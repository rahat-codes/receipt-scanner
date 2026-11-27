import 'package:flutter_test/flutter_test.dart';
import 'package:receiptscanner/data/parsing/merchant_extractor.dart';
import 'package:receiptscanner/domain/entities/ocr_result.dart';

void main() {
  group('MerchantExtractor Tests', () {
    test('extracts labeled merchant', () {
      final ocr = OcrResult(
        fullText: '상호: 스타벅스 대연점\nTEL: 051-123-4567',
        lines: [
          OcrLine('상호: 스타벅스 대연점', 0.1),
          OcrLine('TEL: 051-123-4567', 0.2),
        ],
      );
      final merchant = MerchantExtractor.extract(ocr);
      expect(merchant, '스타벅스 대연점');
    });

    test('falls back to top non-ignored line', () {
      final ocr = OcrResult(
        fullText: '051-123-4567\nGS25 부산점',
        lines: [
          OcrLine('051-123-4567', 0.1),
          OcrLine('GS25 부산점', 0.2),
        ],
      );
      final merchant = MerchantExtractor.extract(ocr);
      expect(merchant, 'GS25 부산점');
    });
  });
}
