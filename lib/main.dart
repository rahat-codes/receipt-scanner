import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'core/providers.dart';
import 'data/db/app_database.dart';
import 'data/settings/settings_store.dart';
import 'presentation/screens/receipts_screen.dart';
import 'presentation/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // If .env is missing or cannot be loaded, continue with defaults.
  }

  final prefs = await SharedPreferences.getInstance();
  final settingsStore = SettingsStore(prefs);

  // WHY: Open database from an explicit file path for production persistence and backup support.
  final dbDir = await getApplicationDocumentsDirectory();
  final dbFile = File(p.join(dbDir.path, 'app.sqlite'));
  final database = AppDatabase(NativeDatabase.createInBackground(dbFile));

  runApp(
    ProviderScope(
      overrides: [
        settingsStoreProvider.overrideWithValue(settingsStore),
        databaseProvider.overrideWithValue(database),
      ],
      child: const ReceiptScannerApp(),
    ),
  );
}

class ReceiptScannerApp extends ConsumerWidget {
  const ReceiptScannerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Receipt Scanner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ReceiptsScreen(),
    );
  }
}
