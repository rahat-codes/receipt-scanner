# SCHEMA

Local SQLite database managed by **Drift**. No server, no sync, single user.
File: `app.sqlite` in the app's private storage (`drift_flutter` handles the location).

## 1. Design decisions

| Decision | Why |
|---|---|
| Money stored as `INTEGER` minor units (`total_minor`) | Floating point cannot represent decimals exactly. KRW has 0 decimals, USD has 2. A helper converts for display. |
| `currency` stored per receipt (`'KRW'` or `'USD'`) | Mixed-currency receipts exist. Aggregates are computed per currency; the UI shows KRW by default. |
| Categories table with a stable `key`, not a display name | Labels come from the ARB files, so the same row shows "식비" in Korean and "Food" in English. |
| `raw_ocr_text` stored | Lets us re-run an improved parser later and debug wrong extractions. |
| `parser_source` + `confidence` stored | Evaluation and the "AI-assisted" badge. Shows how each record was produced. |
| Image path stored, image file kept in app storage | Keeps the database small. Delete the file when the row is deleted. |
| No `users` table | There is no auth. One device, one user. |

## 2. Entity relationship

```
categories 1 ───< receipts
```

## 3. Drift table definitions

```dart
// lib/data/db/app_database.dart
import 'package:drift/drift.dart';

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

@DriftDatabase(tables: [Categories, Receipts, ReceiptItems, MerchantRules])
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
```

Notes for Gemini:
- Run `dart run build_runner build --delete-conflicting-outputs` after any change to this file.
- Open the database from an **explicit file path** in production (`NativeDatabase.createInBackground(File(p.join((await getApplicationDocumentsDirectory()).path, 'app.sqlite')))`) and `NativeDatabase.memory()` in tests. *Why:* backup and restore (F10) must know exactly which file to snapshot and replace.
- Validate before insert: `totalMinor > 0`, `merchant` trimmed, `currency` in `{'KRW','USD'}`.
- If the table or column set changes after Day 3, increment `schemaVersion` and write a migration. Until then, uninstall the app when changing the schema.

## 4. Categories (labels live in ARB files)

| key | English | Korean |
|---|---|---|
| food | Food and drinks | 식비 |
| groceries | Groceries | 장보기 |
| transport | Transport | 교통 |
| shopping | Shopping | 쇼핑 |
| health | Health | 건강 |
| entertainment | Entertainment | 여가 |
| utilities | Bills and utilities | 공과금 |
| other | Other | 기타 |

ARB key pattern: `category_food`, `category_groceries`, and so on.

Default category suggestion on a new draft: simple keyword rules on the merchant name (`스타벅스`, `카페`, `CAFE` -> food; `GS25`, `CU`, `세븐일레븐`, `마트`, `MART` -> groceries; `택시`, `TAXI`, `버스` -> transport; `약국`, `병원` -> health). Fall back to `other`. The user can always change it.

## 5. Key queries

All aggregates filter by currency (default `'KRW'`). Drift stores `DateTime` as Unix seconds by default.

**Monthly totals, last 6 months** (bar chart):
```sql
SELECT strftime('%Y-%m', purchased_at, 'unixepoch', 'localtime') AS month,
       SUM(total_minor) AS total
FROM receipts
WHERE currency = ?1
  AND purchased_at >= ?2          -- first day of the month, 5 months ago
GROUP BY month
ORDER BY month;
```

**Category share for one month** (donut chart):
```sql
SELECT c.key AS category_key, c.color_value, SUM(r.total_minor) AS total
FROM receipts r
JOIN categories c ON c.id = r.category_id
WHERE r.currency = ?1
  AND r.purchased_at >= ?2        -- month start
  AND r.purchased_at <  ?3        -- next month start
GROUP BY c.id
ORDER BY total DESC;
```

**Home list:** `SELECT ... FROM receipts ORDER BY purchased_at DESC, id DESC`, exposed as a Drift `watch()` stream so the UI updates automatically.

**This month's total:** same as the category query without the join and grouping.

Implement these with `customSelect` and `readsFrom: {receipts, categories}` so they work with streams, then map rows into small result classes in `domain/`.

## 6. Domain entity mapping

`Receipt` (domain) mirrors the table minus Drift types: `id`, `merchant`, `purchasedAt`, `totalMinor`, `currency`, `categoryId`, `imagePath`, `rawOcrText`, `parserSource`, `confidence`.
The repository converts between Drift rows and domain entities so that the rest of the app never imports Drift.

## 7. Repository contract

```dart
abstract class ReceiptRepository {
  Stream<List<Receipt>> watchAll();
  Future<Receipt?> getById(int id);
  Future<int> insert(Receipt receipt);       // returns new id
  Future<void> update(Receipt receipt);
  Future<void> delete(int id);               // also deletes the image file
  Stream<List<CategoryTotal>> watchCategoryTotals(DateTime month, String currency);
  Stream<List<MonthTotal>> watchMonthlyTotals({required int months, required String currency});
  Future<List<Category>> getCategories();

  // v2
  Stream<List<Receipt>> watchFiltered(ReceiptFilter filter);              // F2
  Future<List<Receipt>> getMonthReceipts(DateTime month, String currency); // F3, F6, F7 (merchant grouping is done in Dart)
  Future<List<Receipt>> findPossibleDuplicates(Receipt candidate, {int? excludeId}); // F4
  Future<List<ReceiptItem>> getItems(int receiptId);                      // F9
  Future<void> replaceItems(int receiptId, List<ReceiptItem> items);      // F9, run inside a transaction
}

class ReceiptFilter {
  final String? text;            // merchant or item name
  final int? categoryId;
  final DateTime? from;          // inclusive
  final DateTime? to;            // exclusive
  const ReceiptFilter({this.text, this.categoryId, this.from, this.to});
  bool get isEmpty => text == null && categoryId == null && from == null && to == null;
}

abstract class MerchantRuleRepository {                                   // F5
  Future<int?> categoryFor(String merchantKey);
  Future<void> upsert(String merchantKey, int categoryId);               // same category: hitCount + 1; different: replace, hitCount = 1
}
```

## 8. Extended tables and queries (v2)

All four tables are created at **schema version 1**, because the full scope is decided on Day 1. Changing tables later costs a migration, so decide now.

### 8.1 Foreign keys must be switched on

SQLite ignores foreign keys unless asked. Add to the `MigrationStrategy`:
```dart
beforeOpen: (details) async {
  await customStatement('PRAGMA foreign_keys = ON');   // needed for ON DELETE CASCADE on receipt_items
},
```

### 8.2 Design decisions

| Decision | Why |
|---|---|
| `receipt_items.line_total_minor` is required, `unit_price_minor` and `quantity` are optional | Many receipts show only a line amount. Line total is the value we can always verify against the receipt total. |
| `ON DELETE CASCADE` on `receipt_items` | Deleting a receipt must never leave orphan items. |
| `merchant_rules` is keyed by a **normalized** merchant key, not the raw name | "GS25 대연점" and "GS25 광안점" should share one learned category. |
| One rule per merchant key (latest choice wins) | Simple and explainable. Majority voting is possible later. |
| Top merchants are grouped **in Dart**, not in SQL | Normalization (removing branch suffixes) is Dart logic and is unit-tested there. A month has few rows, so fetching them is cheap. |
| Index on `(purchased_at, total_minor)` | Makes the duplicate lookup fast. |

### 8.3 Queries

**Search and filter** (F2). Escape `%` and `_` in the user's text before binding it to the `LIKE`:
```sql
SELECT r.*
FROM receipts r
WHERE (?1 IS NULL OR r.merchant LIKE '%' || ?1 || '%' ESCAPE '\'
       OR EXISTS (SELECT 1 FROM receipt_items i
                  WHERE i.receipt_id = r.id AND i.name LIKE '%' || ?1 || '%' ESCAPE '\'))
  AND (?2 IS NULL OR r.category_id = ?2)
  AND (?3 IS NULL OR r.purchased_at >= ?3)
  AND (?4 IS NULL OR r.purchased_at <  ?4)
ORDER BY r.purchased_at DESC, r.id DESC;
```

**Possible duplicates** (F4): fetch rows with the same currency and total on the same calendar day, then compare normalized merchant keys in Dart.
```sql
SELECT * FROM receipts
WHERE currency = ?1
  AND total_minor = ?2
  AND purchased_at >= ?3          -- start of that day
  AND purchased_at <  ?4          -- start of next day
  AND (?5 IS NULL OR id != ?5);   -- exclude the receipt being edited
```

**Month receipts** (F3, F6, F7): `SELECT * FROM receipts WHERE currency = ?1 AND purchased_at >= ?2 AND purchased_at < ?3` then group in Dart.

**Items of a receipt** (F9): `SELECT * FROM receipt_items WHERE receipt_id = ?1 ORDER BY position`.

### 8.4 Backup relevance

The backup (F10) contains: a consistent snapshot of `app.sqlite` made with `VACUUM INTO`, the `receipts/` image folder, and a `manifest.json` with `schemaVersion`. See `docs/ARCHITECTURE.md` section 12.8.
