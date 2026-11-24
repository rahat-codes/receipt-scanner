import 'package:flutter_test/flutter_test.dart';
import 'package:receiptscanner/data/parsing/total_extractor.dart';
import 'package:receiptscanner/domain/entities/ocr_result.dart';

void main() {
  group('TotalExtractor', () {
    test('extracts total with Korean 합계 keyword', () {
      final ocr = OcrResult(
        fullText: 'GS25\n합계 ₩4,300\n부가세 400',
        lines: [
          OcrLine('GS25', 0.1),
          OcrLine('합계 ₩4,300', 0.8),
          OcrLine('부가세 400', 0.9),
        ],
      );

      final result = TotalExtractor.extract(ocr);
      expect(result.totalMinor, 4300);
      expect(result.currency, 'KRW');
    });

    test('ignores SUBTOTAL and picks TOTAL', () {
      final ocr = OcrResult(
        fullText: 'SUBTOTAL \$10.00\nTAX \$1.00\nTOTAL \$11.00',
        lines: [
          OcrLine('SUBTOTAL \$10.00', 0.6),
          OcrLine('TAX \$1.00', 0.7),
          OcrLine('TOTAL \$11.00', 0.8),
        ],
      );

      final result = TotalExtractor.extract(ocr);
      expect(result.totalMinor, 1100); // 11.00 USD -> 1100 cents
      expect(result.currency, 'USD');
    });
  });
}
