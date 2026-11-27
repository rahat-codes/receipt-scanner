import 'package:flutter_test/flutter_test.dart';
import 'package:receiptscanner/data/parsing/total_extractor.dart';
import 'package:receiptscanner/domain/entities/ocr_result.dart';

void main() {
  group('TotalExtractor Tests', () {
    test('extracts total with Korean 합계 keyword', () {
      final ocr = OcrResult(
        fullText: 'GS25 대연점\n합계 ₩4,300\n부가세 400',
        lines: [
          OcrLine('GS25 대연점', 0.1),
          OcrLine('합계 ₩4,300', 0.8),
          OcrLine('부가세 400', 0.9),
        ],
      );
      final res = TotalExtractor.extract(ocr);
      expect(res.totalMinor, 4300);
      expect(res.currency, 'KRW');
    });

    test('ignores SUBTOTAL and picks TOTAL', () {
      final ocr = OcrResult(
        fullText: 'SUBTOTAL \$10.00\nTAX \$1.00\nTOTAL \$11.00',
        lines: [
          OcrLine('SUBTOTAL \$10.00', 0.6),
          OcrLine('TAX \$1.00', 0.7),
          OcrLine('TOTAL \$11.00', 0.9),
        ],
      );
      final res = TotalExtractor.extract(ocr);
      expect(res.totalMinor, 1100);
      expect(res.currency, 'USD');
    });

    test('handles \\ read instead of ₩', () {
      final ocr = OcrResult(
        fullText: 'Store\nTOTAL \\15,000',
        lines: [
          OcrLine('Store', 0.1),
          OcrLine('TOTAL \\15,000', 0.9),
        ],
      );
      final res = TotalExtractor.extract(ocr);
      expect(res.totalMinor, 15000);
      expect(res.currency, 'KRW');
    });

    test('keyword on one line and amount on the next', () {
      final ocr = OcrResult(
        fullText: 'Store\n합계\n12,300원',
        lines: [
          OcrLine('Store', 0.1),
          OcrLine('합계', 0.7),
          OcrLine('12,300원', 0.9),
        ],
      );
      final res = TotalExtractor.extract(ocr);
      expect(res.totalMinor, 12300);
      expect(res.currency, 'KRW');
    });

    test('handles 합계 and 합 계', () {
      final ocr = OcrResult(
        fullText: '합 계 ₩5,500',
        lines: [
          OcrLine('합 계 ₩5,500', 0.8),
        ],
      );
      final res = TotalExtractor.extract(ocr);
      expect(res.totalMinor, 5500);
    });

    test('ignores 부가세 line', () {
      final ocr = OcrResult(
        fullText: '부가세 3,000\n총액 30,000',
        lines: [
          OcrLine('부가세 3,000', 0.7),
          OcrLine('총액 30,000', 0.9),
        ],
      );
      final res = TotalExtractor.extract(ocr);
      expect(res.totalMinor, 30000);
    });

    test('fallback largest-amount case in bottom half', () {
      final ocr = OcrResult(
        fullText: 'Item 1 500\nItem 2 1,200',
        lines: [
          OcrLine('Item 1 500', 0.2),
          OcrLine('Item 2 1,200', 0.8),
        ],
      );
      final res = TotalExtractor.extract(ocr);
      expect(res.totalMinor, 1200);
      expect(res.confidence, 0.20);
    });

    test('rejects implausible amounts >= 100,000,000', () {
      final ocr = OcrResult(
        fullText: 'TOTAL 150,000,000',
        lines: [
          OcrLine('TOTAL 150,000,000', 0.9),
        ],
      );
      final res = TotalExtractor.extract(ocr);
      expect(res.totalMinor, isNull);
    });
  });
}
