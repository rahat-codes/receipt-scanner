import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/env.dart';
import '../../core/masking.dart';
import '../../domain/entities/ocr_result.dart';
import '../../domain/entities/parsed_receipt.dart';
import '../../domain/interfaces/receipt_parser.dart';

class LlmParser implements ReceiptParser {
  final http.Client client;

  LlmParser({http.Client? client}) : client = client ?? http.Client();

  @override
  Future<ParsedReceipt> parse(OcrResult ocr) async {
    if (Env.geminiApiKey.isEmpty) {
      throw Exception('Gemini API key is not configured.');
    }

    final maskedText = maskSensitiveText(ocr.fullText);
    final url = Uri.parse('${Env.geminiBaseUrl}/models/${Env.geminiModel}:generateContent?key=${Env.geminiApiKey}');

    final prompt = '''
You are a receipt parsing assistant. Extract merchant name, purchase date (ISO 8601 YYYY-MM-DD), total amount as an integer in minor units (cents for USD, won for KRW), and currency code ('KRW' or 'USD') from this receipt text.
Reply with JSON only in this exact format:
{
  "merchant": "string",
  "date": "YYYY-MM-DD",
  "totalMinor": 1234,
  "currency": "KRW"
}

Receipt text:
$maskedText
''';

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
      }
    });

    try {
      final response = await client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(Duration(seconds: Env.geminiTimeoutSeconds));

      if (response.statusCode != 200) {
        throw Exception('Gemini API returned status ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('No candidates returned from Gemini.');
      }

      final textResponse = candidates[0]['content']['parts'][0]['text'] as String;
      final jsonParsed = jsonDecode(textResponse);

      final merchant = jsonParsed['merchant'] as String?;
      final dateStr = jsonParsed['date'] as String?;
      final totalMinor = jsonParsed['totalMinor'] as int?;
      final currency = jsonParsed['currency'] as String? ?? 'KRW';

      DateTime? date;
      if (dateStr != null) {
        date = DateTime.tryParse(dateStr);
      }

      final needsReview = <FieldFlag>{};
      if (merchant == null || merchant.isEmpty) needsReview.add(FieldFlag.merchant);
      if (date == null) needsReview.add(FieldFlag.date);
      if (totalMinor == null || totalMinor <= 0) needsReview.add(FieldFlag.total);

      return ParsedReceipt(
        merchant: merchant,
        date: date,
        totalMinor: totalMinor,
        currency: currency,
        confidence: 0.85,
        needsReview: needsReview,
        source: ParseSource.llm,
      );
    } catch (e) {
      throw Exception('LLM parsing failed: $e');
    }
  }
}
