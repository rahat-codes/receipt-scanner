import 'package:flutter_test/flutter_test.dart';
import 'package:receiptscanner/data/parsing/rule_based_parser.dart';
import 'package:receiptscanner/domain/entities/ocr_result.dart';
import 'package:receiptscanner/domain/entities/parsed_receipt.dart';

void main() {
  group('RuleBasedParser Tests', () {
    test('parses complete receipt successfully', () async {
      final ocr = OcrResult(
        fullText: '스타벅스\n2024-03-01\n합계 ₩5,500',
        lines: [
          OcrLine('스타벅스', 0.1),
          OcrLine('2024-03-01', 0.5),
          OcrLine('합계 ₩5,500', 0.9),
        ],
      );

      final parser = RuleBasedParser();
      final parsed = await parser.parse(ocr);

      expect(parsed.merchant, '스타벅스');
      expect(parsed.date, DateTime(2024, 3, 1));
      expect(parsed.totalMinor, 5500);
      expect(parsed.currency, 'KRW');
      expect(parsed.needsReview, isEmpty);
      expect(parsed.confidence, greaterThan(0.8));
    });

    test('handles receipt with nothing parseable (all null, confidence near 0, all flagged)', () async {
      final ocr = OcrResult(
        fullText: '',
        lines: [],
      );

      final parser = RuleBasedParser();
      final parsed = await parser.parse(ocr);

      expect(parsed.merchant, isNull);
      expect(parsed.date, isNull);
      expect(parsed.totalMinor, isNull);
      expect(parsed.confidence, lessThan(0.1));
      expect(parsed.needsReview, containsAll([FieldFlag.merchant, FieldFlag.date, FieldFlag.total]));
    });
  });
}
