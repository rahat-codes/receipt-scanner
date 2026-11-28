import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../application/settings_controller.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/aurora_background.dart';
import '../theme/frosted_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const String appVersion = '1.0.0+1';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsControllerProvider);
    final notifier = ref.read(settingsControllerProvider.notifier);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.settingsTitle),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Language
            FrostedTile(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.language, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: onSurface)),
                  DropdownButton<String>(
                    key: const Key('language_dropdown'),
                    value: settings.language,
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: onSurface),
                    underline: const SizedBox.shrink(),
                    icon: Icon(Icons.arrow_drop_down, color: onSurface),
                    items: [
                      DropdownMenuItem(value: 'system', child: Text(l10n.system, style: TextStyle(color: onSurface))),
                      DropdownMenuItem(value: 'en', child: Text(l10n.english, style: TextStyle(color: onSurface))),
                      DropdownMenuItem(value: 'ko', child: Text(l10n.korean, style: TextStyle(color: onSurface))),
                    ],
                    onChanged: (val) {
                      if (val != null) notifier.setLanguage(val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Theme Mode
            FrostedTile(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.appearance, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: onSurface)),
                  DropdownButton<String>(
                    key: const Key('theme_dropdown'),
                    value: settings.themeMode,
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: onSurface),
                    underline: const SizedBox.shrink(),
                    icon: Icon(Icons.arrow_drop_down, color: onSurface),
                    items: [
                      DropdownMenuItem(value: 'system', child: Text(l10n.system, style: TextStyle(color: onSurface))),
                      DropdownMenuItem(value: 'light', child: Text(l10n.light, style: TextStyle(color: onSurface))),
                      DropdownMenuItem(value: 'dark', child: Text(l10n.dark, style: TextStyle(color: onSurface))),
                    ],
                    onChanged: (val) {
                      if (val != null) notifier.setThemeMode(val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Privacy Tile
            FrostedTile(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield_outlined, size: 20, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(l10n.privacy, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: onSurface)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.privacyDetail,
                    style: TextStyle(fontSize: 13, color: onSurface.withValues(alpha: 0.70)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Delete All Data Tile
            FrostedTile(
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(l10n.deleteAllData),
                    content: Text(l10n.deleteAllDataConfirm),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(l10n.deleteAllData, style: const TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  final db = ref.read(databaseProvider);
                  await db.transaction(() async {
                    await db.delete(db.receiptItems).go();
                    await db.delete(db.receipts).go();
                    await db.delete(db.merchantRules).go();
                    await db.delete(db.assistantTips).go();
                  });

                  await notifier.setAiConsent(false);
                  await notifier.setAiAssistantEnabled(false);

                  try {
                    final appDir = await getApplicationDocumentsDirectory();
                    final receiptsDir = Directory(p.join(appDir.path, 'receipts'));
                    if (receiptsDir.existsSync()) {
                      receiptsDir.deleteSync(recursive: true);
                    }
                  } catch (_) {}

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.allDataDeleted)),
                  );
                }
              },
              child: Row(
                children: [
                  const Icon(Icons.delete_forever_outlined, color: AppColors.error),
                  const SizedBox(width: 12),
                  Text(l10n.deleteAllData, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.error)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // About & Licenses
            FrostedTile(
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: l10n.appTitle,
                  applicationVersion: appVersion,
                );
              },
              child: Row(
                children: [
                  Image.asset(
                    'assets/branding/logo_rounded.png',
                    width: 36,
                    height: 36,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.appTitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: onSurface)),
                        const SizedBox(height: 2),
                        Text('Version $appVersion', style: TextStyle(fontSize: 13, color: onSurface.withValues(alpha: 0.60))),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: onSurface),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
