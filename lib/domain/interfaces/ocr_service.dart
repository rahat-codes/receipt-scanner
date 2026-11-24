import '../entities/ocr_result.dart';

abstract class OcrService {
  Future<OcrResult> read(String imagePath);
}
