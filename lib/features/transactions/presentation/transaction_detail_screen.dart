import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/money/money.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/presentation/session_controller.dart';
import '../domain/transaction.dart';
import '../domain/transaction_direction.dart';
import 'transaction_providers.dart';
import 'transaction_tile.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final int transactionId;
  final Panel panel;

  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
    required this.panel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(singleTransactionProvider(transactionId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction #$transactionId'),
      ),
      body: txAsync.when(
        data: (tx) => _buildDetail(context, ref, tx),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildError(ref, error),
      ),
    );
  }

  Widget _buildError(WidgetRef ref, Object error) {
    // §7.8: 403 = not your wallet's transaction, 404 = doesn't exist.
    final message = switch (error) {
      ApiException(isForbidden: true) => 'Not available.',
      ApiException(isNotFound: true) => 'Not found.',
      NetworkException() => 'No connection.',
      _ => 'Something went wrong.',
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(singleTransactionProvider(transactionId)),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, WidgetRef ref, Transaction tx) {
    final theme = Theme.of(context);
    final myId = ref.watch(sessionControllerProvider).value?.user.id ?? 0;
    final dir = directionFor(tx, panel: panel, myUserId: myId);
    final color = switch (dir) {
      TransactionDirection.credit => Colors.green.shade700,
      TransactionDirection.debit => Colors.red.shade700,
      TransactionDirection.neutral => Colors.grey.shade700,
    };
    final dateStr = tx.createdAt != null
        ? DateFormat('dd MMMM yyyy, hh:mm:ss a').format(tx.createdAt!.toLocal())
        : 'N/A';
    final historyPrefix = panel == Panel.agent ? '/agent/history' : '/user/history';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                switch (dir) {
                  TransactionDirection.credit => Icons.arrow_downward,
                  TransactionDirection.debit => Icons.arrow_upward,
                  TransactionDirection.neutral => Icons.swap_horiz,
                },
                size: 48,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${signFor(dir)}${formatBdt(walletAmountFor(tx, panel: panel))}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            transactionTypeLabel(tx.type, panel: panel),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: tx.isCompleted ? Colors.green.shade100 : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tx.status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: tx.isCompleted ? Colors.green.shade800 : Colors.orange.shade800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildRow('Transaction ID', '#${tx.id}'),
                  _buildRow('Date & Time', dateStr),
                  _buildRow('Amount', formatBdt(tx.amount)),
                  if (tx.type == 'TRANSFER') ...[
                    if (tx.senderId != null && tx.senderId != myId)
                      _buildRow('From user', '#${tx.senderId}'),
                    if (tx.recipientId != null && tx.recipientId != myId)
                      _buildRow('To user', '#${tx.recipientId}'),
                  ],
                  if (panel == Panel.agent &&
                      (tx.type == 'CASH_IN' || tx.type == 'CASH_OUT') &&
                      tx.userId != null)
                    _buildRow('Customer', '#${tx.userId}'),
                  if (tx.fee > Decimal.zero) _buildRow('Fee', formatBdt(tx.fee)),
                  if (panel == Panel.agent && tx.commission > Decimal.zero)
                    _buildRow('Commission', formatBdt(tx.commission)),
                  if (tx.myBalanceAfter != null)
                    _buildRow('Your balance after', formatBdt(tx.myBalanceAfter!)),
                  if (tx.description != null && tx.description!.isNotEmpty)
                    _buildRow('Note', tx.description!),
                ],
              ),
            ),
          ),
          if (tx.relatedTransactionId != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.link),
              label: Text('View related cash-out #${tx.relatedTransactionId}'),
              onPressed: () => context.push('$historyPrefix/${tx.relatedTransactionId}'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
