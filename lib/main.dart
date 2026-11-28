import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'application/settings_controller.dart';
import 'core/providers.dart';
import 'data/db/app_database.dart';
import 'data/settings/settings_store.dart';
import 'presentation/screens/receipts_screen.dart';
import 'presentation/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // WHY: Intercept Flutter framework UI rendering errors with a friendly error screen.
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
    };

    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        color: const Color(0xFF0F1B2D),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.error_outline_rounded, color: Colors.amber, size: 48),
                SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Please restart the application.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    };

    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {}

    SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {
      rethrow;
    }

    final settingsStore = SettingsStore(prefs);

    AppDatabase database;
    try {
      final dbDir = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbDir.path, 'app.sqlite'));
      database = AppDatabase(NativeDatabase(dbFile));
    } catch (_) {
      database = AppDatabase(NativeDatabase.memory());
    }

    runApp(
      ProviderScope(
        overrides: [
          settingsStoreProvider.overrideWithValue(settingsStore),
          databaseProvider.overrideWithValue(database),
        ],
        child: const ReceiptScannerApp(),
      ),
    );
  }, (error, stack) {
    // WHY: Catch uncaught async errors safely without exposing user receipt data.
  });
}

class ReceiptScannerApp extends ConsumerWidget {
  const ReceiptScannerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);

    ThemeMode mode;
    switch (settings.themeMode) {
      case 'light':
        mode = ThemeMode.light;
        break;
      case 'dark':
        mode = ThemeMode.dark;
        break;
      case 'system':
      default:
        mode = ThemeMode.system;
        break;
    }

    Locale? locale;
    if (settings.language == 'en') {
      locale = const Locale('en');
    } else if (settings.language == 'ko') {
      locale = const Locale('ko');
    }

    return MaterialApp(
      title: 'Receipt Scanner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: mode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ReceiptsScreen(),
    );
  }
}
