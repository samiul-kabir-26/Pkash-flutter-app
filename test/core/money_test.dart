import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pkash/core/money/money.dart';

void main() {
  group('Money Helpers Tests', () {
    test('parseMoney parses num, string, and null correctly without precision loss', () {
      expect(parseMoney(null), Decimal.zero);
      expect(parseMoney(''), Decimal.zero);
      expect(parseMoney('  '), Decimal.zero);
      expect(parseMoney(100), Decimal.fromInt(100));
      expect(parseMoney(100.5), Decimal.parse('100.5'));
      expect(parseMoney('1234.56'), Decimal.parse('1234.56'));
      expect(parseMoney('0.10'), Decimal.parse('0.10'));
    });

    test('toApiAmount produces formatted 2-decimal string', () {
      expect(toApiAmount(Decimal.parse('100')), '100.00');
      expect(toApiAmount(Decimal.parse('50.5')), '50.50');
      expect(toApiAmount(Decimal.parse('1234.56')), '1234.56');
    });

    test('formatBdt produces BDT formatted string', () {
      final formatted = formatBdt(Decimal.parse('1234.50'));
      expect(formatted.contains('1,234.50'), isTrue);
      expect(formatted.contains('৳'), isTrue);
    });

    test('Decimal arithmetic avoids float precision drift (0.1 + 0.2)', () {
      final d1 = parseMoney('0.1');
      final d2 = parseMoney('0.2');
      final sum = d1 + d2;
      expect(sum, Decimal.parse('0.3'));
      expect(toApiAmount(sum), '0.30');
    });

    test('formatRate turns server rates into percentages', () {
      expect(formatRate('0.0100'), '1%');
      expect(formatRate(0.05), '5%');
      expect(formatRate('0.0125'), '1.25%');
      expect(formatRate(0.1), '10%');
    });
  });
}
