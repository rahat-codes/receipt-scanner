import 'dart:io';
import 'package:drift/drift.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/entities/receipt_filter.dart';
import '../../domain/entities/receipt_item.dart';
import '../../domain/interfaces/receipt_repository.dart';
import 'app_database.dart' as db;

class DriftReceiptRepository implements ReceiptRepository {
  final db.AppDatabase _db;

  const DriftReceiptRepository(this._db);

  @override
  Stream<List<Receipt>> watchAll() {
    return (_db.select(_db.receipts)
          ..orderBy([(t) => OrderingTerm.desc(t.purchasedAt), (t) => OrderingTerm.desc(t.id)]))
        .watch()
        .map((rows) => rows.map(_mapReceipt).toList());
  }

  @override
  Future<Receipt?> getById(int id) async {
    final row = await (_db.select(_db.receipts)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row != null ? _mapReceipt(row) : null;
  }

  @override
  Future<int> insert(Receipt receipt) async {
    return _db.into(_db.receipts).insert(_mapCompanion(receipt));
  }

  @override
  Future<void> update(Receipt receipt) async {
    await (_db.update(_db.receipts)..where((t) => t.id.equals(receipt.id))).write(_mapCompanion(receipt));
  }

  @override
  Future<void> delete(int id) async {
    // WHY: Delete associated image file from local storage and ensure atomic cascade deletion of items.
    final receipt = await getById(id);
    if (receipt?.imagePath != null) {
      try {
        final file = File(receipt!.imagePath!);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (_) {}
    }
    await _db.transaction(() async {
      await (_db.delete(_db.receiptItems)..where((t) => t.receiptId.equals(id))).go();
      await (_db.delete(_db.receipts)..where((t) => t.id.equals(id))).go();
    });
  }

  @override
  Stream<List<CategoryTotal>> watchCategoryTotals(DateTime month, String currency) {
    final start = DateTime(month.year, month.month, 1);
    final nextMonth = DateTime(month.year, month.month + 1, 1);

    final query = _db.select(_db.receipts).join([
      innerJoin(_db.categories, _db.categories.id.equalsExp(_db.receipts.categoryId)),
    ])
      ..where(_db.receipts.currency.equals(currency) &
              _db.receipts.purchasedAt.isBiggerOrEqualValue(start) &
              _db.receipts.purchasedAt.isSmallerThanValue(nextMonth));

    return query.watch().map((rows) {
      final map = <int, (String, int, int)>{}; // categoryId -> (key, color, total)
      for (final row in rows) {
        final cat = row.readTable(_db.categories);
        final rec = row.readTable(_db.receipts);
        final entry = map[cat.id] ?? (cat.key, cat.colorValue, 0);
        map[cat.id] = (entry.$1, entry.$2, entry.$3 + rec.totalMinor);
      }
      return map.values.map((v) => CategoryTotal(
            categoryKey: v.$1,
            colorValue: v.$2,
            totalMinor: v.$3,
          )).toList()
        ..sort((a, b) => b.totalMinor.compareTo(a.totalMinor));
    });
  }

  @override
  Stream<List<MonthTotal>> watchMonthlyTotals({required int months, required String currency}) {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - months + 1, 1);

    return (_db.select(_db.receipts)
          ..where((t) => t.currency.equals(currency) & t.purchasedAt.isBiggerOrEqualValue(startDate))
          ..orderBy([(t) => OrderingTerm.asc(t.purchasedAt)]))
        .watch()
        .map((rows) {
      final map = <String, int>{};
      for (final r in rows) {
        final key = '${r.purchasedAt.year}-${r.purchasedAt.month.toString().padLeft(2, '0')}';
        map[key] = (map[key] ?? 0) + r.totalMinor;
      }
      return map.entries.map((e) => MonthTotal(month: e.key, totalMinor: e.value)).toList();
    });
  }

  @override
  Future<List<Category>> getCategories() async {
    final rows = await (_db.select(_db.categories)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();
    return rows.map((r) => Category(id: r.id, key: r.key, colorValue: r.colorValue, sortOrder: r.sortOrder)).toList();
  }

  @override
  Stream<List<Receipt>> watchFiltered(ReceiptFilter filter) {
    var query = _db.select(_db.receipts).join([
      leftOuterJoin(_db.receiptItems, _db.receiptItems.receiptId.equalsExp(_db.receipts.id)),
    ]);

    Expression<bool> condition = const Constant(true);

    if (filter.text != null && filter.text!.isNotEmpty) {
      final pattern = '%${filter.text!}%';
      // WHY: Use isNotNull & like to prevent 3-valued null logic propagation in left joins.
      condition = condition & (_db.receipts.merchant.like(pattern) | (_db.receiptItems.name.isNotNull() & _db.receiptItems.name.like(pattern)));
    }

    if (filter.categoryId != null) {
      condition = condition & _db.receipts.categoryId.equals(filter.categoryId!);
    }

    if (filter.from != null) {
      condition = condition & _db.receipts.purchasedAt.isBiggerOrEqualValue(filter.from!);
    }

    if (filter.to != null) {
      condition = condition & _db.receipts.purchasedAt.isSmallerThanValue(filter.to!);
    }

    query.where(condition);
    query.groupBy([_db.receipts.id]);
    query.orderBy([OrderingTerm.desc(_db.receipts.purchasedAt), OrderingTerm.desc(_db.receipts.id)]);

    return query.watch().map((rows) => rows.map((r) => _mapReceipt(r.readTable(_db.receipts))).toList());
  }

  @override
  Future<List<Receipt>> getMonthReceipts(DateTime month, String currency) async {
    final start = DateTime(month.year, month.month, 1);
    final nextMonth = DateTime(month.year, month.month + 1, 1);
    final rows = await (_db.select(_db.receipts)
          ..where((t) => t.currency.equals(currency) &
                  t.purchasedAt.isBiggerOrEqualValue(start) &
                  t.purchasedAt.isSmallerThanValue(nextMonth))
          ..orderBy([(t) => OrderingTerm.desc(t.purchasedAt)]))
        .get();
    return rows.map(_mapReceipt).toList();
  }

  @override
  Future<List<Receipt>> findPossibleDuplicates(Receipt candidate, {int? excludeId}) async {
    final startOfDay = DateTime(candidate.purchasedAt.year, candidate.purchasedAt.month, candidate.purchasedAt.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    var query = _db.select(_db.receipts)
      ..where((t) => t.totalMinor.equals(candidate.totalMinor) &
              t.purchasedAt.isBiggerOrEqualValue(startOfDay) &
              t.purchasedAt.isSmallerThanValue(endOfDay));

    if (excludeId != null) {
      query.where((t) => t.id.equals(excludeId).not());
    }

    final rows = await query.get();
    return rows.map(_mapReceipt).toList();
  }

  @override
  Future<List<ReceiptItem>> getItems(int receiptId) async {
    final rows = await (_db.select(_db.receiptItems)
          ..where((t) => t.receiptId.equals(receiptId))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
    return rows.map((r) => ReceiptItem(
          id: r.id,
          receiptId: r.receiptId,
          name: r.name,
          quantity: r.quantity,
          unitPriceMinor: r.unitPriceMinor,
          lineTotalMinor: r.lineTotalMinor,
          position: r.position,
        )).toList();
  }

  @override
  Future<void> replaceItems(int receiptId, List<ReceiptItem> items) async {
    // WHY: Atomically replace line items inside a transaction.
    await _db.transaction(() async {
      await (_db.delete(_db.receiptItems)..where((t) => t.receiptId.equals(receiptId))).go();
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        await _db.into(_db.receiptItems).insert(db.ReceiptItemsCompanion.insert(
          receiptId: receiptId,
          name: item.name,
          quantity: Value(item.quantity),
          unitPriceMinor: Value(item.unitPriceMinor),
          lineTotalMinor: item.lineTotalMinor,
          position: Value(i),
        ));
      }
    });
  }

  Receipt _mapReceipt(db.Receipt r) {
    return Receipt(
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

  db.ReceiptsCompanion _mapCompanion(Receipt r) {
    return db.ReceiptsCompanion(
      id: r.id == 0 ? const Value.absent() : Value(r.id),
      merchant: Value(r.merchant),
      purchasedAt: Value(r.purchasedAt),
      totalMinor: Value(r.totalMinor),
      currency: Value(r.currency),
      categoryId: Value(r.categoryId),
      imagePath: Value(r.imagePath),
      rawOcrText: Value(r.rawOcrText),
      parserSource: Value(r.parserSource),
      confidence: Value(r.confidence),
      updatedAt: Value(DateTime.now()),
    );
  }
}
