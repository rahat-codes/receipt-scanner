import 'package:intl/intl.dart';

/// Represents monetary value stored in integer minor units (e.g. cents for USD, won for KRW).
/// WHY: Floating point arithmetic leads to rounding errors in financial calculations.
class Money {
  final int minorUnits;
  final String currency; // 'KRW' | 'USD'

  const Money(this.minorUnits, {this.currency = 'KRW'});

  double get majorUnits {
    if (currency == 'USD') {
      return minorUnits / 100.0;
    }
    return minorUnits.toDouble();
  }

  String format([String? locale]) {
    if (currency == 'USD') {
      final format = NumberFormat.currency(locale: locale ?? 'en_US', symbol: '\$', decimalDigits: 2);
      return format.format(majorUnits);
    } else {
      final format = NumberFormat.currency(locale: locale ?? 'ko_KR', symbol: '₩', decimalDigits: 0);
      return format.format(majorUnits);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money && runtimeType == other.runtimeType && minorUnits == other.minorUnits && currency == other.currency;

  @override
  int get hashCode => minorUnits.hashCode ^ currency.hashCode;

  @override
  String toString() => format();
}
