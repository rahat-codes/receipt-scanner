import '../../domain/entities/ocr_result.dart';
import '../../domain/entities/parsed_receipt.dart';
import '../../domain/interfaces/receipt_parser.dart';
import 'date_extractor.dart';
import 'merchant_extractor.dart';
import 'total_extractor.dart';

class RuleBasedParser implements ReceiptParser {
  @override
  Future<ParsedReceipt> parse(OcrResult ocr) async {
    // WHY: Cap OCR text length (max 10,000 chars) and line count (max 200 lines) to protect against memory exhaustion.
    String cappedText = ocr.fullText;
    if (cappedText.length > 10000) {
      cappedText = cappedText.substring(0, 10000);
    }
    List<OcrLine> cappedLines = ocr.lines;
    if (cappedLines.length > 200) {
      cappedLines = cappedLines.take(200).toList();
    }
    final safeOcr = OcrResult(fullText: cappedText, lines: cappedLines);

    final totalResult = TotalExtractor.extract(safeOcr);
    final date = DateExtractor.extract(safeOcr);
    final merchant = MerchantExtractor.extract(safeOcr);

    double confidence = totalResult.confidence;
    final needsReview = <FieldFlag>{};

    if (totalResult.totalMinor != null && totalResult.totalMinor! > 0) {
      confidence += 0.10; // consistency bonus
    } else {
      needsReview.add(FieldFlag.total);
    }

    if (date != null) {
      confidence += 0.25;
    } else {
      needsReview.add(FieldFlag.date);
    }

    if (merchant != null && merchant.isNotEmpty) {
      confidence += 0.20;
    } else {
      needsReview.add(FieldFlag.merchant);
    }

    if (totalResult.currency.isNotEmpty) {
      // currency valid
    } else {
      needsReview.add(FieldFlag.currency);
    }

    confidence = confidence.clamp(0.0, 1.0);

    return ParsedReceipt(
      merchant: merchant,
      date: date,
      totalMinor: totalResult.totalMinor,
      currency: totalResult.currency,
      confidence: confidence,
      needsReview: needsReview,
      source: ParseSource.rules,
    );
  }
}
