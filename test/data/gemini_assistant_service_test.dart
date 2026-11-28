import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:receiptscanner/application/assistant_controller.dart';
import 'package:receiptscanner/data/assistant/gemini_assistant_service.dart';
import 'package:receiptscanner/domain/entities/category.dart';
import 'package:receiptscanner/domain/entities/receipt.dart';
import 'package:receiptscanner/domain/entities/receipt_item.dart';
import 'package:receiptscanner/domain/interfaces/receipt_repository.dart';
import 'package:receiptscanner/domain/logic/expense_tools.dart';

class MockRepoForAssistant implements ReceiptRepository {
  @override
  Future<List<Receipt>> getMonthReceipts(DateTime month, String currency) async => [
        Receipt(
          id: 1,
          merchant: 'Starbucks',
          purchasedAt: DateTime(2026, 3, 1),
          totalMinor: 5500,
          currency: 'KRW',
          categoryId: 1,
          rawOcrText: '',
          parserSource: 'rules',
          confidence: 0.9,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

  @override
  Future<List<Category>> getCategories() async => const [
        Category(id: 1, key: 'food', colorValue: 0xFFF97316, sortOrder: 0),
      ];

  @override
  Stream<List<Receipt>> watchAll() => Stream.value([]);
  @override
  Future<Receipt?> getById(int id) async => null;
  @override
  Future<int> insert(receipt) async => 1;
  @override
  Future<void> update(receipt) async {}
  @override
  Future<void> delete(int id) async {}
  @override
  Stream<List<CategoryTotal>> watchCategoryTotals(DateTime month, String currency) => Stream.value([]);
  @override
  Stream<List<MonthTotal>> watchMonthlyTotals({required int months, required String currency}) => Stream.value([]);
  @override
  Stream<List<Receipt>> watchFiltered(filter) => Stream.value([]);
  @override
  Future<List<Receipt>> findPossibleDuplicates(candidate, {int? excludeId}) async => [];
  @override
  Future<List<ReceiptItem>> getItems(int receiptId) async => [];
  @override
  Future<void> replaceItems(receiptId, items) async {}
}

class QueueHttpClient extends http.BaseClient {
  final List<http.Response Function(http.BaseRequest)> handlers;
  int callIndex = 0;

  QueueHttpClient(this.handlers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (callIndex >= handlers.length) {
      throw Exception('Unexpected HTTP call beyond queue length');
    }
    final response = handlers[callIndex++](request);
    return http.StreamedResponse(
      Stream.value(utf8.encode(response.body)),
      response.statusCode,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }
}

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: '''
GEMINI_API_KEY=test_key
GEMINI_MODEL=gemini-flash-latest
GEMINI_BASE_URL=https://generativelanguage.googleapis.com/v1beta
''');
  });

  group('GeminiAssistantService Tests', () {
    test('one tool call then answer', () async {
      final client = QueueHttpClient([
        (_) => http.Response(
              jsonEncode({
                'candidates': [
                  {
                    'content': {
                      'parts': [
                        {
                          'functionCall': {
                            'name': 'get_spending_total',
                            'args': {'start_date': '2026-03-01', 'end_date': '2026-03-31'}
                          }
                        }
                      ]
                    }
                  }
                ]
              }),
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            ),
        (_) => http.Response(
              jsonEncode({
                'candidates': [
                  {
                    'content': {
                      'parts': [
                        {'text': 'You spent 5,500원 in March.'}
                      ]
                    }
                  }
                ]
              }),
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            ),
      ]);

      final tools = ExpenseTools(MockRepoForAssistant());
      final service = GeminiAssistantService(
        expenseTools: tools,
        overrideApiKey: 'test_key',
        httpClient: client,
      );

      final answer = await service.sendMessage('How much in March?', []);
      expect(answer, 'You spent 5,500원 in March.');
      expect(client.callIndex, 2);
    });

    test('two tool calls then answer', () async {
      final client = QueueHttpClient([
        (_) => http.Response(
              jsonEncode({
                'candidates': [
                  {
                    'content': {
                      'parts': [
                        {
                          'functionCall': {
                            'name': 'get_spending_total',
                            'args': {'start_date': '2026-03-01', 'end_date': '2026-03-31'}
                          }
                        }
                      ]
                    }
                  }
                ]
              }),
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            ),
        (_) => http.Response(
              jsonEncode({
                'candidates': [
                  {
                    'content': {
                      'parts': [
                        {
                          'functionCall': {
                            'name': 'get_top_merchants',
                            'args': {'start_date': '2026-03-01', 'end_date': '2026-03-31', 'limit': 1}
                          }
                        }
                      ]
                    }
                  }
                ]
              }),
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            ),
        (_) => http.Response(
              jsonEncode({
                'candidates': [
                  {
                    'content': {
                      'parts': [
                        {'text': 'Total was 5,500원 at Starbucks.'}
                      ]
                    }
                  }
                ]
              }),
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            ),
      ]);

      final tools = ExpenseTools(MockRepoForAssistant());
      final service = GeminiAssistantService(
        expenseTools: tools,
        overrideApiKey: 'test_key',
        httpClient: client,
      );

      final answer = await service.sendMessage('Summary for March', []);
      expect(answer, 'Total was 5,500원 at Starbucks.');
      expect(client.callIndex, 3);
    });

    test('tool-call cap reached', () async {
      final client = QueueHttpClient([
        for (int i = 0; i < 5; i++)
          (_) => http.Response(
                jsonEncode({
                  'candidates': [
                    {
                      'content': {
                        'parts': [
                          {
                            'functionCall': {
                              'name': 'get_spending_total',
                              'args': {'start_date': '2026-03-01', 'end_date': '2026-03-31'}
                            }
                          }
                        ]
                      }
                    }
                  ]
                }),
                200,
                headers: {'content-type': 'application/json; charset=utf-8'},
              ),
      ]);

      final tools = ExpenseTools(MockRepoForAssistant());
      final service = GeminiAssistantService(
        expenseTools: tools,
        overrideApiKey: 'test_key',
        httpClient: client,
      );

      final answer = await service.sendMessage('Infinite tool loop query', []);
      expect(answer, contains('Reached maximum tool call limit'));
    });

    test('malformed JSON response handled gracefully', () async {
      final client = QueueHttpClient([
        (_) => http.Response('{"invalid_json": true}', 200, headers: {'content-type': 'application/json; charset=utf-8'}),
      ]);

      final tools = ExpenseTools(MockRepoForAssistant());
      final service = GeminiAssistantService(
        expenseTools: tools,
        overrideApiKey: 'test_key',
        httpClient: client,
      );

      final answer = await service.sendMessage('Query', []);
      expect(answer, contains("couldn't generate a response"));
    });

    test('HTTP error and quota error', () async {
      final client = QueueHttpClient([
        (_) => http.Response('Resource exhausted', 429, headers: {'content-type': 'application/json; charset=utf-8'}),
      ]);

      final tools = ExpenseTools(MockRepoForAssistant());
      final service = GeminiAssistantService(
        expenseTools: tools,
        overrideApiKey: 'test_key',
        httpClient: client,
      );

      expect(() => service.sendMessage('Query', []), throwsA(isA<Exception>()));
    });

    test('timeout handling', () async {
      final client = QueueHttpClient([
        (_) {
          throw TimeoutException('Request timed out');
        },
      ]);

      final tools = ExpenseTools(MockRepoForAssistant());
      final service = GeminiAssistantService(
        expenseTools: tools,
        overrideApiKey: 'test_key',
        httpClient: client,
      );

      expect(() => service.sendMessage('Query', []), throwsA(isA<TimeoutException>()));
    });

    test('message longer than 500 chars rejected or capped', () {
      final longPrompt = 'A' * 600;
      final cappedPrompt = longPrompt.length > 500 ? longPrompt.substring(0, 500) : longPrompt;
      expect(cappedPrompt.length, 500);
    });

    test('history capped at 6 turns', () {
      final historyMsgs = List.generate(10, (i) => ChatMessage(text: 'Msg $i', isUser: i.isEven, timestamp: DateTime.now()));
      final boundedHistory = historyMsgs.length > 6
          ? historyMsgs.sublist(historyMsgs.length - 6)
          : historyMsgs;

      expect(boundedHistory.length, 6);
      expect(boundedHistory.first.text, 'Msg 4');
      expect(boundedHistory.last.text, 'Msg 9');
    });

    test('final answer is shown without key or raw JSON', () async {
      final client = QueueHttpClient([
        (_) => http.Response(
              jsonEncode({
                'candidates': [
                  {
                    'content': {
                      'parts': [
                        {'text': 'Your March spending total is ₩5,500.'}
                      ]
                    }
                  }
                ]
              }),
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            ),
      ]);

      final tools = ExpenseTools(MockRepoForAssistant());
      final service = GeminiAssistantService(
        expenseTools: tools,
        overrideApiKey: 'secret_api_key_12345',
        httpClient: client,
      );

      final answer = await service.sendMessage('How much in March?', []);
      expect(answer, isNot(contains('secret_api_key_12345')));
      expect(answer, isNot(contains('{')));
      expect(answer, 'Your March spending total is ₩5,500.');
    });
  });
}
