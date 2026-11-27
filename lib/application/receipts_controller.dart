import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers.dart';
import '../domain/entities/category.dart';
import '../domain/entities/receipt.dart';

final receiptsStreamProvider = StreamProvider<List<Receipt>>((ref) {
  final repo = ref.watch(receiptRepositoryProvider);
  return repo.watchAll();
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repo = ref.watch(receiptRepositoryProvider);
  return repo.getCategories();
});

class ReceiptsController {
  final Ref ref;
  ReceiptsController(this.ref);

  Future<int> saveReceipt(Receipt receipt) async {
    final repo = ref.read(receiptRepositoryProvider);
    return await repo.insert(receipt);
  }

  Future<void> updateReceipt(Receipt receipt) async {
    final repo = ref.read(receiptRepositoryProvider);
    await repo.update(receipt);
  }

  Future<void> deleteReceipt(int id) async {
    final repo = ref.read(receiptRepositoryProvider);
    await repo.delete(id);
  }
}

final receiptsControllerProvider = Provider<ReceiptsController>((ref) {
  return ReceiptsController(ref);
});
