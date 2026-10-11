import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/money/money.dart';
import '../../transactions/domain/transaction.dart';

class ReceiptScreen extends StatelessWidget {
  final Transaction transaction;

  const ReceiptScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = transaction.createdAt != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(transaction.createdAt!.toLocal())
        : DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        context.go('/user/home');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transaction Receipt'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: 64,
                      color: Colors.green.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Transaction Successful',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  formatBdt(transaction.amount),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildReceiptRow('Transaction ID', '#${transaction.id}'),
                        _buildReceiptRow('Type', transaction.type.replaceAll('_', ' ')),
                        _buildReceiptRow('Date & Time', dateStr),
                        if (transaction.recipientId != null)
                          _buildReceiptRow('Recipient ID', '${transaction.recipientId}'),
                        if (transaction.agentId != null)
                          _buildReceiptRow('Agent ID', '${transaction.agentId}'),
                        if (transaction.fee > Decimal.zero)
                          _buildReceiptRow('System Fee', formatBdt(transaction.fee)),
                        if (transaction.commission > Decimal.zero)
                          _buildReceiptRow('Commission', formatBdt(transaction.commission)),
                        if (transaction.senderWalletBalanceAfter != null)
                          _buildReceiptRow(
                            'New Balance',
                            formatBdt(transaction.senderWalletBalanceAfter!),
                            isHighlight: true,
                          ),
                        if (transaction.recipientWalletBalanceAfter != null &&
                            transaction.senderWalletBalanceAfter == null)
                          _buildReceiptRow(
                            'New Balance',
                            formatBdt(transaction.recipientWalletBalanceAfter!),
                            isHighlight: true,
                          ),
                        if (transaction.description != null && transaction.description!.isNotEmpty)
                          _buildReceiptRow('Note', transaction.description!),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () {
                    context.go('/user/home');
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Back to Home'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              fontSize: isHighlight ? 16 : 14,
              color: isHighlight ? Colors.green.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
