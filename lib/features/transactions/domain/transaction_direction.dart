import 'package:decimal/decimal.dart';
import '../../auth/domain/panel.dart';
import 'transaction.dart';

enum TransactionDirection {
  credit, // Money coming in (+)
  debit, // Money going out (-)
  neutral, // Unknown type: no sign, never crash the list
}

/// History is already scoped to the token's wallet, so the direction only depends on
/// the panel and the type (§7.7). Wallet IDs are hidden from non-staff and not needed.
TransactionDirection directionFor(
  Transaction tx, {
  required Panel panel,
  required int myUserId,
}) {
  final type = tx.type.toUpperCase();

  switch (panel) {
    case Panel.user:
      switch (type) {
        case 'TOP_UP':
        case 'CASH_IN':
          return TransactionDirection.credit;
        case 'CASH_OUT':
          return TransactionDirection.debit;
        case 'TRANSFER':
          return tx.senderId == myUserId ? TransactionDirection.debit : TransactionDirection.credit;
      }
    case Panel.agent:
      switch (type) {
        case 'CASH_IN':
        case 'AGENT_WITHDRAWAL':
          return TransactionDirection.debit;
        case 'CASH_OUT':
        case 'COMMISSION_PAYOUT':
          return TransactionDirection.credit;
      }
  }
  return TransactionDirection.neutral;
}

/// The amount that actually moved on the viewer's wallet. A customer's cash-out debits
/// `amount + system_fee_amount`; the agent's side of it is credited `amount` only.
Decimal walletAmountFor(Transaction tx, {required Panel panel}) {
  if (panel == Panel.user && tx.type.toUpperCase() == 'CASH_OUT') {
    return tx.amount + tx.fee;
  }
  return tx.amount;
}

String signFor(TransactionDirection direction) => switch (direction) {
      TransactionDirection.credit => '+',
      TransactionDirection.debit => '-',
      TransactionDirection.neutral => '',
    };
