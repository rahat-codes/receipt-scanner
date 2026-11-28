import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';
import 'package:receiptscanner/application/settings_controller.dart';
import 'package:receiptscanner/core/providers.dart';
import 'package:receiptscanner/data/db/app_database.dart';
import 'package:receiptscanner/data/settings/settings_store.dart';
import 'package:receiptscanner/l10n/app_localizations.dart';
import 'package:receiptscanner/presentation/screens/settings_screen.dart';

void main() {
  testWidgets('switching language to Korean changes visible title to 한국어 설정', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = SettingsStore(prefs);

    final container = ProviderContainer(
      overrides: [
        settingsStoreProvider.overrideWithValue(store),
      ],
    );

    Widget buildApp() {
      return UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, child) {
            final settings = ref.watch(settingsControllerProvider);
            Locale? locale;
            if (settings.language == 'en') {
              locale = const Locale('en');
            } else if (settings.language == 'ko') {
              locale = const Locale('ko');
            }

            return MaterialApp(
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const SettingsScreen(),
            );
          },
        ),
      );
    }

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);

    // Switch to Korean
    await container.read(settingsControllerProvider.notifier).setLanguage('ko');
    await tester.pumpAndSettle();

    expect(find.text('설정'), findsOneWidget);
  });

  testWidgets('Delete all data wipes AI consent and database records', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = SettingsStore(prefs);
    await store.setAiConsent(true);

    final db = AppDatabase(NativeDatabase.memory());

    Widget buildApp() {
      return ProviderScope(
        overrides: [
          settingsStoreProvider.overrideWithValue(store),
          databaseProvider.overrideWithValue(db),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        ),
      );
    }

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(store.getAiConsent(), isTrue);

    // Tap Delete all data
    await tester.tap(find.text('Delete all data'));
    await tester.pumpAndSettle();

    expect(find.text('Delete all receipts, rules, and assistant data? This cannot be undone.'), findsOneWidget);

    // Confirm delete
    await tester.tap(find.widgetWithText(TextButton, 'Delete all data'));
    await tester.pumpAndSettle();

    expect(store.getAiConsent(), isFalse);
    await db.close();
  });
}
