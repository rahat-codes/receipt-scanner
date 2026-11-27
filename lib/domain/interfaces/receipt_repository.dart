import 'package:meta/meta.dart';
import '../entities/category.dart';
import '../entities/receipt.dart';
import '../entities/receipt_filter.dart';
import '../entities/receipt_item.dart';

@immutable
class CategoryTotal {
  final String categoryKey;
  final int colorValue;
  final int totalMinor;

  const CategoryTotal({
    required this.categoryKey,
    required this.colorValue,
    required this.totalMinor,
  });
}

@immutable
class MonthTotal {
  final String month; // 'YYYY-MM'
  final int totalMinor;

  const MonthTotal({
    required this.month,
    required this.totalMinor,
  });
}

abstract class ReceiptRepository {
  Stream<List<Receipt>> watchAll();
  Future<Receipt?> getById(int id);
  Future<int> insert(Receipt receipt);
  Future<void> update(Receipt receipt);
  Future<void> delete(int id);
  Stream<List<CategoryTotal>> watchCategoryTotals(DateTime month, String currency);
  Stream<List<MonthTotal>> watchMonthlyTotals({required int months, required String currency});
  Future<List<Category>> getCategories();

  // v2 methods
  Stream<List<Receipt>> watchFiltered(ReceiptFilter filter);
  Future<List<Receipt>> getMonthReceipts(DateTime month, String currency);
  Future<List<Receipt>> findPossibleDuplicates(Receipt candidate, {int? excludeId});
  Future<List<ReceiptItem>> getItems(int receiptId);
  Future<void> replaceItems(int receiptId, List<ReceiptItem> items);
}
