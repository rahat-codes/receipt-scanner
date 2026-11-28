import 'package:flutter_test/flutter_test.dart';
import 'package:receiptscanner/domain/entities/category.dart';
import 'package:receiptscanner/domain/entities/receipt.dart';
import 'package:receiptscanner/domain/entities/receipt_item.dart';
import 'package:receiptscanner/domain/interfaces/receipt_repository.dart';
import 'package:receiptscanner/domain/logic/expense_tools.dart';

class FakeRepoForTools implements ReceiptRepository {
  final List<Receipt> receipts;
  FakeRepoForTools(this.receipts);

  @override
  Future<List<Receipt>> getMonthReceipts(DateTime month, String currency) async => receipts;

  @override
  Future<List<Category>> getCategories() async => const [
        Category(id: 1, key: 'food', colorValue: 0xFFF97316, sortOrder: 0),
        Category(id: 2, key: 'groceries', colorValue: 0xFF22C55E, sortOrder: 1),
      ];

  @override
  Stream<List<Receipt>> watchAll() => Stream.value(receipts);
  @override
  Future<Receipt?> getById(int id) async => null;
  @override
  Future<int> insert(receipt) async => 1;
  @override
  Future<void> update(receipt) async {}
  @override
  Future<void> delete(int id) async {}
  @override
  Stream<List<CategoryTotal>> watchCategoryTotals(DateTime month, String currency) => Stream.value([]);
  @override
  Stream<List<MonthTotal>> watchMonthlyTotals({required int months, required String currency}) => Stream.value([]);
  @override
  Stream<List<Receipt>> watchFiltered(filter) => Stream.value(receipts);
  @override
  Future<List<Receipt>> findPossibleDuplicates(candidate, {int? excludeId}) async => [];
  @override
  Future<List<ReceiptItem>> getItems(int receiptId) async => [];
  @override
  Future<void> replaceItems(receiptId, items) async {}
}

void main() {
  group('ExpenseTools Tests', () {
    test('sanitizeMerchant strips control characters and trims length', () {
      expect(ExpenseTools.sanitizeMerchant('Starbucks\nGangnam\r\t'), 'StarbucksGangnam');
      expect(ExpenseTools.sanitizeMerchant('A' * 50), 'A' * 40);
    });

    test('get_spending_total calculates total correctly', () async {
      final repo = FakeRepoForTools([
        Receipt(
          id: 1,
          merchant: 'Starbucks',
          purchasedAt: DateTime(2026, 3, 1),
          totalMinor: 5000,
          currency: 'KRW',
          categoryId: 1,
          rawOcrText: '',
          parserSource: 'rules',
          confidence: 0.9,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ]);
      final tools = ExpenseTools(repo);
      final res = await tools.execute('get_spending_total', {
        'start_date': '2026-03-01',
        'end_date': '2026-03-31',
      });

      expect(res['total_minor'], 5000);
      expect(res['receipt_count'], 1);
    });
  });
}
