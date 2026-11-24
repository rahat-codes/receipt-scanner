import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/receipts_controller.dart';
import '../../core/providers.dart';
import '../../domain/entities/money.dart';
import '../../domain/entities/parsed_receipt.dart';
import '../../domain/entities/receipt.dart';
import '../../l10n/app_localizations.dart';
import '../theme/aurora_background.dart';
import '../theme/glass_panel.dart';
import 'review_screen.dart';

class DetailScreen extends ConsumerWidget {
  const DetailScreen({super.key, required this.receiptId});
  final int receiptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(receiptRepositoryProvider);

    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.receiptsTitle),
          actions: [
            FutureBuilder<Receipt?>(
              future: repo.getById(receiptId),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) return const SizedBox.shrink();
                final receipt = snapshot.data!;
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReviewScreen(
                              parsed: ParsedReceipt(
                                merchant: receipt.merchant,
                                date: receipt.purchasedAt,
                                totalMinor: receipt.totalMinor,
                                currency: receipt.currency,
                                confidence: receipt.confidence,
                              ),
                              imagePath: receipt.imagePath ?? '',
                              existingReceipt: receipt,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(l10n.deleteReceipt),
                            content: Text(l10n.deleteConfirm),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.deleteReceipt, style: const TextStyle(color: Colors.red))),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref.read(receiptsControllerProvider).deleteReceipt(receipt.id);
                          if (!context.mounted) return;
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                );
              },
            )
          ],
        ),
        body: FutureBuilder<Receipt?>(
          future: repo.getById(receiptId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('Receipt not found'));
            }
            final r = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (r.imagePath != null && r.imagePath!.isNotEmpty && File(r.imagePath!).existsSync()) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        File(r.imagePath!),
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  GlassPanel(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.merchant, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(DateFormat('yyyy-MM-dd HH:mm').format(r.purchasedAt), style: const TextStyle(color: Colors.grey)),
                          const Divider(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.total, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                              Text(
                                Money(r.totalMinor, currency: r.currency).format(),
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF12B5A6)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
