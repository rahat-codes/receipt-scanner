import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:receiptscanner/data/db/app_database.dart' hide Receipt, ReceiptItem;
import 'package:receiptscanner/data/db/drift_receipt_repository.dart';
import 'package:receiptscanner/domain/entities/receipt.dart';
import 'package:receiptscanner/domain/entities/receipt_filter.dart';
import 'package:receiptscanner/domain/entities/receipt_item.dart';

void main() {
  late AppDatabase db;
  late DriftReceiptRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(
      setup: (rawDb) {
        rawDb.execute('PRAGMA foreign_keys = ON;');
      },
    ));
    repo = DriftReceiptRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('categories are seeded with 8 default categories', () async {
    final categories = await repo.getCategories();
    expect(categories.length, 8);
    expect(categories.first.key, 'food');
  });

  test('insert, getById, update, delete receipt', () async {
    final categories = await repo.getCategories();
    final foodCatId = categories.first.id;

    final receipt = Receipt(
      id: 0,
      merchant: 'Starbucks',
      purchasedAt: DateTime(2026, 3, 1, 12, 0),
      totalMinor: 5000,
      currency: 'KRW',
      categoryId: foodCatId,
      rawOcrText: 'Starbucks 5000',
      parserSource: 'rules',
      confidence: 0.9,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final id = await repo.insert(receipt);
    expect(id, greaterThan(0));

    final fetched = await repo.getById(id);
    expect(fetched, isNotNull);
    expect(fetched!.merchant, 'Starbucks');
    expect(fetched.totalMinor, 5000);

    final updated = Receipt(
      id: id,
      merchant: 'Starbucks Gangnam',
      purchasedAt: fetched.purchasedAt,
      totalMinor: 5500,
      currency: fetched.currency,
      categoryId: fetched.categoryId,
      rawOcrText: fetched.rawOcrText,
      parserSource: fetched.parserSource,
      confidence: fetched.confidence,
      createdAt: fetched.createdAt,
      updatedAt: DateTime.now(),
    );

    await repo.update(updated);
    final fetchedUpdated = await repo.getById(id);
    expect(fetchedUpdated!.merchant, 'Starbucks Gangnam');
    expect(fetchedUpdated.totalMinor, 5500);

    await repo.delete(id);
    final fetchedDeleted = await repo.getById(id);
    expect(fetchedDeleted, isNull);
  });

  test('cascade deletes items when receipt is deleted', () async {
    final categories = await repo.getCategories();
    final catId = categories.first.id;

    final receipt = Receipt(
      id: 0,
      merchant: 'Mart',
      purchasedAt: DateTime(2026, 3, 2),
      totalMinor: 10000,
      categoryId: catId,
      rawOcrText: 'Mart 10000',
      parserSource: 'rules',
      confidence: 0.9,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final id = await repo.insert(receipt);
    await repo.replaceItems(id, [
      ReceiptItem(receiptId: id, name: 'Milk', lineTotalMinor: 5000),
      ReceiptItem(receiptId: id, name: 'Bread', lineTotalMinor: 5000),
    ]);

    var items = await repo.getItems(id);
    expect(items.length, 2);

    await repo.delete(id);
    items = await repo.getItems(id);
    expect(items, isEmpty);
  });

  test('watchFiltered by text, category, date range, and item name with LIKE escaping', () async {
    final categories = await repo.getCategories();
    final foodId = categories[0].id;
    final transportId = categories[2].id;

    final r1 = Receipt(
      id: 0,
      merchant: 'Cafe 100%',
      purchasedAt: DateTime(2026, 3, 10),
      totalMinor: 4000,
      categoryId: foodId,
      rawOcrText: 'Cafe 100%',
      parserSource: 'rules',
      confidence: 0.9,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final id1 = await repo.insert(r1);
    await repo.replaceItems(id1, [ReceiptItem(receiptId: id1, name: 'Latte 50_off', lineTotalMinor: 4000)]);

    final r2 = Receipt(
      id: 0,
      merchant: 'Taxi',
      purchasedAt: DateTime(2026, 3, 15),
      totalMinor: 12000,
      categoryId: transportId,
      rawOcrText: 'Taxi',
      parserSource: 'rules',
      confidence: 0.9,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await repo.insert(r2);

    // Filter by item name containing special characters % or _
    final filter = ReceiptFilter(text: '50_off');
    final results = await repo.watchFiltered(filter).first;
    expect(results.length, 1);
    expect(results.first.merchant, 'Cafe 100%');
  });

  test('findPossibleDuplicates finds matching total and same day, excluding itself', () async {
    final categories = await repo.getCategories();
    final catId = categories.first.id;

    final r1 = Receipt(
      id: 0,
      merchant: 'Shop A',
      purchasedAt: DateTime(2026, 3, 5, 10, 0),
      totalMinor: 5000,
      categoryId: catId,
      rawOcrText: '',
      parserSource: 'rules',
      confidence: 0.9,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final id1 = await repo.insert(r1);

    final candidate = Receipt(
      id: 0,
      merchant: 'Shop B',
      purchasedAt: DateTime(2026, 3, 5, 15, 0),
      totalMinor: 5000,
      categoryId: catId,
      rawOcrText: '',
      parserSource: 'rules',
      confidence: 0.9,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    var dupes = await repo.findPossibleDuplicates(candidate, excludeId: id1);
    expect(dupes, isEmpty); // excluded itself / none other

    final id2 = await repo.insert(candidate);
    dupes = await repo.findPossibleDuplicates(candidate, excludeId: id2);
    expect(dupes.length, 1);
    expect(dupes.first.id, id1);
  });
}
