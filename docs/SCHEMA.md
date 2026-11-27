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
| `assistant_tips` stored locally (schemaVersion 1) | Remembers scheduled and historical tips; auto-cleans old entries to keep at most 50 rows. All tables created at version 1. |
| No `users` table | There is no auth. One device, one user. |

## 2. Entity relationship

```
categories 1 ───< receipts
receipts   1 ───< receipt_items
assistant_tips
merchant_rules
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

@DriftDatabase(tables: [Categories, Receipts, ReceiptItems, MerchantRules, AssistantTips])
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
```

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

## 6. Domain entity mapping

`Receipt` (domain) mirrors the table minus Drift types: `id`, `merchant`, `purchasedAt`, `totalMinor`, `currency`, `categoryId`, `imagePath`, `rawOcrText`, `parserSource`, `confidence`.
`AssistantTip` (domain) mirrors the table: `id`, `kind`, `ruleKey`, `title`, `body`, `scheduledAt`, `readAt`, `createdAt`.

The repository converts between Drift rows and domain entities so that the rest of the app never imports Drift.

## 7. Repository contracts

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
  Future<List<Receipt>> getMonthReceipts(DateTime month, String currency); // F3, F6, F7
  Future<List<Receipt>> findPossibleDuplicates(Receipt candidate, {int? excludeId}); // F4
  Future<List<ReceiptItem>> getItems(int receiptId);                      // F9
  Future<void> replaceItems(int receiptId, List<ReceiptItem> items);      // F9
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
  Future<void> upsert(String merchantKey, int categoryId);
}

abstract class TipRepository {                                            // F13
  Future<List<AssistantTip>> getTips({int limit = 50});
  Future<void> insertTip(AssistantTip tip);
  Future<void> markAsRead(int tipId);
  Future<List<String>> getRecentTipKeys({int count = 20});
}
```

## 8. Extended tables and queries (v2 & v3)

All five tables (`Categories`, `Receipts`, `ReceiptItems`, `MerchantRules`, `AssistantTips`) are created at **schemaVersion 1**, because the full scope is decided on Day 1. No migration is needed for v2 or v3.

### 8.1 Foreign keys must be switched on

SQLite ignores foreign keys unless asked. Add to `MigrationStrategy`:
```dart
beforeOpen: (details) async {
  await customStatement('PRAGMA foreign_keys = ON');   // needed for ON DELETE CASCADE on receipt_items
},
```

### 8.2 Tip Retention Query
When inserting new tips, keep at most the 50 most recent entries:
```sql
DELETE FROM assistant_tips
WHERE id NOT IN (
  SELECT id FROM assistant_tips ORDER BY created_at DESC LIMIT 50
);
```

### 8.3 Backup Relevance
The backup file (`F10`) snapshots `app.sqlite` using `VACUUM INTO`, capturing all tables (`receipts`, `receipt_items`, `categories`, `merchant_rules`, and `assistant_tips`) at `schemaVersion 1`. Restore verifies `manifest.schemaVersion == 1` and runs `PRAGMA integrity_check`.
