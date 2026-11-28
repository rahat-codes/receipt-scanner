import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:receiptscanner/data/assistant/gemini_assistant_service.dart';
import 'package:receiptscanner/domain/logic/expense_tools.dart';
import 'package:receiptscanner/domain/interfaces/receipt_repository.dart';
import 'package:receiptscanner/domain/entities/category.dart';
import 'package:receiptscanner/domain/entities/receipt.dart';
import 'package:receiptscanner/domain/entities/receipt_item.dart';

class FailingHttpClient extends http.BaseClient {
  int callCount = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    callCount++;
    throw UnimplementedError('Network call attempted without user consent!');
  }
}

class FakeRepoForConsent implements ReceiptRepository {
  @override
  Future<List<Receipt>> getMonthReceipts(DateTime month, String currency) async => [];
  @override
  Future<List<Category>> getCategories() async => [];
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

void main() {
  group('Assistant Consent Gating Tests', () {
    test('proves zero network calls before consent is granted', () async {
      final failingClient = FailingHttpClient();
      final tools = ExpenseTools(FakeRepoForConsent());

      // Attempting to send message without API key or before consent does not trigger network requests
      final service = GeminiAssistantService(
        expenseTools: tools,
        overrideApiKey: '', // empty key prior to consent / config
        httpClient: failingClient,
      );

      expect(failingClient.callCount, 0);

      try {
        await service.sendMessage('How much did I spend?', []);
      } catch (_) {}

      // Zero network calls occurred
      expect(failingClient.callCount, 0);
    });
  });
}
