import '../entities/money.dart';
import '../interfaces/receipt_repository.dart';

class ExpenseTools {
  final ReceiptRepository repository;

  const ExpenseTools(this.repository);

  /// Sanitizes merchant strings: max 40 chars, strips newlines and control characters.
  static String sanitizeMerchant(String? merchant) {
    if (merchant == null) return '';
    final cleaned = merchant.replaceAll(RegExp(r'[\r\n\t\p{C}]', unicode: true), '').trim();
    if (cleaned.length > 40) {
      return cleaned.substring(0, 40);
    }
    return cleaned;
  }

  /// Validates ISO date string (YYYY-MM-DD).
  static DateTime? parseIsoDate(String? dateStr) {
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }

  Future<Map<String, dynamic>> execute(String toolName, Map<String, dynamic> args) async {
    try {
      switch (toolName) {
        case 'get_spending_total':
          return await _getSpendingTotal(args);
        case 'get_category_breakdown':
          return await _getCategoryBreakdown(args);
        case 'get_top_merchants':
          return await _getTopMerchants(args);
        case 'find_receipts':
          return await _findReceipts(args);
        case 'compare_periods':
          return await _comparePeriods(args);
        default:
          return {'error': 'Unknown tool: $toolName'};
      }
    } catch (e) {
      return {'error': 'Tool execution failed: $e'};
    }
  }

  Future<Map<String, dynamic>> _getSpendingTotal(Map<String, dynamic> args) async {
    final startDate = parseIsoDate(args['start_date']);
    final endDate = parseIsoDate(args['end_date']);
    if (startDate == null || endDate == null) {
      return {'error': 'Invalid or missing start_date / end_date (expected YYYY-MM-DD)'};
    }

    final receipts = await repository.getMonthReceipts(startDate, 'KRW'); // default KRW for core
    final filtered = receipts.where((r) =>
        !r.purchasedAt.isBefore(startDate) && r.purchasedAt.isBefore(endDate.add(const Duration(days: 1))));

    int totalMinor = 0;
    for (final r in filtered) {
      totalMinor += r.totalMinor;
    }

    return {
      'total_minor': totalMinor,
      'display_amount': Money(totalMinor, currency: 'KRW').format(),
      'receipt_count': filtered.length,
    };
  }

  Future<Map<String, dynamic>> _getCategoryBreakdown(Map<String, dynamic> args) async {
    final startDate = parseIsoDate(args['start_date']);
    final endDate = parseIsoDate(args['end_date']);
    if (startDate == null || endDate == null) {
      return {'error': 'Invalid or missing start_date / end_date'};
    }

    // Use monthly category totals or compute from month receipts
    final categories = await repository.getCategories();
    final receipts = await repository.getMonthReceipts(startDate, 'KRW');
    final filtered = receipts.where((r) =>
        !r.purchasedAt.isBefore(startDate) && r.purchasedAt.isBefore(endDate.add(const Duration(days: 1))));

    final catTotals = <int, int>{};
    int grandTotal = 0;
    for (final r in filtered) {
      catTotals[r.categoryId] = (catTotals[r.categoryId] ?? 0) + r.totalMinor;
      grandTotal += r.totalMinor;
    }

    final breakdown = <Map<String, dynamic>>[];
    for (final cat in categories) {
      final amt = catTotals[cat.id] ?? 0;
      final pct = grandTotal > 0 ? (amt / grandTotal) * 100 : 0.0;
      breakdown.add({
        'category': cat.key,
        'display_amount': Money(amt, currency: 'KRW').format(),
        'percent': double.parse(pct.toStringAsFixed(1)),
      });
    }

    return {'breakdown': breakdown, 'grand_total': Money(grandTotal, currency: 'KRW').format()};
  }

  Future<Map<String, dynamic>> _getTopMerchants(Map<String, dynamic> args) async {
    final startDate = parseIsoDate(args['start_date']);
    final endDate = parseIsoDate(args['end_date']);
    int limit = int.tryParse(args['limit']?.toString() ?? '5') ?? 5;
    if (limit > 5) limit = 5;
    if (startDate == null || endDate == null) {
      return {'error': 'Invalid or missing start_date / end_date'};
    }

    final receipts = await repository.getMonthReceipts(startDate, 'KRW');
    final filtered = receipts.where((r) =>
        !r.purchasedAt.isBefore(startDate) && r.purchasedAt.isBefore(endDate.add(const Duration(days: 1))));

    final merchantStats = <String, (int, int)>{}; // merchant -> (totalMinor, visits)
    for (final r in filtered) {
      final m = sanitizeMerchant(r.merchant);
      if (m.isEmpty) continue;
      final current = merchantStats[m] ?? (0, 0);
      merchantStats[m] = (current.$1 + r.totalMinor, current.$2 + 1);
    }

    final sorted = merchantStats.entries.toList()
      ..sort((a, b) => b.value.$1.compareTo(a.value.$1));

    final top = sorted.take(limit).map((e) => {
          'merchant': e.key,
          'display_amount': Money(e.value.$1, currency: 'KRW').format(),
          'visits': e.value.$2,
        }).toList();

    return {'top_merchants': top};
  }

  Future<Map<String, dynamic>> _findReceipts(Map<String, dynamic> args) async {
    final startDate = parseIsoDate(args['start_date']);
    final endDate = parseIsoDate(args['end_date']);
    int limit = int.tryParse(args['limit']?.toString() ?? '10') ?? 10;
    if (limit > 10) limit = 10;
    if (startDate == null || endDate == null) {
      return {'error': 'Invalid or missing start_date / end_date'};
    }

    final receipts = await repository.getMonthReceipts(startDate, 'KRW');
    final categories = await repository.getCategories();
    final catMap = {for (var c in categories) c.id: c.key};

    final filtered = receipts.where((r) =>
        !r.purchasedAt.isBefore(startDate) && r.purchasedAt.isBefore(endDate.add(const Duration(days: 1))));

    final list = filtered.take(limit).map((r) => {
          'date': r.purchasedAt.toIso8601String().split('T').first,
          'merchant': sanitizeMerchant(r.merchant),
          'category': catMap[r.categoryId] ?? 'other',
          'display_amount': Money(r.totalMinor, currency: r.currency).format(),
        }).toList();

    return {'receipts': list};
  }

  Future<Map<String, dynamic>> _comparePeriods(Map<String, dynamic> args) async {
    final aStart = parseIsoDate(args['a_start']);
    final aEnd = parseIsoDate(args['a_end']);
    final bStart = parseIsoDate(args['b_start']);
    final bEnd = parseIsoDate(args['b_end']);

    if (aStart == null || aEnd == null || bStart == null || bEnd == null) {
      return {'error': 'Missing period date parameters'};
    }

    final receiptsA = await repository.getMonthReceipts(aStart, 'KRW');
    final filteredA = receiptsA.where((r) => !r.purchasedAt.isBefore(aStart) && r.purchasedAt.isBefore(aEnd.add(const Duration(days: 1))));
    int totalA = filteredA.fold(0, (sum, r) => sum + r.totalMinor);

    final receiptsB = await repository.getMonthReceipts(bStart, 'KRW');
    final filteredB = receiptsB.where((r) => !r.purchasedAt.isBefore(bStart) && r.purchasedAt.isBefore(bEnd.add(const Duration(days: 1))));
    int totalB = filteredB.fold(0, (sum, r) => sum + r.totalMinor);

    double percentChange = totalA > 0 ? ((totalB - totalA) / totalA) * 100 : (totalB > 0 ? 100.0 : 0.0);

    return {
      'period_a_total': Money(totalA, currency: 'KRW').format(),
      'period_b_total': Money(totalB, currency: 'KRW').format(),
      'percent_change': double.parse(percentChange.toStringAsFixed(1)),
    };
  }
}
