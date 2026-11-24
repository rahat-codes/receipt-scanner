import '../entities/ocr_result.dart';
import '../entities/parsed_receipt.dart';

abstract class ReceiptParser {
  Future<ParsedReceipt> parse(OcrResult ocr);
}
