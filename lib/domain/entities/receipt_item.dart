import 'package:meta/meta.dart';

@immutable
class ReceiptItem {
  final int id;
  final int receiptId;
  final String name;
  final int quantity;
  final int? unitPriceMinor;
  final int lineTotalMinor;
  final int position;

  const ReceiptItem({
    this.id = 0,
    required this.receiptId,
    required this.name,
    this.quantity = 1,
    this.unitPriceMinor,
    required this.lineTotalMinor,
    this.position = 0,
  });
}
