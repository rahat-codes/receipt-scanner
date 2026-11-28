import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/env.dart';
import '../../domain/interfaces/assistant_service.dart';
import '../../domain/logic/expense_tools.dart';
import 'assistant_prompt.dart';

class GeminiAssistantService implements AssistantService {
  final ExpenseTools expenseTools;
  final String? overrideApiKey;
  final http.Client? httpClient;

  const GeminiAssistantService({
    required this.expenseTools,
    this.overrideApiKey,
    this.httpClient,
  });

  String get _apiKey => overrideApiKey ?? Env.geminiApiKey;

  static final List<Map<String, dynamic>> _functionDeclarations = [
    {
      'name': 'get_spending_total',
      'description': 'Get total spending amount between start_date and end_date.',
      'parameters': {
        'type': 'OBJECT',
        'properties': {
          'start_date': {'type': 'STRING', 'description': 'Start date in ISO format YYYY-MM-DD'},
          'end_date': {'type': 'STRING', 'description': 'End date in ISO format YYYY-MM-DD'},
        },
        'required': ['start_date', 'end_date'],
      },
    },
    {
      'name': 'get_category_breakdown',
      'description': 'Get spending breakdown by category between start_date and end_date.',
      'parameters': {
        'type': 'OBJECT',
        'properties': {
          'start_date': {'type': 'STRING', 'description': 'Start date in ISO format YYYY-MM-DD'},
          'end_date': {'type': 'STRING', 'description': 'End date in ISO format YYYY-MM-DD'},
        },
        'required': ['start_date', 'end_date'],
      },
    },
    {
      'name': 'get_top_merchants',
      'description': 'Get top merchants by spending between start_date and end_date.',
      'parameters': {
        'type': 'OBJECT',
        'properties': {
          'start_date': {'type': 'STRING', 'description': 'Start date in ISO format YYYY-MM-DD'},
          'end_date': {'type': 'STRING', 'description': 'End date in ISO format YYYY-MM-DD'},
          'limit': {'type': 'INTEGER', 'description': 'Max merchants to return (<= 5)'},
        },
        'required': ['start_date', 'end_date'],
      },
    },
    {
      'name': 'find_receipts',
      'description': 'Find receipts between start_date and end_date.',
      'parameters': {
        'type': 'OBJECT',
        'properties': {
          'start_date': {'type': 'STRING', 'description': 'Start date in ISO format YYYY-MM-DD'},
          'end_date': {'type': 'STRING', 'description': 'End date in ISO format YYYY-MM-DD'},
          'limit': {'type': 'INTEGER', 'description': 'Max receipts to return (<= 10)'},
        },
        'required': ['start_date', 'end_date'],
      },
    },
    {
      'name': 'compare_periods',
      'description': 'Compare total spending between two time periods (period A and period B).',
      'parameters': {
        'type': 'OBJECT',
        'properties': {
          'a_start': {'type': 'STRING', 'description': 'Period A start date YYYY-MM-DD'},
          'a_end': {'type': 'STRING', 'description': 'Period A end date YYYY-MM-DD'},
          'b_start': {'type': 'STRING', 'description': 'Period B start date YYYY-MM-DD'},
          'b_end': {'type': 'STRING', 'description': 'Period B end date YYYY-MM-DD'},
        },
        'required': ['a_start', 'a_end', 'b_start', 'b_end'],
      },
    },
  ];

  @override
  Future<String> sendMessage(String prompt, List<Map<String, String>> history) async {
    if (_apiKey.isEmpty) {
      throw Exception('Gemini API key is not configured.');
    }

    final client = httpClient ?? http.Client();
    final url = Uri.parse('${Env.geminiBaseUrl}/models/${Env.geminiModel}:generateContent?key=$_apiKey');

    final todayStr = DateTime.now().toIso8601String().split('T').first;
    final systemInstruction = kAssistantSystemPrompt
        .replaceAll('{today}', todayStr)
        .replaceAll('{language}', 'English'); // or dynamic locale

    final contents = <Map<String, dynamic>>[];
    for (final turn in history) {
      contents.add({
        'role': turn['role'] == 'user' ? 'user' : 'model',
        'parts': [{'text': turn['text']}]
      });
    }
    contents.add({
      'role': 'user',
      'parts': [{'text': prompt}]
    });

    final body = {
      'system_instruction': {
        'parts': [{'text': systemInstruction}]
      },
      'contents': contents,
      'tools': [
        {'functionDeclarations': _functionDeclarations}
      ],
    };

    int toolCallsCount = 0;
    try {
      while (toolCallsCount < Env.assistantMaxToolCalls) {
        final response = await client
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body),
            )
            .timeout(Duration(seconds: Env.assistantTimeoutSeconds));

        if (response.statusCode != 200) {
          throw Exception('Gemini API error: ${response.statusCode} - ${response.reasonPhrase}');
        }

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates == null || candidates.isEmpty) {
          return "I couldn't generate a response. Please try again.";
        }

        final candidate = candidates[0] as Map<String, dynamic>;
        final content = candidate['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List<dynamic>?;
        if (parts == null || parts.isEmpty) {
          return "I couldn't parse the response.";
        }

        // Check if model invoked a function call
        Map<String, dynamic>? functionCallPart;
        for (final p in parts) {
          if (p is Map<String, dynamic> && p.containsKey('functionCall')) {
            functionCallPart = p['functionCall'] as Map<String, dynamic>;
            break;
          }
        }

        if (functionCallPart != null) {
          toolCallsCount++;
          final fnName = functionCallPart['name'] as String;
          final fnArgs = (functionCallPart['args'] as Map<String, dynamic>?) ?? {};

          final toolResult = await expenseTools.execute(fnName, fnArgs);

          // Append assistant function call and function response to contents
          contents.add({
            'role': 'model',
            'parts': [{'functionCall': functionCallPart}]
          });
          contents.add({
            'role': 'function',
            'parts': [
              {
                'functionResponse': {
                  'name': fnName,
                  'response': toolResult,
                }
              }
            ]
          });
          body['contents'] = contents;
          continue;
        }

        // Otherwise return text
        final textParts = parts.where((p) => p is Map<String, dynamic> && p.containsKey('text')).map((p) => p['text'] as String).toList();
        if (textParts.isNotEmpty) {
          return textParts.join('\n');
        }

        return "I processed your request but had no text to return.";
      }

      return "Reached maximum tool call limit without final answer.";
    } catch (e) {
      rethrow;
    } finally {
      if (httpClient == null) {
        client.close();
      }
    }
  }
}
