import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/money/money.dart';
import '../../transactions/domain/transaction.dart';

class ReceiptScreen extends StatelessWidget {
  final Transaction transaction;
  final String homeRoute;

  /// The server returned a different transaction than the one submitted (G7). The receipt
  /// always shows what the server returned, never the submitted values.
  final bool mismatch;

  const ReceiptScreen({
    super.key,
    required this.transaction,
    this.homeRoute = '/user/home',
    this.mismatch = false,
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
        context.go(homeRoute);
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
                if (mismatch) ...[
                  const SizedBox(height: 12),
                  Text(
                    'This receipt does not match what you submitted. Check your history before trying again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.orange.shade900),
                  ),
                ],
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
                        if (transaction.type == 'TRANSFER' && transaction.recipientId != null)
                          _buildReceiptRow('Recipient ID', '${transaction.recipientId}'),
                        if (transaction.fee > Decimal.zero) ...[
                          _buildReceiptRow('Fee', formatBdt(transaction.fee)),
                          if (transaction.type == 'CASH_OUT')
                            _buildReceiptRow(
                              'Total debited',
                              formatBdt(transaction.amount + transaction.fee),
                            ),
                        ],
                        if (transaction.myBalanceAfter != null)
                          _buildReceiptRow(
                            'Your balance after',
                            formatBdt(transaction.myBalanceAfter!),
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
                    context.go(homeRoute);
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
