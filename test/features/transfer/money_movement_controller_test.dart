import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pkash/core/network/api_exception.dart';
import 'package:pkash/features/transactions/domain/transaction.dart';
import 'package:pkash/features/transfer/presentation/money_movement_controller.dart';

void main() {
  group('MoneyMovementController Tests (§7.2 & §10.3)', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      container.listen(moneyMovementControllerProvider, (_, _) {});
    });

    tearDown(() {
      container.dispose();
    });

    test('generates fresh idempotency key upon entering review', () {
      final controller = container.read(moneyMovementControllerProvider.notifier);

      expect(container.read(moneyMovementControllerProvider).stage, MoneyFlowStage.form);
      expect(container.read(moneyMovementControllerProvider).idempotencyKey, isNull);

      controller.enterReview();
      expect(container.read(moneyMovementControllerProvider).stage, MoneyFlowStage.review);
      final key1 = container.read(moneyMovementControllerProvider).idempotencyKey;
      expect(key1, isNotNull);

      // Going back to form and re-entering review produces a new key (new intent)
      controller.backToForm();
      expect(container.read(moneyMovementControllerProvider).stage, MoneyFlowStage.form);

      controller.enterReview();
      final key2 = container.read(moneyMovementControllerProvider).idempotencyKey;
      expect(key2, isNotNull);
      expect(key1, isNot(equals(key2)));
    });

    test('reaches success stage upon successful operation and sets transaction', () async {
      final controller = container.read(moneyMovementControllerProvider.notifier);
      controller.enterReview();
      final key = container.read(moneyMovementControllerProvider).idempotencyKey!;

      final sampleTx = Transaction(
        id: 101,
        type: 'TOP_UP',
        amount: Decimal.fromInt(100),
        idempotencyKey: key,
      );

      await controller.submit((idempotencyKey) async {
        expect(idempotencyKey, key);
        return sampleTx;
      });

      expect(container.read(moneyMovementControllerProvider).stage, MoneyFlowStage.success);
      expect(container.read(moneyMovementControllerProvider).transaction, sampleTx);
    });

    test('handles 4xx definite failure correctly', () async {
      final controller = container.read(moneyMovementControllerProvider.notifier);
      controller.enterReview();

      await controller.submit((idempotencyKey) async {
        throw const ApiException(
          statusCode: 422,
          message: 'Insufficient balance.',
          fieldErrors: {'amount': 'Exceeds available balance.'},
        );
      });

      expect(container.read(moneyMovementControllerProvider).stage, MoneyFlowStage.failed);
      expect(container.read(moneyMovementControllerProvider).errorMessage, 'Insufficient balance.');
      expect(container.read(moneyMovementControllerProvider).fieldErrors['amount'], 'Exceeds available balance.');
    });

    test('handles timeout / network drop with unknown outcome retry using SAME key', () async {
      final controller = container.read(moneyMovementControllerProvider.notifier);
      controller.enterReview();
      final key = container.read(moneyMovementControllerProvider).idempotencyKey!;

      final sampleTx = Transaction(
        id: 102,
        type: 'TOP_UP',
        amount: Decimal.fromInt(200),
        idempotencyKey: key,
      );

      int attempts = 0;
      await controller.submit((idempotencyKey) async {
        attempts++;
        expect(idempotencyKey, key); // MUST BE SAME KEY
        if (attempts == 1) {
          throw const NetworkException(message: 'Connection timeout');
        }
        return sampleTx;
      });

      expect(attempts, 2);
      expect(container.read(moneyMovementControllerProvider).stage, MoneyFlowStage.success);
      expect(container.read(moneyMovementControllerProvider).transaction, sampleTx);
    });
  });
}
