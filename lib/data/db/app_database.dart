import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().unique()();          // 'food', 'groceries', ...
  IntColumn get colorValue => integer()();          // ARGB int for charts
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@TableIndex(name: 'idx_receipts_purchased_at', columns: {#purchasedAt})
@TableIndex(name: 'idx_receipts_category', columns: {#categoryId})
@TableIndex(name: 'idx_receipts_dupe', columns: {#purchasedAt, #totalMinor})
class Receipts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get merchant => text().withDefault(const Constant(''))();
  DateTimeColumn get purchasedAt => dateTime()();
  IntColumn get totalMinor => integer()();                       // > 0
  TextColumn get currency =>
      text().withLength(min: 3, max: 3).withDefault(const Constant('KRW'))();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get imagePath => text().nullable()();
  TextColumn get rawOcrText => text().withDefault(const Constant(''))();
  TextColumn get parserSource =>
      text().withDefault(const Constant('rules'))();             // rules | llm | manual
  RealColumn get confidence => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// v2: line items (F9)
@TableIndex(name: 'idx_items_receipt', columns: {#receiptId})
class ReceiptItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get receiptId =>
      integer().references(Receipts, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  IntColumn get unitPriceMinor => integer().nullable()();
  IntColumn get lineTotalMinor => integer()();
  IntColumn get position => integer().withDefault(const Constant(0))();   // keeps receipt order
}

// v2: learn from corrections (F5)
class MerchantRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get merchantKey => text().unique()();      // normalized merchant, see ARCHITECTURE 12.3
  IntColumn get categoryId => integer().references(Categories, #id)();
  IntColumn get hitCount => integer().withDefault(const Constant(1))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// v3: tip notifications & history (F13)
class AssistantTips extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kind => text()();                      // 'rule' | 'ai' | 'evergreen'
  TextColumn get ruleKey => text().nullable()();        // null for AI tips
  TextColumn get title => text()();
  TextColumn get body => text()();
  DateTimeColumn get scheduledAt => dateTime().nullable()();
  DateTimeColumn get readAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(tables: [Categories, Receipts, ReceiptItems, MerchantRules, AssistantTips])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await m.createAll();
          await _seedCategories();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');   // needed for ON DELETE CASCADE on receipt_items
        },
      );

  Future<void> _seedCategories() async {
    const seed = <(String, int)>[
      ('food',          0xFFF97316),
      ('groceries',     0xFF22C55E),
      ('transport',     0xFF3B82F6),
      ('shopping',      0xFFA855F7),
      ('health',        0xFFEF4444),
      ('entertainment', 0xFFEC4899),
      ('utilities',     0xFF14B8A6),
      ('other',         0xFF94A3B8),
    ];
    for (var i = 0; i < seed.length; i++) {
      await into(categories).insert(CategoriesCompanion.insert(
        key: seed[i].$1,
        colorValue: seed[i].$2,
        sortOrder: Value(i),
      ));
    }
  }
}
