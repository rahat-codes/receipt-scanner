// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:receiptscanner/data/assistant/gemini_assistant_service.dart';
import 'package:receiptscanner/data/db/app_database.dart' hide Receipt, ReceiptItem;
import 'package:receiptscanner/data/db/drift_receipt_repository.dart';
import 'package:receiptscanner/domain/entities/receipt.dart';
import 'package:receiptscanner/domain/logic/expense_tools.dart';

Future<void> main() async {
  final questionsFile = File('eval/assistant/questions.json');
  if (!questionsFile.existsSync()) {
    print('eval/assistant/questions.json not found.');
    return;
  }

  final questions = jsonDecode(questionsFile.readAsStringSync()) as List<dynamic>;
  final db = AppDatabase(NativeDatabase.memory());
  final repo = DriftReceiptRepository(db);

  // Seed sample data for evaluation
  final categories = await repo.getCategories();
  final foodCatId = categories.first.id;
  await repo.insert(Receipt(
    id: 0,
    merchant: '스타벅스 대연점',
    purchasedAt: DateTime(2026, 3, 1),
    totalMinor: 5500,
    currency: 'KRW',
    categoryId: foodCatId,
    rawOcrText: '',
    parserSource: 'rules',
    confidence: 0.9,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ));

  final service = GeminiAssistantService(expenseTools: ExpenseTools(repo));
  final results = <Map<String, dynamic>>[];

  for (final q in questions) {
    final qId = q['id'];
    final questionText = q['question'];
    final sw = Stopwatch()..start();
    try {
      final answer = await service.sendMessage(questionText, []);
      sw.stop();
      results.add({
        'id': qId,
        'question': questionText,
        'answer': answer,
        'latency_ms': sw.elapsedMilliseconds,
        'error': null,
      });
      print('Evaluated Q$qId: "$questionText" (${sw.elapsedMilliseconds}ms)');
    } catch (e) {
      sw.stop();
      results.add({
        'id': qId,
        'question': questionText,
        'answer': '',
        'latency_ms': sw.elapsedMilliseconds,
        'error': e.toString(),
      });
      print('Error on Q$qId: $e');
    }
  }

  final outDir = Directory('eval/assistant');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);
  File('${outDir.path}/results.json').writeAsStringSync(const JsonEncoder.withIndent('  ').convert(results));
  print('Evaluation results saved to eval/assistant/results.json');
  await db.close();
}
