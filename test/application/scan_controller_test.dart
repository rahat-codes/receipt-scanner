import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receiptscanner/application/scan_controller.dart';
import 'package:receiptscanner/core/providers.dart';
import 'package:receiptscanner/data/parsing/rule_based_parser.dart';
import 'package:receiptscanner/domain/entities/ocr_result.dart';
import 'package:receiptscanner/domain/interfaces/ocr_service.dart';

class FakeOcrService implements OcrService {
  final OcrResult resultToReturn;
  final bool shouldThrow;

  FakeOcrService({required this.resultToReturn, this.shouldThrow = false});

  @override
  Future<OcrResult> read(String imagePath) async {
    if (shouldThrow) throw Exception('OCR hardware failure');
    return resultToReturn;
  }
}

void main() {
  group('ScanController Tests', () {
    test('handles successful OCR and parse flow', () async {
      final container = ProviderContainer(
        overrides: [
          ocrServiceProvider.overrideWithValue(
            FakeOcrService(
              resultToReturn: const OcrResult(
                fullText: 'Starbucks\n2024-03-01\nTotal 5000',
                lines: [
                  OcrLine('Starbucks', 0.1),
                  OcrLine('2024-03-01', 0.5),
                  OcrLine('Total 5000', 0.9),
                ],
              ),
            ),
          ),
          parserProvider.overrideWithValue(RuleBasedParser()),
        ],
      );

      final controller = container.read(scanControllerProvider.notifier);
      expect(container.read(scanControllerProvider).status, ScanStateStatus.idle);

      await controller.processImage('dummy_path.jpg');
      final state = container.read(scanControllerProvider);

      expect(state.status, ScanStateStatus.ready);
      expect(state.parsed, isNotNull);
      expect(state.parsed!.totalMinor, 5000);
      expect(state.parsed!.merchant, 'Starbucks');
    });

    test('handles empty OCR result', () async {
      final container = ProviderContainer(
        overrides: [
          ocrServiceProvider.overrideWithValue(
            FakeOcrService(
              resultToReturn: const OcrResult(fullText: '', lines: []),
            ),
          ),
          parserProvider.overrideWithValue(RuleBasedParser()),
        ],
      );

      final controller = container.read(scanControllerProvider.notifier);
      await controller.processImage('dummy_path.jpg');
      final state = container.read(scanControllerProvider);

      expect(state.status, ScanStateStatus.ready);
      expect(state.parsed!.totalMinor, isNull);
    });

    test('handles OCR exception / failure', () async {
      final container = ProviderContainer(
        overrides: [
          ocrServiceProvider.overrideWithValue(
            FakeOcrService(
              resultToReturn: const OcrResult(fullText: '', lines: []),
              shouldThrow: true,
            ),
          ),
          parserProvider.overrideWithValue(RuleBasedParser()),
        ],
      );

      final controller = container.read(scanControllerProvider.notifier);
      await controller.processImage('dummy_path.jpg');
      final state = container.read(scanControllerProvider);

      expect(state.status, ScanStateStatus.failed);
      expect(state.errorMessage, contains('OCR hardware failure'));
    });
  });
}
