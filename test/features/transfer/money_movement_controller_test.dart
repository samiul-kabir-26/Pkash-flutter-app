import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pkash/core/network/api_exception.dart';
import 'package:pkash/features/transactions/domain/transaction.dart';
import 'package:pkash/features/transfer/presentation/money_movement_controller.dart';

final intent = MoneyIntent(
  type: 'TRANSFER',
  amount: Decimal.parse('500.00'),
  counterparty: '42',
  description: 'rent',
);

Transaction txFor(MoneyIntent intent, {int id = 101}) =>
    Transaction(id: id, type: intent.type, amount: intent.amount);

void main() {
  group('MoneyMovementController (§7.2, §10.3)', () {
    late ProviderContainer container;

    MoneyMovementController controller() => container.read(moneyMovementControllerProvider.notifier);
    MoneyMovementState state() => container.read(moneyMovementControllerProvider);

    setUp(() {
      container = ProviderContainer(
        overrides: [
          moneyFlowRetryDelaysProvider.overrideWithValue(const [Duration.zero, Duration.zero, Duration.zero]),
        ],
      );
      container.listen(moneyMovementControllerProvider, (_, _) {});
    });

    tearDown(() => container.dispose());

    test('creates the key on entering Review', () {
      expect(state().idempotencyKey, isNull);
      controller().enterReview(intent);
      expect(state().stage, MoneyFlowStage.review);
      expect(state().idempotencyKey, isNotNull);
    });

    test('same intent after going back keeps the key; any payload change gets a new key', () {
      controller().enterReview(intent);
      final key1 = state().idempotencyKey;

      controller().backToForm();
      controller().enterReview(intent);
      expect(state().idempotencyKey, key1);

      for (final changed in [
        MoneyIntent(type: 'TRANSFER', amount: Decimal.parse('600.00'), counterparty: '42', description: 'rent'),
        MoneyIntent(type: 'TRANSFER', amount: Decimal.parse('500.00'), counterparty: '43', description: 'rent'),
        MoneyIntent(type: 'TRANSFER', amount: Decimal.parse('500.00'), counterparty: '42', description: 'food'),
      ]) {
        final before = state().idempotencyKey;
        controller().backToForm();
        controller().enterReview(changed);
        expect(state().idempotencyKey, isNot(before));
      }
    });

    test('success: uses the review key, stores the receipt, discards the key', () async {
      controller().enterReview(intent);
      final key = state().idempotencyKey!;

      await controller().submit((k) async {
        expect(k, key);
        return txFor(intent);
      });

      expect(state().stage, MoneyFlowStage.success);
      expect(state().transaction!.id, 101);
      expect(state().receiptMismatch, isFalse);
      expect(state().idempotencyKey, isNull);
    });

    test('first-attempt 4xx is a definite failure; a new attempt gets a new key', () async {
      controller().enterReview(intent);
      final key = state().idempotencyKey;

      await controller().submit((_) async {
        throw const ApiException(
          statusCode: 422,
          message: 'Insufficient balance.',
          fieldErrors: {'amount': 'Exceeds available balance.'},
        );
      });

      expect(state().stage, MoneyFlowStage.failed);
      expect(state().errorMessage, 'Insufficient balance.');
      expect(state().fieldErrors['amount'], 'Exceeds available balance.');

      controller().enterReview(intent);
      expect(state().idempotencyKey, isNot(key));
    });

    test('timeout → unknown → retry with the SAME key → success exactly once', () async {
      controller().enterReview(intent);
      final keys = <String>[];

      await controller().submit((k) async {
        keys.add(k);
        if (keys.length == 1) throw const NetworkException();
        return txFor(intent);
      });

      expect(keys, hasLength(2));
      expect(keys.toSet(), hasLength(1));
      expect(state().stage, MoneyFlowStage.success);
    });

    test('timeout → retry returns 409 → unknown, not failed (G7)', () async {
      controller().enterReview(intent);
      var attempts = 0;

      await controller().submit((_) async {
        attempts++;
        if (attempts == 1) throw const NetworkException();
        throw const ApiException(statusCode: 409, message: 'Agent is not approved.');
      });

      expect(attempts, 2);
      expect(state().stage, MoneyFlowStage.unknownOutcome);
      expect(state().isRetrying, isFalse);
    });

    test('network keeps failing → gives up after the retries, still unknown, never a new key', () async {
      controller().enterReview(intent);
      final keys = <String>{};
      var attempts = 0;

      await controller().submit((k) async {
        attempts++;
        keys.add(k);
        throw const NetworkException();
      });

      expect(attempts, 4); // first attempt + 3 retries
      expect(keys, hasLength(1));
      expect(state().stage, MoneyFlowStage.unknownOutcome);
    });

    test('receipt mismatch (returned amount ≠ submitted) is detected', () async {
      controller().enterReview(intent);

      await controller().submit((_) async => Transaction(
            id: 7,
            type: 'TRANSFER',
            amount: Decimal.parse('100.00'),
          ));

      expect(state().stage, MoneyFlowStage.success);
      expect(state().receiptMismatch, isTrue);
      expect(state().transaction!.amount, Decimal.parse('100.00'));
    });

    test('Confirm cannot fire twice while submitting', () async {
      controller().enterReview(intent);
      var calls = 0;

      final first = controller().submit((_) async {
        calls++;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return txFor(intent);
      });
      await controller().submit((_) async {
        calls++;
        return txFor(intent, id: 999);
      });
      await first;

      expect(calls, 1);
      expect(state().transaction!.id, 101);
    });
  });
}
