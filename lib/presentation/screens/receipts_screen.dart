import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../application/receipts_controller.dart';
import '../../application/scan_controller.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/money.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/aurora_background.dart';
import '../theme/frosted_tile.dart';
import '../theme/glass_panel.dart';
import '../theme/perforated_slip.dart';
import 'detail_screen.dart';
import 'review_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

class ReceiptsScreen extends ConsumerStatefulWidget {
  const ReceiptsScreen({super.key});

  @override
  ConsumerState<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends ConsumerState<ReceiptsScreen> {
  final ImagePicker _picker = ImagePicker();

  void _showScanBottomSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GlassPanel(
        strong: true,
        radius: 28,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt_rounded, color: Theme.of(context).colorScheme.primary),
                title: Text(l10n.takePhoto, style: const TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_rounded, color: Theme.of(context).colorScheme.primary),
                title: Text(l10n.chooseFromGallery, style: const TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final photo = await _picker.pickImage(source: source);
      if (photo == null) return; // cancelled picker

      final appDir = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory(p.join(appDir.path, 'receipts'));
      if (!receiptsDir.existsSync()) {
        receiptsDir.createSync(recursive: true);
      }
      final fileName = '${DateTime.now().millisecondsSinceEpoch}${p.extension(photo.path)}';
      final savedPath = p.join(receiptsDir.path, fileName);
      await File(photo.path).copy(savedPath);

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _ProcessingDialog(
          onCancel: () {
            ref.read(scanControllerProvider.notifier).reset();
            Navigator.pop(context);
          },
        ),
      );

      await ref.read(scanControllerProvider.notifier).processImage(savedPath);

      if (!mounted) return;
      Navigator.pop(context); // close dialog

      final scanState = ref.read(scanControllerProvider);
      if (scanState.status == ScanStateStatus.ready && scanState.parsed != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReviewScreen(
              parsed: scanState.parsed!,
              imagePath: savedPath,
            ),
          ),
        );
      } else if (scanState.status == ScanStateStatus.failed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(scanState.errorMessage ?? 'Failed to process receipt')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.permissionCamera),
          action: SnackBarAction(
            label: l10n.openSettings,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final receiptsAsync = ref.watch(receiptsStreamProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final currentLocale = Localizations.localeOf(context).languageCode;

    final categoriesMap = <int, Category>{};
    categoriesAsync.whenData((cats) {
      for (final c in cats) {
        categoriesMap[c.id] = c;
      }
    });

    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(l10n.receiptsTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.analytics_outlined),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen())),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
          ],
        ),
        body: receiptsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: onSurface))),
          data: (receipts) {
            final currentMonthTotal = receipts
                .where((r) => r.purchasedAt.year == DateTime.now().year && r.purchasedAt.month == DateTime.now().month && r.currency == 'KRW')
                .fold(0, (sum, r) => sum + r.totalMinor);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen())),
                  child: PerforatedSlip(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MMMM yyyy').format(DateTime.now()),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: onSurface.withValues(alpha: 0.70),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          Money(currentMonthTotal, currency: 'KRW').format(currentLocale),
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: onSurface,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.receiptCount(receipts.length),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: onSurface.withValues(alpha: 0.70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                if (receipts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: onSurface.withValues(alpha: 0.40),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.emptyTitle,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onSurface),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.emptyBody,
                            style: TextStyle(fontSize: 14, color: onSurface.withValues(alpha: 0.60)),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: AppColors.ink,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => _showScanBottomSheet(context),
                            icon: const Icon(Icons.add_a_photo_rounded),
                            label: Text(l10n.scanReceipt, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...receipts.map((r) {
                    final cat = categoriesMap[r.categoryId];
                    final catColor = cat != null ? Color(cat.colorValue) : AppColors.lagoon;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Dismissible(
                        key: ValueKey('receipt_${r.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                        ),
                        onDismissed: (_) async {
                          final deletedReceipt = r;
                          final messenger = ScaffoldMessenger.of(context);
                          final deleteText = l10n.receiptDeleted;
                          final undoText = l10n.undo;

                          await ref.read(receiptsControllerProvider).deleteReceipt(r.id);

                          final snackBar = messenger.showSnackBar(
                            SnackBar(
                              content: Text(deleteText),
                              action: SnackBarAction(
                                label: undoText,
                                onPressed: () async {
                                  await ref.read(receiptsControllerProvider).saveReceipt(deletedReceipt);
                                },
                              ),
                            ),
                          );

                          // WHY: Keep image file until snackbar closes without undo action.
                          snackBar.closed.then((reason) async {
                            if (reason != SnackBarClosedReason.action) {
                              if (deletedReceipt.imagePath != null) {
                                try {
                                  final file = File(deletedReceipt.imagePath!);
                                  if (file.existsSync()) file.deleteSync();
                                } catch (_) {}
                              }
                            }
                          });
                        },
                        child: FrostedTile(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(receiptId: r.id))),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: catColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          r.merchant.isEmpty ? l10n.unknownMerchant : r.merchant,
                                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: onSurface),
                                        ),
                                        if (r.parserSource == 'llm') ...[
                                          const SizedBox(width: 6),
                                          const Icon(Icons.auto_awesome, size: 14, color: AppColors.iris),
                                        ]
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('MMM dd').format(r.purchasedAt),
                                      style: TextStyle(fontSize: 13, color: onSurface.withValues(alpha: 0.60)),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                Money(r.totalMinor, currency: r.currency).format(currentLocale),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: onSurface,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showScanBottomSheet(context),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: AppColors.ink,
          icon: const Icon(Icons.add_a_photo_rounded),
          label: Text(l10n.scanReceipt, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _ProcessingDialog extends ConsumerWidget {
  const _ProcessingDialog({required this.onCancel});
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scanState = ref.watch(scanControllerProvider);

    String statusText = l10n.reading;
    if (scanState.status == ScanStateStatus.parsing) {
      statusText = l10n.findingTotal;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: GlassPanel(
        strong: true,
        radius: 20,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 24),
                  Flexible(
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: onCancel,
                child: Text(l10n.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
