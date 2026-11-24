import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../application/receipts_controller.dart';
import '../../application/scan_controller.dart';
import '../../domain/entities/money.dart';
import '../../l10n/app_localizations.dart';
import '../theme/aurora_background.dart';
import '../theme/frosted_tile.dart';
import '../theme/glass_tokens.dart';
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
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).extension<GlassTheme>()!.fillStrong,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: Theme.of(context).extension<GlassTheme>()!.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: Text(l10n.takePhoto),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(l10n.chooseFromGallery),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
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
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          Money(currentMonthTotal, currency: 'KRW').format(),
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white, fontFeatures: [FontFeature.tabularFigures()]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.receiptCount(receipts.length),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white70),
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
                          const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(l10n.emptyTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(l10n.emptyBody, style: const TextStyle(fontSize: 14, color: Colors.grey)),
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
                                  color: Color(0xFF12B5A6),
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
                                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                        ),
                                        if (r.parserSource == 'llm') ...[
                                          const SizedBox(width: 6),
                                          const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF7C83FD)),
                                        ]
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('MMM dd').format(r.purchasedAt),
                                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                Money(r.totalMinor, currency: r.currency).format(),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFeatures: [FontFeature.tabularFigures()]),
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
          backgroundColor: const Color(0xFF12B5A6),
          foregroundColor: const Color(0xFF0F1B2D),
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

    return AlertDialog(
      backgroundColor: Theme.of(context).extension<GlassTheme>()!.fillStrong,
      content: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 24),
          Text(statusText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
