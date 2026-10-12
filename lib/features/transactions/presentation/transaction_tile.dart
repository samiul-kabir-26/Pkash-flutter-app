import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/money/money.dart';
import '../../auth/domain/panel.dart';
import '../domain/transaction.dart';
import '../domain/transaction_direction.dart';

String transactionTypeLabel(String type, {required Panel panel}) {
  return switch (type.toUpperCase()) {
    'TOP_UP' => 'Top-up',
    'TRANSFER' => 'Transfer',
    'CASH_IN' => 'Cash-in',
    'CASH_OUT' => 'Cash-out',
    'AGENT_WITHDRAWAL' => 'Withdrawal',
    'COMMISSION_PAYOUT' => 'Commission',
    _ => type.replaceAll('_', ' '),
  };
}

/// One history row: icon, type, local time, signed amount (§7.7).
class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final Panel panel;
  final int myUserId;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.panel,
    required this.myUserId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tx = transaction;
    final dir = directionFor(tx, panel: panel, myUserId: myUserId);
    final color = switch (dir) {
      TransactionDirection.credit => Colors.green.shade700,
      TransactionDirection.debit => Colors.red.shade700,
      TransactionDirection.neutral => Colors.grey.shade700,
    };
    final background = switch (dir) {
      TransactionDirection.credit => Colors.green.shade50,
      TransactionDirection.debit => Colors.red.shade50,
      TransactionDirection.neutral => Colors.grey.shade100,
    };
    final icon = switch (dir) {
      TransactionDirection.credit => Icons.arrow_downward,
      TransactionDirection.debit => Icons.arrow_upward,
      TransactionDirection.neutral => Icons.swap_horiz,
    };
    final dateFormatted = tx.createdAt != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(tx.createdAt!.toLocal())
        : '';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: background,
        child: Icon(icon, color: color),
      ),
      title: Text(
        transactionTypeLabel(tx.type, panel: panel),
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        dateFormatted,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${signFor(dir)}${formatBdt(walletAmountFor(tx, panel: panel))}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
          ),
          if (!tx.isCompleted)
            Text(
              tx.status,
              style: TextStyle(fontSize: 11, color: Colors.orange.shade800),
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}
