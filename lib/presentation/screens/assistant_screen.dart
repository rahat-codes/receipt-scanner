import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/assistant_controller.dart';
import '../../application/settings_controller.dart';
import '../../l10n/app_localizations.dart';
import '../theme/aurora_background.dart';
import '../theme/frosted_tile.dart';
import '../theme/glass_panel.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkConsentAndPrompt());
  }

  Future<void> _checkConsentAndPrompt() async {
    final settings = ref.read(settingsControllerProvider);
    if (!settings.aiConsent) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final agreed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.consentTitle),
          content: SingleChildScrollView(
            child: Text(l10n.consentBody),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.notNow),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.agreeAndContinue),
            ),
          ],
        ),
      );

      if (agreed == true) {
        await ref.read(settingsControllerProvider.notifier).setAiConsent(true);
        await ref.read(settingsControllerProvider.notifier).setAiAssistantEnabled(true);
      } else {
        if (!mounted) return;
        Navigator.pop(context);
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSend([String? rawText]) {
    final text = (rawText ?? _controller.text).trim();
    final assistantState = ref.read(assistantControllerProvider);
    if (text.isEmpty || assistantState.isLoading) return;

    _controller.clear();
    ref.read(assistantControllerProvider.notifier).sendMessage(text);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final assistantState = ref.watch(assistantControllerProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final currentLocale = Localizations.localeOf(context).languageCode;

    ref.listen(assistantControllerProvider, (prev, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });

    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.aiAssistantSetting),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: l10n.clearChat,
              onPressed: () => ref.read(assistantControllerProvider.notifier).clearChat(),
            ),
          ],
        ),
        body: Column(
          children: [
            // Quick chips & suggestion chips
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ActionChip(
                    label: Text(l10n.chipThisMonthTotal),
                    onPressed: () => ref.read(assistantControllerProvider.notifier).answerQuickChip('this_month_total', 'KRW', currentLocale),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    label: Text(l10n.chipTopCategory),
                    onPressed: () => ref.read(assistantControllerProvider.notifier).answerQuickChip('top_category', 'KRW', currentLocale),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    label: Text(l10n.chipQ1),
                    onPressed: assistantState.isLoading ? null : () => _handleSend(l10n.chipQ1),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    label: Text(l10n.chipQ3),
                    onPressed: assistantState.isLoading ? null : () => _handleSend(l10n.chipQ3),
                  ),
                ],
              ),
            ),
            Expanded(
              child: assistantState.messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          l10n.askAssistantHint,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: onSurface.withValues(alpha: 0.60)),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: assistantState.messages.length,
                      itemBuilder: (context, index) {
                        final msg = assistantState.messages[index];
                        return Align(
                          alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                            child: FrostedTile(
                              radius: 16,
                              child: Text(
                                msg.text,
                                style: TextStyle(
                                  color: msg.isUser ? onSurface : onSurface,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (assistantState.isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: LinearProgressIndicator(),
              ),
            if (assistantState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  assistantState.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                l10n.disclaimer,
                style: TextStyle(fontSize: 11, color: onSurface.withValues(alpha: 0.50)),
              ),
            ),
            GlassPanel(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: l10n.askAssistantHint,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onSubmitted: (val) => _handleSend(val),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_rounded),
                      onPressed: assistantState.isLoading ? null : () => _handleSend(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
