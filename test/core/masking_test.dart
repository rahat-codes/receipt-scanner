import 'package:flutter_test/flutter_test.dart';
import 'package:receiptscanner/core/masking.dart';

void main() {
  group('Sensitive Text Masking', () {
    test('masks credit card numbers and long numbers', () {
      final input = 'Card: 1234-5678-9012-3456 and Phone: 010-1234-5678 and Total: 4,300';
      final masked = maskSensitiveText(input);
      expect(masked, contains('****-****-****-****'));
      expect(masked, contains('***-****-****'));
      expect(masked, contains('4,300')); // short amount preserved
    });
  });
}
