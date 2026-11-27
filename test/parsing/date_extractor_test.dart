import 'package:flutter_test/flutter_test.dart';
import 'package:receiptscanner/data/parsing/date_extractor.dart';
import 'package:receiptscanner/domain/entities/ocr_result.dart';

void main() {
  group('DateExtractor Tests', () {
    test('extracts yyyy-mm-dd', () {
      final ocr = OcrResult(fullText: 'Date: 2024-05-12', lines: [OcrLine('Date: 2024-05-12', 0.2)]);
      final date = DateExtractor.extract(ocr);
      expect(date, DateTime(2024, 5, 12));
    });

    test('extracts yyyy/mm/dd', () {
      final ocr = OcrResult(fullText: '2024/12/25', lines: [OcrLine('2024/12/25', 0.2)]);
      final date = DateExtractor.extract(ocr);
      expect(date, DateTime(2024, 12, 25));
    });

    test('extracts yyyy.mm.dd', () {
      final ocr = OcrResult(fullText: '2024.01.05', lines: [OcrLine('2024.01.05', 0.2)]);
      final date = DateExtractor.extract(ocr);
      expect(date, DateTime(2024, 1, 5));
    });

    test('extracts yy-mm-dd', () {
      final ocr = OcrResult(fullText: '23-10-15', lines: [OcrLine('23-10-15', 0.2)]);
      final date = DateExtractor.extract(ocr);
      expect(date, DateTime(2023, 10, 15));
    });

    test('extracts yyyy년 m월 d일', () {
      final ocr = OcrResult(fullText: '2024년 3월 1일', lines: [OcrLine('2024년 3월 1일', 0.2)]);
      final date = DateExtractor.extract(ocr);
      expect(date, DateTime(2024, 3, 1));
    });

    test('extracts mm/dd/yyyy', () {
      final ocr = OcrResult(fullText: '04/15/2024', lines: [OcrLine('04/15/2024', 0.2)]);
      final date = DateExtractor.extract(ocr);
      expect(date, DateTime(2024, 4, 15));
    });

    test('rejects future dates', () {
      final ocr = OcrResult(fullText: '2099-01-01', lines: [OcrLine('2099-01-01', 0.2)]);
      final date = DateExtractor.extract(ocr);
      expect(date, isNull);
    });
  });
}
