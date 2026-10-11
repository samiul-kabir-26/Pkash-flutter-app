import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pkash/core/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    test('validatePhone validates Bangladeshi phone format', () {
      expect(Validators.validatePhone('01712345678'), isNull);
      expect(Validators.validatePhone('01812345678'), isNull);
      expect(Validators.validatePhone('01912345678'), isNull);
      expect(Validators.validatePhone('01312345678'), isNull);
      expect(Validators.validatePhone('01412345678'), isNull);
      expect(Validators.validatePhone('01512345678'), isNull);
      expect(Validators.validatePhone('01612345678'), isNull);

      // Invalid cases
      expect(Validators.validatePhone('01212345678'), isNotNull); // 012 not valid
      expect(Validators.validatePhone('0171234567'), isNotNull);  // 10 digits
      expect(Validators.validatePhone('017123456789'), isNotNull); // 12 digits
      expect(Validators.validatePhone('abcdefghijk'), isNotNull);
      expect(Validators.validatePhone(''), isNotNull);
      expect(Validators.validatePhone(null), isNotNull);
    });

    test('validatePin validates 5-10 numeric digits', () {
      expect(Validators.validatePin('12345'), isNull);
      expect(Validators.validatePin('01234'), isNull); // Leading zero preserved
      expect(Validators.validatePin('1234567890'), isNull);

      expect(Validators.validatePin('1234'), isNotNull); // 4 digits
      expect(Validators.validatePin('12345678901'), isNotNull); // 11 digits
      expect(Validators.validatePin('1234a'), isNotNull); // Non-digit
      expect(Validators.validatePin(null), isNotNull);
    });

    test('validatePinConfirmation checks equality', () {
      expect(Validators.validatePinConfirmation('12345', '12345'), isNull);
      expect(Validators.validatePinConfirmation('12345', '54321'), isNotNull);
      expect(Validators.validatePinConfirmation('', '12345'), isNotNull);
    });

    test('validateAmount validates positive amount with max 2 decimals', () {
      expect(Validators.validateAmount('50'), isNull);
      expect(Validators.validateAmount('50.50'), isNull);
      expect(Validators.validateAmount('0.05'), isNull);

      expect(Validators.validateAmount('0'), isNotNull);
      expect(Validators.validateAmount('-10'), isNotNull);
      expect(Validators.validateAmount('50.123'), isNotNull); // >2 decimals
      expect(Validators.validateAmount('abc'), isNotNull);
      expect(Validators.validateAmount(''), isNotNull);

      // Max balance test
      expect(
        Validators.validateAmount('100.00', maxAmount: Decimal.parse('50.00')),
        isNotNull,
      );
      expect(
        Validators.validateAmount('50.00', maxAmount: Decimal.parse('50.00')),
        isNull,
      );
    });

    test('validateId validates positive integer', () {
      expect(Validators.validateId('1'), isNull);
      expect(Validators.validateId('105'), isNull);

      expect(Validators.validateId('0'), isNotNull);
      expect(Validators.validateId('-5'), isNotNull);
      expect(Validators.validateId('1.5'), isNotNull);
      expect(Validators.validateId('abc'), isNotNull);
    });
  });
}
