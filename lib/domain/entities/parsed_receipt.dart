import 'package:meta/meta.dart';

enum FieldFlag { merchant, date, total, currency }

enum ParseSource { rules, llm, manual }

@immutable
class ParsedReceipt {
  final String? merchant;
  final DateTime? date;
  final int? totalMinor; // integer minor units
  final String currency; // 'KRW' | 'USD'
  final double confidence; // 0..1
  final Set<FieldFlag> needsReview; // drives amber highlights
  final ParseSource source;

  const ParsedReceipt({
    this.merchant,
    this.date,
    this.totalMinor,
    this.currency = 'KRW',
    required this.confidence,
    this.needsReview = const {},
    this.source = ParseSource.rules,
  });
}
