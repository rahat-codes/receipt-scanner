import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/db/app_database.dart';
import '../data/db/drift_merchant_rule_repository.dart';
import '../data/db/drift_receipt_repository.dart';
import '../data/ocr/mlkit_ocr_service.dart';
import '../data/parsing/rule_based_parser.dart';
import '../data/settings/settings_store.dart';
import '../data/assistant/gemini_assistant_service.dart';
import '../domain/interfaces/merchant_rule_repository.dart';
import '../domain/interfaces/ocr_service.dart';
import '../domain/interfaces/receipt_parser.dart';
import '../domain/interfaces/receipt_repository.dart';
import '../domain/interfaces/assistant_service.dart';
import '../domain/logic/expense_tools.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  // WHY: Default to open AppDatabase using explicit path NativeDatabase(file).
  return AppDatabase();
});

final ocrServiceProvider = Provider<OcrService>((ref) {
  return MlKitOcrService();
});

final ruleParserProvider = Provider<ReceiptParser>((ref) {
  return RuleBasedParser();
});

final settingsStoreProvider = Provider<SettingsStore>((ref) {
  throw UnimplementedError('Initialize settingsStoreProvider in main() via ProviderScope overrides');
});

final parserProvider = Provider<ReceiptParser>((ref) {
  return RuleBasedParser();
});

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftReceiptRepository(db);
});

final merchantRuleRepositoryProvider = Provider<MerchantRuleRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftMerchantRuleRepository(db);
});

final assistantServiceProvider = Provider<AssistantService>((ref) {
  final repo = ref.watch(receiptRepositoryProvider);
  final expenseTools = ExpenseTools(repo);
  return GeminiAssistantService(expenseTools: expenseTools);
});
