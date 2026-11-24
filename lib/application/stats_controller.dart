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
