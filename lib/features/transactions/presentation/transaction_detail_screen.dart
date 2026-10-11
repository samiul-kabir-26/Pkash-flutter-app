import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/money/money.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../auth/presentation/session_controller.dart';
import '../data/transaction_repository.dart';
import '../domain/transaction.dart';
import '../domain/transaction_direction.dart';

final singleTransactionProvider =
    FutureProvider.autoDispose.family<Transaction, int>((ref, id) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getTransaction(id);
});

class TransactionDetailScreen extends ConsumerWidget {
  final int transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final txAsync = ref.watch(singleTransactionProvider(transactionId));
    final session = ref.watch(sessionControllerProvider).value;
    final myId = session?.user.id ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction #$transactionId'),
      ),
      body: AsyncValueView<Transaction>(
        value: txAsync,
        onRetry: () => ref.invalidate(singleTransactionProvider(transactionId)),
        data: (tx) {
          final dir = directionFor(tx, myId);
          final isInbound = dir == TransactionDirection.inbound;
          final dateStr = tx.createdAt != null
              ? DateFormat('dd MMMM yyyy, hh:mm:ss a').format(tx.createdAt!.toLocal())
              : 'N/A';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isInbound ? Colors.green.shade50 : Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isInbound ? Icons.arrow_downward : Icons.arrow_upward,
                      size: 48,
                      color: isInbound ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${isInbound ? '+' : '-'}${formatBdt(tx.amount)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isInbound ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tx.type.replaceAll('_', ' '),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: tx.isCompleted
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tx.status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: tx.isCompleted
                            ? Colors.green.shade800
                            : Colors.orange.shade800,
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
                        if (tx.senderId != null) _buildRow('Sender ID', '#${tx.senderId}'),
                        if (tx.recipientId != null) _buildRow('Recipient ID', '#${tx.recipientId}'),
                        if (tx.agentId != null) _buildRow('Agent ID', '#${tx.agentId}'),
                        if (tx.fee > Decimal.zero) _buildRow('System Fee', formatBdt(tx.fee)),
                        if (tx.commission > Decimal.zero)
                          _buildRow('Commission', formatBdt(tx.commission)),
                        if (tx.senderWalletBalanceAfter != null && tx.senderId == myId)
                          _buildRow('Balance After', formatBdt(tx.senderWalletBalanceAfter!)),
                        if (tx.recipientWalletBalanceAfter != null && tx.recipientId == myId)
                          _buildRow('Balance After', formatBdt(tx.recipientWalletBalanceAfter!)),
                        if (tx.description != null && tx.description!.isNotEmpty)
                          _buildRow('Note', tx.description!),
                        if (tx.idempotencyKey != null)
                          _buildRow('Reference', tx.idempotencyKey!),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
