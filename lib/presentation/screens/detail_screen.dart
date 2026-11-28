import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/receipts_controller.dart';
import '../../core/providers.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/money.dart';
import '../../domain/entities/parsed_receipt.dart';
import '../../domain/entities/receipt.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
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
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(l10n.deleteReceipt),
                            content: Text(l10n.deleteConfirm),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.deleteReceipt, style: const TextStyle(color: AppColors.error))),
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
              return Center(child: Text(l10n.receiptNotFound, style: TextStyle(color: onSurface)));
            }
            final r = snapshot.data!;
            final cat = categoriesMap[r.categoryId];
            final categoryName = cat != null ? _getLocalizedCategoryName(l10n, cat.key) : l10n.category_other;

            String badgeText = l10n.badgeAuto;
            if (r.parserSource == 'manual') {
              badgeText = l10n.badgeEdited;
            } else if (r.parserSource == 'llm') {
              badgeText = l10n.badgeAi;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (r.imagePath != null && r.imagePath!.isNotEmpty && File(r.imagePath!).existsSync()) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: InteractiveViewer(
                        minScale: 1.0,
                        maxScale: 4.0,
                        child: Image.file(
                          File(r.imagePath!),
                          height: 280,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  r.merchant.isEmpty ? l10n.unknownMerchant : r.merchant,
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: onSurface),
                                ),
                              ),
                              Chip(
                                label: Text(badgeText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                                labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                                side: BorderSide.none,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat('yyyy-MM-dd HH:mm').format(r.purchasedAt),
                            style: TextStyle(color: onSurface.withValues(alpha: 0.60)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${l10n.category}: $categoryName',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: onSurface.withValues(alpha: 0.80)),
                          ),
                          Divider(height: 32, color: onSurface.withValues(alpha: 0.12)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.total, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: onSurface)),
                              Text(
                                Money(r.totalMinor, currency: r.currency).format(currentLocale),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
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

  String _getLocalizedCategoryName(AppLocalizations l10n, String key) {
    switch (key) {
      case 'food': return l10n.category_food;
      case 'groceries': return l10n.category_groceries;
      case 'transport': return l10n.category_transport;
      case 'shopping': return l10n.category_shopping;
      case 'health': return l10n.category_health;
      case 'entertainment': return l10n.category_entertainment;
      case 'utilities': return l10n.category_utilities;
      default: return l10n.category_other;
    }
  }
}
