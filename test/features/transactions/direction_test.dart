import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pkash/features/transactions/domain/transaction.dart';
import 'package:pkash/features/transactions/domain/transaction_direction.dart';

void main() {
  group('Transaction Direction Tests', () {
    test('TOP_UP is always inbound for user', () {
      final tx = Transaction(
        id: 1,
        type: 'TOP_UP',
        amount: Decimal.fromInt(100),
        recipientId: 10,
        initiatedBy: 10,
      );
      expect(directionFor(tx, 10), TransactionDirection.inbound);
    });

    test('TRANSFER is outbound for sender and inbound for recipient', () {
      final tx = Transaction(
        id: 2,
        type: 'TRANSFER',
        amount: Decimal.fromInt(500),
        senderId: 10,
        recipientId: 20,
      );
      expect(directionFor(tx, 10), TransactionDirection.outbound);
      expect(directionFor(tx, 20), TransactionDirection.inbound);
    });

    test('CASH_IN is inbound for user and outbound for agent', () {
      final tx = Transaction(
        id: 3,
        type: 'CASH_IN',
        amount: Decimal.fromInt(200),
        agentId: 5,
        recipientId: 10,
        initiatedBy: 10,
      );
      // User receives cash
      expect(directionFor(tx, 10), TransactionDirection.inbound);
      // Agent gives out cash
      expect(directionFor(tx, 5), TransactionDirection.outbound);
    });

    test('CASH_OUT is outbound for user and inbound for agent', () {
      final tx = Transaction(
        id: 4,
        type: 'CASH_OUT',
        amount: Decimal.fromInt(300),
        senderId: 10,
        agentId: 5,
        initiatedBy: 10,
      );
      // User loses wallet balance
      expect(directionFor(tx, 10), TransactionDirection.outbound);
      // Agent gains wallet balance
      expect(directionFor(tx, 5), TransactionDirection.inbound);
    });

    test('COMMISSION_PAYOUT is inbound for agent', () {
      final tx = Transaction(
        id: 5,
        type: 'COMMISSION_PAYOUT',
        amount: Decimal.parse('5.50'),
        agentId: 5,
        recipientId: 5,
      );
      expect(directionFor(tx, 5), TransactionDirection.inbound);
    });

    test('AGENT_WITHDRAWAL is outbound for agent', () {
      final tx = Transaction(
        id: 6,
        type: 'AGENT_WITHDRAWAL',
        amount: Decimal.fromInt(1000),
        agentId: 5,
        senderId: 5,
      );
      expect(directionFor(tx, 5), TransactionDirection.outbound);
    });
  });
}
