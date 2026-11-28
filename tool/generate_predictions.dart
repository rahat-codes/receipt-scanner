// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:receiptscanner/data/parsing/rule_based_parser.dart';
import 'package:receiptscanner/domain/entities/ocr_result.dart';

Future<void> main() async {
  final fixtureDir = Directory('test/fixtures/ocr');
  final outDir = Directory('eval/predictions');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  if (!fixtureDir.existsSync()) {
    print('Fixture directory test/fixtures/ocr does not exist.');
    return;
  }

  final txtFiles = fixtureDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.txt'))
      .toList();

  final parser = RuleBasedParser();

  for (final txtFile in txtFiles) {
    final fileName = txtFile.uri.pathSegments.last;
    final baseName = fileName.replaceAll('.txt', '');
    final text = txtFile.readAsStringSync();
    final lines = text.split('\n');

    final ocrLines = <OcrLine>[];
    for (int i = 0; i < lines.length; i++) {
      final top = lines.length > 1 ? i / (lines.length - 1) : 0.0;
      ocrLines.add(OcrLine(lines[i], top));
    }

    final ocr = OcrResult(fullText: text, lines: ocrLines);
    final parsed = await parser.parse(ocr);

    final predictionJson = {
      'merchant': parsed.merchant,
      'date': parsed.date?.toIso8601String().split('T').first,
      'total_minor': parsed.totalMinor,
      'currency': parsed.currency,
      'confidence': parsed.confidence,
      'needs_review': parsed.needsReview.map((f) => f.name).toList(),
    };

    final outFile = File('${outDir.path}/$baseName.json');
    outFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(predictionJson));
    print('Generated prediction for $baseName -> ${outFile.path}');
  }

  print('Predictions generated successfully for ${txtFiles.length} fixtures.');
}
