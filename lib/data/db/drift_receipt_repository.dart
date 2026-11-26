import 'package:drift/drift.dart' as drift;
import '../../domain/entities/category.dart' as domain;
import '../../domain/entities/receipt.dart' as domain;
import '../../domain/interfaces/receipt_repository.dart';
import 'app_database.dart' as db;

class DriftReceiptRepository implements ReceiptRepository {
  final db.AppDatabase database;

  DriftReceiptRepository(this.database);

  @override
  Stream<List<domain.Receipt>> watchAll() {
    return (database.select(database.receipts)..orderBy([(t) => drift.OrderingTerm.desc(t.purchasedAt), (t) => drift.OrderingTerm.desc(t.id)]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<domain.Receipt?> getById(int id) async {
    final row = await (database.select(database.receipts)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row != null ? _toDomain(row) : null;
  }

  @override
  Future<int> insert(domain.Receipt receipt) async {
    return await database.into(database.receipts).insert(db.ReceiptsCompanion.insert(
          merchant: drift.Value(receipt.merchant),
          purchasedAt: receipt.purchasedAt,
          totalMinor: receipt.totalMinor,
          currency: drift.Value(receipt.currency),
          categoryId: receipt.categoryId,
          imagePath: drift.Value(receipt.imagePath),
          rawOcrText: drift.Value(receipt.rawOcrText),
          parserSource: drift.Value(receipt.parserSource),
          confidence: drift.Value(receipt.confidence),
        ));
  }

  @override
  Future<void> update(domain.Receipt receipt) async {
    await (database.update(database.receipts)..where((t) => t.id.equals(receipt.id))).write(db.ReceiptsCompanion(
          merchant: drift.Value(receipt.merchant),
          purchasedAt: drift.Value(receipt.purchasedAt),
          totalMinor: drift.Value(receipt.totalMinor),
          currency: drift.Value(receipt.currency),
          categoryId: drift.Value(receipt.categoryId),
          imagePath: drift.Value(receipt.imagePath),
          rawOcrText: drift.Value(receipt.rawOcrText),
          parserSource: drift.Value(receipt.parserSource),
          confidence: drift.Value(receipt.confidence),
          updatedAt: drift.Value(DateTime.now()),
        ));
  }

  @override
  Future<void> delete(int id) async {
    await (database.delete(database.receipts)..where((t) => t.id.equals(id))).go();
  }

  @override
  Stream<List<CategoryTotal>> watchCategoryTotals(DateTime month, String currency) {
    final start = DateTime(month.year, month.month, 1);
    final nextMonth = DateTime(month.year, month.month + 1, 1);

    final query = database.select(database.receipts).join([
      drift.innerJoin(database.categories, database.categories.id.equalsExp(database.receipts.categoryId)),
    ])
      ..where(database.receipts.currency.equals(currency) &
              database.receipts.purchasedAt.isBiggerOrEqualValue(start) &
              database.receipts.purchasedAt.isSmallerThanValue(nextMonth))
      ..groupBy([database.categories.id]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final cat = row.readTable(database.categories);
        final total = row.read<int>(database.receipts.totalMinor.sum()) ?? 0;
        return CategoryTotal(
          categoryKey: cat.key,
          colorValue: cat.colorValue,
          totalMinor: total,
        );
      }).toList();
    });
  }

  @override
  Stream<List<MonthTotal>> watchMonthlyTotals({required int months, required String currency}) {
    return (database.select(database.receipts)..where((t) => t.currency.equals(currency))).watch().map((rows) {
      final map = <String, int>{};
      for (final r in rows) {
        final mKey = '${r.purchasedAt.year}-${r.purchasedAt.month.toString().padLeft(2, '0')}';
        map[mKey] = (map[mKey] ?? 0) + r.totalMinor;
      }
      final sortedKeys = map.keys.toList()..sort();
      final recentKeys = sortedKeys.length > months ? sortedKeys.sublist(sortedKeys.length - months) : sortedKeys;
      return recentKeys.map((k) => MonthTotal(month: k, totalMinor: map[k]!)).toList();
    });
  }

  @override
  Future<List<domain.Category>> getCategories() async {
    final rows = await (database.select(database.categories)..orderBy([(t) => drift.OrderingTerm.asc(t.sortOrder)])).get();
    return rows.map((c) => domain.Category(id: c.id, key: c.key, colorValue: c.colorValue, sortOrder: c.sortOrder)).toList();
  }

  domain.Receipt _toDomain(db.Receipt r) {
    return domain.Receipt(
      id: r.id,
      merchant: r.merchant,
      purchasedAt: r.purchasedAt,
      totalMinor: r.totalMinor,
      currency: r.currency,
      categoryId: r.categoryId,
      imagePath: r.imagePath,
      rawOcrText: r.rawOcrText,
      parserSource: r.parserSource,
      confidence: r.confidence,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );
  }
}
