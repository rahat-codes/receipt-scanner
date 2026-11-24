import 'package:meta/meta.dart';

@immutable
class Receipt {
  final int id;
  final String merchant;
  final DateTime purchasedAt;
  final int totalMinor;
  final String currency;
  final int categoryId;
  final String? imagePath;
  final String rawOcrText;
  final String parserSource;
  final double confidence;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Receipt({
    required this.id,
    required this.merchant,
    required this.purchasedAt,
    required this.totalMinor,
    this.currency = 'KRW',
    required this.categoryId,
    this.imagePath,
    required this.rawOcrText,
    required this.parserSource,
    required this.confidence,
    required this.createdAt,
    required this.updatedAt,
  });
}
