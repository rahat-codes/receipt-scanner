import '../../domain/entities/ocr_result.dart';

class DateExtractor {
  static DateTime? extract(OcrResult ocr) {
    final text = ocr.fullText;

    final patterns = [
      RegExp(r'\b(20\d{2})[-/. ](\d{1,2})[-/. ](\d{1,2})\b'),
      RegExp(r'\b(20\d{2})년\s*(\d{1,2})월\s*(\d{1,2})일\b'),
      RegExp(r'\b(\d{2})[-/. ](\d{1,2})[-/. ](\d{1,2})\b'),
      RegExp(r'\b(\d{1,2})/(\d{1,2})/(20\d{2})\b'),
    ];

    final now = DateTime.now();

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        try {
          int year = 0, month = 0, day = 0;
          if (pattern.pattern.startsWith(r'\b(\d{1,2})/')) {
            month = int.parse(match.group(1)!);
            day = int.parse(match.group(2)!);
            year = int.parse(match.group(3)!);
          } else {
            year = int.parse(match.group(1)!);
            if (year < 100) year += 2000;
            month = int.parse(match.group(2)!);
            day = int.parse(match.group(3)!);
          }

          if (year >= 2000 && year <= now.year + 1 && month >= 1 && month <= 12 && day >= 1 && day <= 31) {
            final date = DateTime(year, month, day);
            if (!date.isAfter(now.add(const Duration(days: 1)))) {
              return date;
            }
          }
        } catch (_) {}
      }
    }

    return null;
  }
}
