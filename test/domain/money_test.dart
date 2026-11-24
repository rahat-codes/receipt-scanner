import 'package:flutter_test/flutter_test.dart';
import 'package:receiptscanner/domain/entities/money.dart';

void main() {
  group('Money Entity', () {
    test('KRW formatting and major units', () {
      const money = Money(15400, currency: 'KRW');
      expect(money.majorUnits, 15400.0);
      expect(money.format('ko_KR'), '₩15,400');
    });

    test('USD formatting and major units', () {
      const money = Money(1299, currency: 'USD');
      expect(money.majorUnits, 12.99);
      expect(money.format('en_US'), '\$12.99');
    });
  });
}
