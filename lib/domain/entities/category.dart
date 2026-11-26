import 'package:meta/meta.dart';

@immutable
class Category {
  final int id;
  final String key;
  final int colorValue;
  final int sortOrder;

  const Category({
    required this.id,
    required this.key,
    required this.colorValue,
    required this.sortOrder,
  });
}
