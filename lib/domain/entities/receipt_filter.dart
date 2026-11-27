import 'package:meta/meta.dart';

@immutable
class ReceiptFilter {
  final String? text;            // merchant or item name
  final int? categoryId;
  final DateTime? from;          // inclusive
  final DateTime? to;            // exclusive
  const ReceiptFilter({this.text, this.categoryId, this.from, this.to});
  bool get isEmpty => text == null && categoryId == null && from == null && to == null;
}
