import '../../domain/entities/ocr_result.dart';

class DateExtractor {
  static DateTime? extract(OcrResult ocr) {
    final text = ocr.fullText;
    final now = DateTime.now();

    // 1. yyyy-mm-dd, yyyy/mm/dd, yyyy.mm.dd (using backreference \2 for matching the same separator)
    final ymdRegex = RegExp(r'\b(20\d{2})([-/.])(\d{1,2})\2(\d{1,2})\b');
    final ymdMatch = ymdRegex.firstMatch(text);
    if (ymdMatch != null) {
      try {
        final year = int.parse(ymdMatch.group(1)!);
        final month = int.parse(ymdMatch.group(3)!);
        final day = int.parse(ymdMatch.group(4)!);
        if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
          final date = DateTime(year, month, day);
          if (!date.isAfter(now.add(const Duration(days: 1)))) {
            return date;
          }
        }
      } catch (_) {}
    }

    // 2. yyyy년 m월 d일
    final korRegex = RegExp(r'(20\d{2})\s*년\s*(\d{1,2})\s*월\s*(\d{1,2})\s*일');
    final korMatch = korRegex.firstMatch(text);
    if (korMatch != null) {
      try {
        final year = int.parse(korMatch.group(1)!);
        final month = int.parse(korMatch.group(2)!);
        final day = int.parse(korMatch.group(3)!);
        if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
          final date = DateTime(year, month, day);
          if (!date.isAfter(now.add(const Duration(days: 1)))) {
            return date;
          }
        }
      } catch (_) {}
    }

    // 3. mm/dd/yyyy
    final mdyRegex = RegExp(r'\b(\d{1,2})/(\d{1,2})/(20\d{2})\b');
    final mdyMatch = mdyRegex.firstMatch(text);
    if (mdyMatch != null) {
      try {
        final month = int.parse(mdyMatch.group(1)!);
        final day = int.parse(mdyMatch.group(2)!);
        final year = int.parse(mdyMatch.group(3)!);
        if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
          final date = DateTime(year, month, day);
          if (!date.isAfter(now.add(const Duration(days: 1)))) {
            return date;
          }
        }
      } catch (_) {}
    }

    // 4. yy-mm-dd
    final yyRegex = RegExp(r'\b(\d{2})([-/.])(\d{1,2})\2(\d{1,2})\b');
    final yyMatch = yyRegex.firstMatch(text);
    if (yyMatch != null) {
      try {
        int year = int.parse(yyMatch.group(1)!);
        if (year < 100) year += 2000;
        final month = int.parse(yyMatch.group(3)!);
        final day = int.parse(yyMatch.group(4)!);
        if (year >= 2000 && month >= 1 && month <= 12 && day >= 1 && day <= 31) {
          final date = DateTime(year, month, day);
          if (!date.isAfter(now.add(const Duration(days: 1)))) {
            return date;
          }
        }
      } catch (_) {}
    }

    return null;
  }
}
