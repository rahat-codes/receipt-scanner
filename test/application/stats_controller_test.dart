import 'package:flutter_test/flutter_test.dart';
import 'package:receiptscanner/application/stats_controller.dart';

void main() {
  group('StatsController Pure Logic Tests', () {
    test('calculatePercents handles zero total', () {
      final percents = calculatePercents([0, 0, 0]);
      expect(percents, [0.0, 0.0, 0.0]);
    });

    test('calculatePercents sums to 100 within rounding for valid totals', () {
      final amounts = [5000, 3000, 2000];
      final percents = calculatePercents(amounts);
      expect(percents, [50.0, 30.0, 20.0]);
      final sum = percents.fold(0.0, (s, p) => s + p);
      expect(sum, closeTo(100.0, 0.01));
    });

    test('abbreviateAmount formats Korean locale correctly', () {
      expect(abbreviateAmount(184000, 'KRW', 'ko'), '18.4만');
      expect(abbreviateAmount(180000, 'KRW', 'ko'), '18만');
      expect(abbreviateAmount(5000, 'KRW', 'ko'), '5천');
      expect(abbreviateAmount(500, 'KRW', 'ko'), '500');
    });

    test('abbreviateAmount formats English locale correctly', () {
      expect(abbreviateAmount(184000, 'KRW', 'en'), '₩184K');
      expect(abbreviateAmount(1299, 'USD', 'en'), '\$12.99');
      expect(abbreviateAmount(150000, 'USD', 'en'), '\$1.5K');
    });
  });
}
