import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pkash/features/auth/domain/panel.dart';
import 'package:pkash/features/transactions/domain/transaction.dart';
import 'package:pkash/features/transactions/domain/transaction_direction.dart';

const me = 10;
const other = 20;

Transaction tx(String type, {int? senderId, Decimal? fee}) => Transaction(
      id: 1,
      type: type,
      amount: Decimal.fromInt(100),
      senderId: senderId,
      systemFeeAmount: fee,
    );

void main() {
  group('directionFor — every row of the §7.7 table', () {
    final cases = <(Panel, Transaction, TransactionDirection)>[
      (Panel.user, tx('TOP_UP'), TransactionDirection.credit),
      (Panel.user, tx('CASH_IN'), TransactionDirection.credit),
      (Panel.user, tx('CASH_OUT', senderId: me), TransactionDirection.debit),
      (Panel.user, tx('TRANSFER', senderId: me), TransactionDirection.debit),
      (Panel.user, tx('TRANSFER', senderId: other), TransactionDirection.credit),
      (Panel.agent, tx('CASH_IN'), TransactionDirection.debit),
      (Panel.agent, tx('CASH_OUT', senderId: other), TransactionDirection.credit),
      (Panel.agent, tx('COMMISSION_PAYOUT'), TransactionDirection.credit),
      (Panel.agent, tx('AGENT_WITHDRAWAL', senderId: me), TransactionDirection.debit),
    ];

    for (final (panel, transaction, expected) in cases) {
      test('${panel.name} ${transaction.type} (sender ${transaction.senderId}) → ${expected.name}', () {
        expect(directionFor(transaction, panel: panel, myUserId: me), expected);
      });
    }

    test('unknown type is neutral with no sign, so a new backend type cannot crash the list', () {
      final unknown = tx('SOMETHING_NEW');
      expect(directionFor(unknown, panel: Panel.user, myUserId: me), TransactionDirection.neutral);
      expect(directionFor(unknown, panel: Panel.agent, myUserId: me), TransactionDirection.neutral);
      expect(signFor(TransactionDirection.neutral), '');
    });

    test('a dual-role person: same CASH_OUT row reads differently per panel', () {
      final cashOut = tx('CASH_OUT', senderId: me);
      expect(directionFor(cashOut, panel: Panel.user, myUserId: me), TransactionDirection.debit);
      expect(directionFor(cashOut, panel: Panel.agent, myUserId: me), TransactionDirection.credit);
    });
  });

  group('walletAmountFor', () {
    test('customer cash-out debits amount + fee; agent is credited amount only', () {
      final cashOut = tx('CASH_OUT', senderId: me, fee: Decimal.parse('5.00'));
      expect(walletAmountFor(cashOut, panel: Panel.user), Decimal.parse('105.00'));
      expect(walletAmountFor(cashOut, panel: Panel.agent), Decimal.fromInt(100));
    });

    test('other types move exactly amount', () {
      expect(walletAmountFor(tx('TRANSFER', senderId: me), panel: Panel.user), Decimal.fromInt(100));
    });
  });
}
