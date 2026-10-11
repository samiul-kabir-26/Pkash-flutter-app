import 'transaction.dart';

enum TransactionDirection {
  inbound,  // Money coming in (+ credit)
  outbound, // Money going out (- debit)
}

TransactionDirection directionFor(Transaction tx, int myUserId) {
  final type = tx.type.toUpperCase();

  switch (type) {
    case 'TOP_UP':
      return TransactionDirection.inbound;

    case 'TRANSFER':
      if (tx.senderId == myUserId) {
        return TransactionDirection.outbound;
      }
      return TransactionDirection.inbound;

    case 'CASH_IN':
      // For agent (whose wallet is deducted to give cash to user): outbound
      if (tx.agentId == myUserId && tx.initiatedBy != myUserId) {
        return TransactionDirection.outbound;
      }
      // For user: inbound (wallet credited)
      return TransactionDirection.inbound;

    case 'CASH_OUT':
      // For user: outbound (wallet debited)
      if (tx.senderId == myUserId || (tx.userId == myUserId && tx.agentId != myUserId)) {
        return TransactionDirection.outbound;
      }
      // For agent: inbound (agent receives money)
      return TransactionDirection.inbound;

    case 'AGENT_WITHDRAWAL':
      return TransactionDirection.outbound;

    case 'COMMISSION_PAYOUT':
      return TransactionDirection.inbound;

    default:
      if (tx.senderId == myUserId) {
        return TransactionDirection.outbound;
      }
      return TransactionDirection.inbound;
  }
}
