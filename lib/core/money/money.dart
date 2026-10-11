import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

Decimal parseMoney(Object? json) {
  if (json == null) {
    return Decimal.zero;
  }
  if (json is num) {
    return Decimal.parse(json.toString());
  }
  if (json is String) {
    final trimmed = json.trim();
    if (trimmed.isEmpty) return Decimal.zero;
    return Decimal.parse(trimmed);
  }
  return Decimal.parse(json.toString());
}

String formatBdt(Decimal amount, {bool showSymbol = true}) {
  // Convert Decimal to formatted currency string with exactly 2 fraction digits.
  final formatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: showSymbol ? '৳' : '',
    decimalDigits: 2,
  );
  // Decimal.toDouble() for display formatting with NumberFormat
  return formatter.format(amount.toDouble());
}

String toApiAmount(Decimal amount) {
  return amount.toStringAsFixed(2);
}
