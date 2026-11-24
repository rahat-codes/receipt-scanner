import '../../domain/entities/ocr_result.dart';
import '../../domain/entities/parsed_receipt.dart';
import '../../domain/interfaces/receipt_parser.dart';
import 'date_extractor.dart';
import 'merchant_extractor.dart';
import 'total_extractor.dart';

class RuleBasedParser implements ReceiptParser {
  @override
  Future<ParsedReceipt> parse(OcrResult ocr) async {
    final totalResult = TotalExtractor.extract(ocr);
    final date = DateExtractor.extract(ocr);
    final merchant = MerchantExtractor.extract(ocr);

    double confidence = totalResult.confidence;
    final needsReview = <FieldFlag>{};

    if (totalResult.totalMinor != null && totalResult.totalMinor! > 0) {
      confidence += 0.10; // plausible amount bonus
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
