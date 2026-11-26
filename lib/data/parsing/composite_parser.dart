import '../../core/env.dart';
import '../../domain/entities/ocr_result.dart';
import '../../domain/entities/parsed_receipt.dart';
import '../../domain/interfaces/receipt_parser.dart';

class CompositeParser implements ReceiptParser {
  final ReceiptParser ruleParser;
  final ReceiptParser llmParser;
  final double threshold;
  final bool isLlmEnabled;

  CompositeParser({
    required this.ruleParser,
    required this.llmParser,
    double? threshold,
    this.isLlmEnabled = true,
  }) : threshold = threshold ?? Env.llmFallbackThreshold;

  @override
  Future<ParsedReceipt> parse(OcrResult ocr) async {
    final ruleResult = await ruleParser.parse(ocr);

    if (isLlmEnabled && ruleResult.confidence < threshold) {
      try {
        final llmResult = await llmParser.parse(ocr);
        // Merge: use LLM where rules had null or flagged field
        final mergedMerchant = (ruleResult.merchant == null || ruleResult.needsReview.contains(FieldFlag.merchant))
            ? (llmResult.merchant ?? ruleResult.merchant)
            : ruleResult.merchant;

        final mergedDate = (ruleResult.date == null || ruleResult.needsReview.contains(FieldFlag.date))
            ? (llmResult.date ?? ruleResult.date)
            : ruleResult.date;

        final mergedTotal = (ruleResult.totalMinor == null || ruleResult.totalMinor! <= 0 || ruleResult.needsReview.contains(FieldFlag.total))
            ? (llmResult.totalMinor ?? ruleResult.totalMinor)
            : ruleResult.totalMinor;

        final needsReview = <FieldFlag>{};
        if (mergedMerchant == null || mergedMerchant.isEmpty) needsReview.add(FieldFlag.merchant);
        if (mergedDate == null) needsReview.add(FieldFlag.date);
        if (mergedTotal == null || mergedTotal <= 0) needsReview.add(FieldFlag.total);

        return ParsedReceipt(
          merchant: mergedMerchant,
          date: mergedDate,
          totalMinor: mergedTotal,
          currency: llmResult.currency.isNotEmpty ? llmResult.currency : ruleResult.currency,
          confidence: (ruleResult.confidence + llmResult.confidence) / 2,
          needsReview: needsReview,
          source: ParseSource.llm,
        );
      } catch (_) {
        // Fallback failed or timed out: keep rule result per Section 6.2
        return ruleResult;
      }
    }

    return ruleResult;
  }
}
