import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../domain/entities/ocr_result.dart';
import '../../domain/interfaces/ocr_service.dart';

class MlKitOcrService implements OcrService {
  @override
  Future<OcrResult> read(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    // WHY: Use Korean script recognizer which also supports Latin text and digits per Section 2 & 6.3.
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);
    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      final lines = <OcrLine>[];
      
      // We estimate bounding box top normalization (0..1) if image height is available,
      // or use text blocks position. Here we parse blocks/lines.
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          final rect = line.boundingBox;
          // Approximate top ratio (assuming standard height or relative positioning)
          final top = rect.top > 0 ? rect.top / 1000.0 : 0.0;
          lines.add(OcrLine(line.text, top));
        }
      }

      return OcrResult(
        fullText: recognizedText.text,
        lines: lines.isNotEmpty ? lines : [OcrLine(recognizedText.text, 0.0)],
      );
    } finally {
      await textRecognizer.close();
    }
  }
}
