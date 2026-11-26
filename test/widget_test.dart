import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';
import 'package:receiptscanner/main.dart';
import 'package:receiptscanner/core/providers.dart';
import 'package:receiptscanner/data/db/app_database.dart';
import 'package:receiptscanner/data/settings/settings_store.dart';

void main() {
  testWidgets('ReceiptScannerApp loads correctly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsStore = SettingsStore(prefs);
    final db = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsStoreProvider.overrideWithValue(settingsStore),
          databaseProvider.overrideWithValue(db),
        ],
        child: const ReceiptScannerApp(),
      ),
    );

    expect(find.text('Receipts'), findsOneWidget);

    await db.close();
  });
}
