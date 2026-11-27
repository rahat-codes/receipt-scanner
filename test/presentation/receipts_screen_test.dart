import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receiptscanner/application/receipts_controller.dart';
import 'package:receiptscanner/core/providers.dart';
import 'package:receiptscanner/domain/entities/category.dart';
import 'package:receiptscanner/domain/entities/receipt.dart';
import 'package:receiptscanner/domain/entities/receipt_item.dart';
import 'package:receiptscanner/domain/interfaces/receipt_repository.dart';
import 'package:receiptscanner/l10n/app_localizations.dart';
import 'package:receiptscanner/presentation/screens/receipts_screen.dart';

class FakeReceiptRepository implements ReceiptRepository {
  final List<Receipt> receipts;
  FakeReceiptRepository(this.receipts);

  @override
  Stream<List<Receipt>> watchAll() => Stream.value(receipts);

  @override
  Future<List<Category>> getCategories() async => const [
        Category(id: 1, key: 'food', colorValue: 0xFFF97316, sortOrder: 0),
        Category(id: 2, key: 'groceries', colorValue: 0xFF22C55E, sortOrder: 1),
      ];

  @override
  Future<void> delete(int id) async {
    receipts.removeWhere((r) => r.id == id);
  }

  @override
  Future<int> insert(Receipt receipt) async {
    receipts.add(receipt);
    return receipt.id;
  }

  @override
  Future<Receipt?> getById(int id) async => receipts.firstWhere((r) => r.id == id);

  @override
  Future<void> update(Receipt receipt) async {}

  @override
  Stream<List<CategoryTotal>> watchCategoryTotals(DateTime month, String currency) => Stream.value([]);

  @override
  Stream<List<MonthTotal>> watchMonthlyTotals({required int months, required String currency}) => Stream.value([]);

  @override
  Stream<List<Receipt>> watchFiltered(filter) => Stream.value(receipts);

  @override
  Future<List<Receipt>> getMonthReceipts(DateTime month, String currency) async => receipts;

  @override
  Future<List<Receipt>> findPossibleDuplicates(candidate, {int? excludeId}) async => [];

  @override
  Future<List<ReceiptItem>> getItems(int receiptId) async => [];

  @override
  Future<void> replaceItems(int receiptId, items) async {}
}

void main() {
  Widget buildTestableWidget({
    required List<Receipt> receipts,
    ReceiptRepository? repo,
  }) {
    final repository = repo ?? FakeReceiptRepository(List.from(receipts));
    return ProviderScope(
      overrides: [
        receiptRepositoryProvider.overrideWithValue(repository),
        receiptsStreamProvider.overrideWith((ref) => repository.watchAll()),
        categoriesProvider.overrideWith((ref) => repository.getCategories()),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en'), Locale('ko')],
        home: ReceiptsScreen(),
      ),
    );
  }

  group('ReceiptsScreen Widget Tests', () {
    testWidgets('renders empty state when receipts list is empty', (tester) async {
      await tester.pumpWidget(buildTestableWidget(receipts: []));
      await tester.pumpAndSettle();

      expect(find.text('No receipts yet'), findsOneWidget);
      expect(find.text('Scan receipt'), findsNWidgets(2));
    });

    testWidgets('renders list with 3 receipts', (tester) async {
      final receipts = [
        Receipt(
          id: 1,
          merchant: 'Starbucks',
          purchasedAt: DateTime.now(),
          totalMinor: 5500,
          currency: 'KRW',
          categoryId: 1,
          rawOcrText: '',
          parserSource: 'rules',
          confidence: 0.9,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Receipt(
          id: 2,
          merchant: 'GS25',
          purchasedAt: DateTime.now(),
          totalMinor: 3000,
          currency: 'KRW',
          categoryId: 2,
          rawOcrText: '',
          parserSource: 'rules',
          confidence: 0.9,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Receipt(
          id: 3,
          merchant: 'Burger King',
          purchasedAt: DateTime.now(),
          totalMinor: 8900,
          currency: 'KRW',
          categoryId: 1,
          rawOcrText: '',
          parserSource: 'rules',
          confidence: 0.9,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(buildTestableWidget(receipts: receipts));
      await tester.pumpAndSettle();

      expect(find.text('Starbucks'), findsOneWidget);
      expect(find.text('GS25'), findsOneWidget);
      expect(find.text('Burger King'), findsOneWidget);
    });

    testWidgets('swipe to delete receipt triggers snackbar with undo option', (tester) async {
      final receipts = [
        Receipt(
          id: 10,
          merchant: 'Target Store',
          purchasedAt: DateTime.now(),
          totalMinor: 15000,
          currency: 'KRW',
          categoryId: 1,
          rawOcrText: '',
          parserSource: 'rules',
          confidence: 0.9,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final repo = FakeReceiptRepository(List.from(receipts));
      await tester.pumpWidget(buildTestableWidget(receipts: receipts, repo: repo));
      await tester.pumpAndSettle();

      expect(find.text('Target Store'), findsOneWidget);

      // Swipe to delete
      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text('Receipt deleted'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      // Tap undo
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(repo.receipts.length, 1);
    });
  });
}
