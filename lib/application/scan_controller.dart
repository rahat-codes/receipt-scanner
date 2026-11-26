import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers.dart';
import '../domain/entities/parsed_receipt.dart';

enum ScanStateStatus { idle, reading, parsing, ready, failed }

class ScanState {
  final ScanStateStatus status;
  final ParsedReceipt? parsed;
  final String? imagePath;
  final String? errorMessage;

  const ScanState({
    this.status = ScanStateStatus.idle,
    this.parsed,
    this.imagePath,
    this.errorMessage,
  });

  ScanState copyWith({
    ScanStateStatus? status,
    ParsedReceipt? parsed,
    String? imagePath,
    String? errorMessage,
  }) {
    return ScanState(
      status: status ?? this.status,
      parsed: parsed ?? this.parsed,
      imagePath: imagePath ?? this.imagePath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ScanController extends StateNotifier<ScanState> {
  final Ref ref;

  ScanController(this.ref) : super(const ScanState());

  Future<void> processImage(String imagePath) async {
    state = state.copyWith(status: ScanStateStatus.reading, imagePath: imagePath);
    try {
      final ocrService = ref.read(ocrServiceProvider);
      final ocrResult = await ocrService.read(imagePath);

      if (ocrResult.isEmpty) {
        state = state.copyWith(
          status: ScanStateStatus.ready,
          parsed: const ParsedReceipt(confidence: 0.0, needsReview: {FieldFlag.merchant, FieldFlag.date, FieldFlag.total}),
        );
        return;
      }

      state = state.copyWith(status: ScanStateStatus.parsing);
      final parser = ref.read(parserProvider);
      final parsed = await parser.parse(ocrResult);

      state = state.copyWith(
        status: ScanStateStatus.ready,
        parsed: parsed,
      );
    } catch (e) {
      state = state.copyWith(
        status: ScanStateStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const ScanState();
  }
}

final scanControllerProvider = StateNotifierProvider<ScanController, ScanState>((ref) {
  return ScanController(ref);
});
