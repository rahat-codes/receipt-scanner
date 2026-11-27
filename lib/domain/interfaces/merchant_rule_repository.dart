abstract class MerchantRuleRepository {
  Future<int?> categoryFor(String merchantKey);
  Future<void> upsert(String merchantKey, int categoryId);
}
