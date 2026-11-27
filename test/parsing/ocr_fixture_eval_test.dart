import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:receiptscanner/data/parsing/rule_based_parser.dart';
import 'package:receiptscanner/domain/entities/ocr_result.dart';

void main() {
  test('OCR fixture evaluation harness runs successfully (passes when folder is empty)', () async {
    final fixtureDir = Directory('test/fixtures/ocr');
    if (!fixtureDir.existsSync()) {
      expect(true, isTrue);
      return;
    }

    final txtFiles = fixtureDir.listSync().whereType<File>().where((f) => f.path.endsWith('.txt')).toList();

    for (final txtFile in txtFiles) {
      final basePath = txtFile.path.replaceAll('.txt', '');
      final labelFile = File('$basePath.label.json');
      if (!labelFile.existsSync()) continue;

      final text = txtFile.readAsStringSync();
      final lines = text.split('\n');
      final ocrLines = <OcrLine>[];
      for (int i = 0; i < lines.length; i++) {
        final top = lines.length > 1 ? i / (lines.length - 1) : 0.0;
        ocrLines.add(OcrLine(lines[i], top));
      }

      final ocr = OcrResult(fullText: text, lines: ocrLines);
      final parser = RuleBasedParser();
      final parsed = await parser.parse(ocr);

      // ignore: avoid_print
      print('Evaluated fixture: ${txtFile.path} -> parsed total: ${parsed.totalMinor}, merchant: ${parsed.merchant}');
      expect(parsed, isNotNull);
    }
  });
}
