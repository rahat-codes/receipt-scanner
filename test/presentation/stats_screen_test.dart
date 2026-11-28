import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:receiptscanner/application/receipts_controller.dart';
import 'package:receiptscanner/core/providers.dart';
import 'package:receiptscanner/domain/entities/category.dart';
import 'package:receiptscanner/domain/entities/receipt.dart';
import 'package:receiptscanner/domain/entities/receipt_item.dart';
import 'package:receiptscanner/domain/interfaces/receipt_repository.dart';
import 'package:receiptscanner/l10n/app_localizations.dart';
import 'package:receiptscanner/presentation/screens/stats_screen.dart';

class FakeStatsReceiptRepository implements ReceiptRepository {
  @override
  Stream<List<CategoryTotal>> watchCategoryTotals(DateTime month, String currency) {
    return Stream.value([
      const CategoryTotal(categoryKey: 'food', colorValue: 0xFFF97316, totalMinor: 15000),
      const CategoryTotal(categoryKey: 'groceries', colorValue: 0xFF22C55E, totalMinor: 5000),
    ]);
  }

  @override
  Stream<List<MonthTotal>> watchMonthlyTotals({required int months, required String currency}) {
    return Stream.value([
      const MonthTotal(month: '2026-02', totalMinor: 120000),
      const MonthTotal(month: '2026-03', totalMinor: 184000),
    ]);
  }

  @override
  Future<List<Category>> getCategories() async => const [
        Category(id: 1, key: 'food', colorValue: 0xFFF97316, sortOrder: 0),
        Category(id: 2, key: 'groceries', colorValue: 0xFF22C55E, sortOrder: 1),
      ];

  @override
  Stream<List<Receipt>> watchAll() => Stream.value([]);
  @override
  Future<Receipt?> getById(int id) async => null;
  @override
  Future<int> insert(Receipt receipt) async => 1;
  @override
  Future<void> update(Receipt receipt) async {}
  @override
  Future<void> delete(int id) async {}
  @override
  Stream<List<Receipt>> watchFiltered(filter) => Stream.value([]);
  @override
  Future<List<Receipt>> getMonthReceipts(month, currency) async => [];
  @override
  Future<List<Receipt>> findPossibleDuplicates(candidate, {int? excludeId}) async => [];
  @override
  Future<List<ReceiptItem>> getItems(int receiptId) async => [];
  @override
  Future<void> replaceItems(receiptId, items) async {}
}

void main() {
  final repo = FakeStatsReceiptRepository();

  Widget buildTestableWidget() {
    return ProviderScope(
      overrides: [
        receiptRepositoryProvider.overrideWithValue(repo),
        categoriesProvider.overrideWith((ref) => repo.getCategories()),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en'), Locale('ko')],
        home: StatsScreen(),
      ),
    );
  }

  group('StatsScreen Navigation & Chart Tests', () {
    testWidgets('defaults to current month and enforces month navigation limits', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final now = DateTime.now();
      final currentMonthStr = DateFormat('MMMM yyyy').format(now);
      expect(find.text(currentMonthStr), findsOneWidget);

      // Tapping next button when in current month does not change month
      await tester.tap(find.byKey(const Key('next_month_button')));
      await tester.pumpAndSettle();
      expect(find.text(currentMonthStr), findsOneWidget);

      // Tapping prev button moves to previous month
      await tester.tap(find.byKey(const Key('prev_month_button')));
      await tester.pumpAndSettle();

      final prevMonth = DateTime(now.year, now.month - 1, 1);
      final prevMonthStr = DateFormat('MMMM yyyy').format(prevMonth);
      expect(find.text(prevMonthStr), findsOneWidget);

      // Now next button is enabled and moves back to current month
      await tester.tap(find.byKey(const Key('next_month_button')));
      await tester.pumpAndSettle();
      expect(find.text(currentMonthStr), findsOneWidget);
    });
  });
}
