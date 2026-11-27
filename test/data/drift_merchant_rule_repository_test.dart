import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:receiptscanner/data/db/app_database.dart';
import 'package:receiptscanner/data/db/drift_merchant_rule_repository.dart';

void main() {
  late AppDatabase db;
  late DriftMerchantRuleRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftMerchantRuleRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('merchant rule upsert semantics: same category increments hitCount, different category resets hitCount to 1', () async {
    final categories = await db.select(db.categories).get();
    final cat1 = categories[0].id;
    final cat2 = categories[1].id;

    const merchantKey = 'starbucks';

    // Insert new rule
    await repo.upsert(merchantKey, cat1);
    expect(await repo.categoryFor(merchantKey), cat1);

    // Same category -> hitCount increments (tested via internal table query)
    await repo.upsert(merchantKey, cat1);
    expect(await repo.categoryFor(merchantKey), cat1);
    var rule = await (db.select(db.merchantRules)..where((t) => t.merchantKey.equals(merchantKey))).getSingle();
    expect(rule.hitCount, 2);

    // Different category -> replaces category and resets hitCount to 1
    await repo.upsert(merchantKey, cat2);
    expect(await repo.categoryFor(merchantKey), cat2);
    rule = await (db.select(db.merchantRules)..where((t) => t.merchantKey.equals(merchantKey))).getSingle();
    expect(rule.hitCount, 1);
  });
}
