import '../../domain/entities/ocr_result.dart';

class MerchantExtractor {
  static const _merchantKeywords = ['상호', '가맹점명', '매장명', 'store', 'merchant'];

  static String? extract(OcrResult ocr) {
    for (final line in ocr.lines) {
      final text = line.text;
      final lower = text.toLowerCase();
      for (final kw in _merchantKeywords) {
        if (lower.contains(kw)) {
          final parts = text.split(RegExp(r'[:：]'));
          if (parts.length > 1 && parts[1].trim().length > 1) {
            return _clean(parts[1]);
          }
          if (text.trim().length > kw.length + 1) {
            return _clean(text.replaceAll(RegExp(kw, caseSensitive: false), ''));
          }
        }
      }
    }

    final sortedLines = List<OcrLine>.from(ocr.lines)..sort((a, b) => a.top.compareTo(b.top));
    for (final line in sortedLines) {
      final t = line.text.trim();
      if (t.length >= 2 && !_isIgnoredLine(t)) {
        return _clean(t);
      }
    }

    return null;
  }

  static bool _isIgnoredLine(String text) {
    if (RegExp(r'^\d+[\d\-()\s]*$').hasMatch(text)) return true;
    if (text.contains('전화') || text.contains('TEL') || text.contains('No.')) return true;
    return false;
  }

  static String _clean(String text) {
    return text.replaceAll(RegExp(r"[^\w\s가-힣&()\'-]"), '').trim();
  }
}
