import 'package:meta/meta.dart';

@immutable
class OcrLine {
  final String text;
  final double top; // normalized 0..1 from top of image; used for merchant detection

  const OcrLine(this.text, this.top);
}

@immutable
class OcrResult {
  final String fullText;
  final List<OcrLine> lines;

  const OcrResult({required this.fullText, required this.lines});

  bool get isEmpty => fullText.trim().isEmpty;
}
