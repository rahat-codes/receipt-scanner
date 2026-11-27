import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../application/receipts_controller.dart';
import '../../application/scan_controller.dart';
import '../../domain/entities/money.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/aurora_background.dart';
import '../theme/frosted_tile.dart';
import '../theme/glass_panel.dart';
import '../theme/perforated_slip.dart';
import 'detail_screen.dart';
import 'ocr_debug_screen.dart';
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
    final photo = await _picker.pickImage(source: source);
    if (photo == null) return;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ProcessingDialog(),
    );

    await ref.read(scanControllerProvider.notifier).processImage(photo.path);

    if (!mounted) return;
    Navigator.pop(context); // close dialog

    final scanState = ref.read(scanControllerProvider);
    if (scanState.status == ScanStateStatus.ready && scanState.parsed != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReviewScreen(
            parsed: scanState.parsed!,
            imagePath: photo.path,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final receiptsAsync = ref.watch(receiptsStreamProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(l10n.receiptsTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.bug_report_outlined),
              tooltip: 'OCR Debug',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OcrDebugScreen())),
            ),
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
          error: (e, _) => Center(child: Text('Error: $e')),
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
                          Money(currentMonthTotal, currency: 'KRW').format(),
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
                    padding: const EdgeInsets.only(top: 60.0),
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
                        ],
                      ),
                    ),
                  )
                else
                  ...receipts.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: FrostedTile(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(receiptId: r.id))),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.lagoon,
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
                                Money(r.totalMinor, currency: r.currency).format(),
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
                      )),
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
  const _ProcessingDialog();

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
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
        ),
      ),
    );
  }
}
