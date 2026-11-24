import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import '../data/db/app_database.dart';
import '../data/db/drift_receipt_repository.dart';
import '../data/ocr/mlkit_ocr_service.dart';
import '../data/parsing/composite_parser.dart';
import '../data/parsing/llm_parser.dart';
import '../data/parsing/rule_based_parser.dart';
import '../data/settings/settings_store.dart';
import '../domain/interfaces/ocr_service.dart';
import '../domain/interfaces/receipt_parser.dart';
import '../domain/interfaces/receipt_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  // WHY: Use in-memory database for robust testing and instant execution.
  return AppDatabase(NativeDatabase.memory());
});

final ocrServiceProvider = Provider<OcrService>((ref) {
  return MlKitOcrService();
});

final ruleParserProvider = Provider<ReceiptParser>((ref) {
  return RuleBasedParser();
});

final llmParserProvider = Provider<ReceiptParser>((ref) {
  return LlmParser();
});

final settingsStoreProvider = Provider<SettingsStore>((ref) {
  throw UnimplementedError('Initialize settingsStoreProvider in main() via ProviderScope overrides');
});

final parserProvider = Provider<ReceiptParser>((ref) {
  final rules = ref.watch(ruleParserProvider);
  final llm = ref.watch(llmParserProvider);
  final settings = ref.watch(settingsStoreProvider);
  return CompositeParser(
    ruleParser: rules,
    llmParser: llm,
    isLlmEnabled: settings.getGeminiFallback(),
  );
});

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftReceiptRepository(db);
});
