// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/receipts_controller.dart';
import '../../core/providers.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/parsed_receipt.dart';
import '../../domain/entities/receipt.dart';
import '../../l10n/app_localizations.dart';
import '../theme/amber_hint.dart';
import '../theme/aurora_background.dart';
import '../theme/glass_panel.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({
    super.key,
    required this.parsed,
    required this.imagePath,
    this.existingReceipt,
  });

  final ParsedReceipt parsed;
  final String imagePath;
  final Receipt? existingReceipt;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  late final TextEditingController _merchantController;
  late final TextEditingController _totalController;
  late DateTime _selectedDate;
  late String _currency;
  int? _selectedCategoryId;
  bool _hasEdited = false;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    final r = widget.existingReceipt;
    final p = widget.parsed;

    _merchantController = TextEditingController(text: r?.merchant ?? p.merchant ?? '');
    _totalController = TextEditingController(
        text: r != null
            ? (r.totalMinor / (r.currency == 'USD' ? 100 : 1)).toString()
            : (p.totalMinor != null ? (p.totalMinor! / (p.currency == 'USD' ? 100 : 1)).toString() : ''));
    _selectedDate = r?.purchasedAt ?? p.date ?? DateTime.now();
    _currency = r?.currency ?? p.currency;

    _loadCategories(r?.categoryId);

    _merchantController.addListener(_markEdited);
    _totalController.addListener(_markEdited);
  }

  Future<void> _loadCategories(int? initialCatId) async {
    final repo = ref.read(receiptRepositoryProvider);
    final cats = await repo.getCategories();
    setState(() {
      _categories = cats;
      if (initialCatId != null) {
        _selectedCategoryId = initialCatId;
      } else if (cats.isNotEmpty) {
        _selectedCategoryId = cats.first.id;
      }
    });
  }

  void _markEdited() {
    if (!_hasEdited) {
      setState(() => _hasEdited = true);
    }
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  Future<void> _cleanupImage() async {
    // WHY: Clean up orphan image file on discard or failed save if not an existing receipt edit.
    if (widget.existingReceipt == null && widget.imagePath.isNotEmpty) {
      try {
        final file = File(widget.imagePath);
        if (file.existsSync()) file.deleteSync();
      } catch (_) {}
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final merchant = _merchantController.text.trim();
    final totalVal = double.tryParse(_totalController.text) ?? 0.0;
    if (totalVal <= 0 || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.checkThis)));
      return;
    }

    try {
      final totalMinor = _currency == 'USD' ? (totalVal * 100).round() : totalVal.round();
      final controller = ref.read(receiptsControllerProvider);

      final source = widget.existingReceipt != null
          ? 'manual'
          : (_hasEdited ? 'manual' : widget.parsed.source.name);

      if (widget.existingReceipt != null) {
        final updated = Receipt(
          id: widget.existingReceipt!.id,
          merchant: merchant.isEmpty ? l10n.unknownMerchant : merchant,
          purchasedAt: _selectedDate,
          totalMinor: totalMinor,
          currency: _currency,
          categoryId: _selectedCategoryId!,
          imagePath: widget.imagePath,
          rawOcrText: widget.existingReceipt!.rawOcrText,
          parserSource: source,
          confidence: 1.0,
          createdAt: widget.existingReceipt!.createdAt,
          updatedAt: DateTime.now(),
        );
        await controller.updateReceipt(updated);
      } else {
        final newReceipt = Receipt(
          id: 0,
          merchant: merchant.isEmpty ? l10n.unknownMerchant : merchant,
          purchasedAt: _selectedDate,
          totalMinor: totalMinor,
          currency: _currency,
          categoryId: _selectedCategoryId!,
          imagePath: widget.imagePath,
          rawOcrText: '',
          parserSource: source,
          confidence: widget.parsed.confidence,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await controller.saveReceipt(newReceipt);
      }

      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (_) {
      await _cleanupImage();
    }
  }

  Future<void> _onBack() async {
    final l10n = AppLocalizations.of(context)!;
    if (_hasEdited) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.discardTitle),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.keepEditing)),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.discard)),
          ],
        ),
      );
      if (discard == true) {
        await _cleanupImage();
        if (!mounted) return;
        Navigator.pop(context);
      }
    } else {
      await _cleanupImage();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final needsReview = widget.parsed.needsReview;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onBack();
      },
      child: AuroraBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(l10n.saveReceipt),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _onBack,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: GlassPanel(
              strong: true,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.merchant, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    needsReview.contains(FieldFlag.merchant)
                        ? AmberHint(
                            message: l10n.checkThis,
                            child: TextField(controller: _merchantController, decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(12))),
                          )
                        : TextField(controller: _merchantController, decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.all(12))),
                    const SizedBox(height: 16),
                    Text(l10n.date, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        _markEdited();
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now().add(const Duration(days: 1)),
                        );
                        if (d != null) setState(() => _selectedDate = d);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.all(12)),
                        child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.total, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    needsReview.contains(FieldFlag.total)
                        ? AmberHint(
                            message: l10n.checkThis,
                            child: TextField(controller: _totalController, keyboardType: TextInputType.number, decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(12))),
                          )
                        : TextField(controller: _totalController, keyboardType: TextInputType.number, decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.all(12))),
                    const SizedBox(height: 16),
                    Text(l10n.currency, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'KRW', label: Text('KRW (₩)')),
                        ButtonSegment(value: 'USD', label: Text('USD (\$ )')),
                      ],
                      selected: {_currency},
                      onSelectionChanged: (val) {
                        _markEdited();
                        setState(() => _currency = val.first);
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.category, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategoryId == cat.id;
                        return ChoiceChip(
                          label: Text(_getLocalizedCategoryName(l10n, cat.key)),
                          selected: isSelected,
                          onSelected: (_) {
                            _markEdited();
                            setState(() => _selectedCategoryId = cat.id);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF12B5A6),
                          foregroundColor: const Color(0xFF0F1B2D),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _save,
                        child: Text(l10n.saveReceipt, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
