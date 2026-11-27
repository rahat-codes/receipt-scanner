import 'package:drift/drift.dart';
import '../../domain/interfaces/merchant_rule_repository.dart';
import 'app_database.dart';

class DriftMerchantRuleRepository implements MerchantRuleRepository {
  final AppDatabase _db;

  const DriftMerchantRuleRepository(this._db);

  @override
  Future<int?> categoryFor(String merchantKey) async {
    final row = await (_db.select(_db.merchantRules)..where((t) => t.merchantKey.equals(merchantKey))).getSingleOrNull();
    return row?.categoryId;
  }

  @override
  Future<void> upsert(String merchantKey, int categoryId) async {
    // WHY: Same category increments hitCount; different category replaces category and resets hitCount to 1.
    final existing = await (_db.select(_db.merchantRules)..where((t) => t.merchantKey.equals(merchantKey))).getSingleOrNull();
    if (existing != null) {
      if (existing.categoryId == categoryId) {
        await (_db.update(_db.merchantRules)..where((t) => t.id.equals(existing.id))).write(
          MerchantRulesCompanion(
            hitCount: Value(existing.hitCount + 1),
            updatedAt: Value(DateTime.now()),
          ),
        );
      } else {
        await (_db.update(_db.merchantRules)..where((t) => t.id.equals(existing.id))).write(
          MerchantRulesCompanion(
            categoryId: Value(categoryId),
            hitCount: const Value(1),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    } else {
      await _db.into(_db.merchantRules).insert(
            MerchantRulesCompanion.insert(
              merchantKey: merchantKey,
              categoryId: categoryId,
              hitCount: const Value(1),
            ),
          );
    }
  }
}
