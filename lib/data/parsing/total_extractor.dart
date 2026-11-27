import '../../domain/entities/ocr_result.dart';

class TotalExtractionResult {
  final int? totalMinor;
  final String currency;
  final double confidence;

  const TotalExtractionResult({this.totalMinor, this.currency = 'KRW', this.confidence = 0.0});
}

class TotalExtractor {
  static const _totalKeywords = [
    '합계', '총액', '총 금액', '결제금액', '받을금액', '청구금액', '승인금액', '합 계',
    'total', 'grand total', 'amount due', 'balance due'
  ];

  static const _exclusionKeywords = [
    '부가세', '과세', '면세', '공급가액', '소계', '거스름', '받은금액',
    'subtotal', 'tax', 'change', 'cash'
  ];

  static TotalExtractionResult extract(OcrResult ocr) {
    final lines = ocr.lines;
    
    // WHY: Scan for total keywords first, ignoring exclusion keywords (e.g. 부가세, SUBTOTAL).
    for (int i = 0; i < lines.length; i++) {
      final lineText = lines[i].text.toLowerCase();
      
      if (_exclusionKeywords.any((ex) => lineText.contains(ex))) {
        continue;
      }

      if (_totalKeywords.any((kw) => lineText.contains(kw))) {
        var amount = _parseAmount(lines[i].text);
        if (amount != null && amount > 0 && amount < 100000000) {
          final currency = _detectCurrency(lines[i].text);
          return TotalExtractionResult(totalMinor: amount, currency: currency, confidence: 0.45);
        }
        
        if (i + 1 < lines.length) {
          amount = _parseAmount(lines[i + 1].text);
          if (amount != null && amount > 0 && amount < 100000000) {
            final currency = _detectCurrency(lines[i + 1].text);
            return TotalExtractionResult(totalMinor: amount, currency: currency, confidence: 0.40);
          }
        }
      }
    }

    // WHY: Fallback to largest plausible amount in the bottom half of the receipt.
    int maxAmount = 0;
    String currency = 'KRW';
    
    final halfIndex = (lines.length / 2).floor();
    for (int i = halfIndex; i < lines.length; i++) {
      final text = lines[i].text;
      if (_exclusionKeywords.any((ex) => text.toLowerCase().contains(ex))) continue;
      
      final amount = _parseAmount(text);
      if (amount != null && amount > maxAmount && amount > 0 && amount < 100000000) {
        maxAmount = amount;
        currency = _detectCurrency(text);
      }
    }

    if (maxAmount == 0) {
      for (final line in lines) {
        final text = line.text;
        if (_exclusionKeywords.any((ex) => text.toLowerCase().contains(ex))) continue;

        final amount = _parseAmount(text);
        if (amount != null && amount > maxAmount && amount > 0 && amount < 100000000) {
          maxAmount = amount;
          currency = _detectCurrency(text);
        }
      }
    }

    if (maxAmount > 0) {
      return TotalExtractionResult(totalMinor: maxAmount, currency: currency, confidence: 0.20);
    }

    return const TotalExtractionResult();
  }

  static int? _parseAmount(String text) {
    final matches = RegExp(r'\b\d{1,3}(?:[,\s]\d{3})*(?:[.,]\d{2})?\b|\b\d+(?:[.,]\d{2})?\b').allMatches(text);
    int? maxVal;
    for (final match in matches) {
      var numStr = match.group(0)!.replaceAll(RegExp(r'[, ]'), '');
      int? val;
      if (numStr.contains('.')) {
        final parts = numStr.split('.');
        final dollars = int.tryParse(parts[0]) ?? 0;
        final cents = int.tryParse(parts[1]) ?? 0;
        val = dollars * 100 + cents;
      } else {
        val = int.tryParse(numStr);
      }
      if (val != null && (maxVal == null || val > maxVal)) {
        maxVal = val;
      }
    }
    return maxVal;
  }

  static String _detectCurrency(String text) {
    if (text.contains('\$') || text.toUpperCase().contains('USD')) {
      return 'USD';
    }
    return 'KRW';
  }
}
