import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/settings_controller.dart';
import '../../l10n/app_localizations.dart';
import '../theme/aurora_background.dart';
import '../theme/frosted_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsControllerProvider);
    final notifier = ref.read(settingsControllerProvider.notifier);

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
                  Text(l10n.language, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  DropdownButton<String>(
                    value: settings.language,
                    dropdownColor: Theme.of(context).cardColor,
                    items: [
                      DropdownMenuItem(value: 'system', child: Text(l10n.system)),
                      DropdownMenuItem(value: 'en', child: Text(l10n.english)),
                      DropdownMenuItem(value: 'ko', child: Text(l10n.korean)),
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
                  Text(l10n.appearance, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  DropdownButton<String>(
                    value: settings.themeMode,
                    dropdownColor: Theme.of(context).cardColor,
                    items: [
                      DropdownMenuItem(value: 'system', child: Text(l10n.system)),
                      DropdownMenuItem(value: 'light', child: Text(l10n.light)),
                      DropdownMenuItem(value: 'dark', child: Text(l10n.dark)),
                    ],
                    onChanged: (val) {
                      if (val != null) notifier.setThemeMode(val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Gemini Fallback Toggle
            FrostedTile(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.aiDoubleCheck, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      Switch(
                        value: settings.geminiFallback,
                        onChanged: (val) => notifier.setGeminiFallback(val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.aiDoubleCheckHelp,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
