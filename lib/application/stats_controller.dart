import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers.dart';
import '../domain/interfaces/receipt_repository.dart';

final categoryTotalsProvider = StreamProvider.family<List<CategoryTotal>, (DateTime, String)>((ref, params) {
  final repo = ref.watch(receiptRepositoryProvider);
  return repo.watchCategoryTotals(params.$1, params.$2);
});

final monthlyTotalsProvider = StreamProvider.family<List<MonthTotal>, String>((ref, currency) {
  final repo = ref.watch(receiptRepositoryProvider);
  return repo.watchMonthlyTotals(months: 6, currency: currency);
});

/// Pure helper logic for abbreviating spending amounts per locale.
String abbreviateAmount(int amountMinor, String currency, String locale) {
  if (amountMinor == 0) return '0';
  final isKo = locale.startsWith('ko');

  if (currency == 'USD') {
    final dollars = amountMinor / 100.0;
    if (dollars >= 1000) {
      final k = dollars / 1000.0;
      return '\$${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}K';
    }
    return '\$${dollars.toStringAsFixed(dollars.truncateToDouble() == dollars ? 0 : 2)}';
  } else {
    final won = amountMinor;
    if (isKo) {
      if (won >= 10000) {
        final man = won / 10000.0;
        return '${man.toStringAsFixed(man.truncateToDouble() == man ? 0 : 1)}만';
      } else if (won >= 1000) {
        final cheon = won / 1000.0;
        return '${cheon.toStringAsFixed(cheon.truncateToDouble() == cheon ? 0 : 1)}천';
      }
      return '$won';
    } else {
      if (won >= 1000) {
        final k = won / 1000.0;
        return '₩${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}K';
      }
      return '₩$won';
    }
  }
}

/// Pure helper logic for computing percentage shares for category totals.
List<double> calculatePercents(List<int> amounts) {
  final total = amounts.fold(0, (sum, a) => sum + a);
  if (total == 0) {
    return List.filled(amounts.length, 0.0);
  }
  return amounts.map((a) => (a / total) * 100.0).toList();
}
