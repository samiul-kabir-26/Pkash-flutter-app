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

/// `0.0100` → `1%`, `0.05` → `5%`, `0.0125` → `1.25%` (up to 2 decimals).
String formatRate(Object? json) {
  final percent = parseMoney(json) * Decimal.fromInt(100);
  var text = percent.toStringAsFixed(2);
  if (text.contains('.')) {
    text = text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
  return '$text%';
}
