import 'package:drift/drift.dart';

part 'app_database.g.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().unique()(); // 'food', 'groceries', ...
  IntColumn get colorValue => integer()(); // ARGB int for charts
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@TableIndex(name: 'idx_receipts_purchased_at', columns: {#purchasedAt})
@TableIndex(name: 'idx_receipts_category', columns: {#categoryId})
class Receipts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get merchant => text().withDefault(const Constant(''))();
  DateTimeColumn get purchasedAt => dateTime()();
  IntColumn get totalMinor => integer()(); // > 0
  TextColumn get currency => text().withLength(min: 3, max: 3).withDefault(const Constant('KRW'))();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get imagePath => text().nullable()();
  TextColumn get rawOcrText => text().withDefault(const Constant(''))();
  TextColumn get parserSource => text().withDefault(const Constant('rules'))(); // rules | llm | manual
  RealColumn get confidence => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Categories, Receipts])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedCategories();
        },
      );

  Future<void> _seedCategories() async {
    const seed = <(String, int)>[
      ('food', 0xFFF97316),
      ('groceries', 0xFF22C55E),
      ('transport', 0xFF3B82F6),
      ('shopping', 0xFFA855F7),
      ('health', 0xFFEF4444),
      ('entertainment', 0xFFEC4899),
      ('utilities', 0xFF14B8A6),
      ('other', 0xFF94A3B8),
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
