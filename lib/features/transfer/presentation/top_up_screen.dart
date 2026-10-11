import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/money/money.dart';
import '../../../core/widgets/amount_field.dart';
import '../../../core/widgets/confirm_sheet.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/snackbar_helpers.dart';
import '../../transactions/data/transaction_repository.dart';
import 'money_movement_controller.dart';
import 'receipt_screen.dart';

class TopUpScreen extends ConsumerStatefulWidget {
  const TopUpScreen({super.key});

  @override
  ConsumerState<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends ConsumerState<TopUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(moneyMovementControllerProvider.notifier);
    controller.enterReview();

    final amount = parseMoney(_amountController.text.trim());
    final desc = _descController.text.trim();

    ConfirmSheet.show(
      context,
      title: 'Confirm Top-Up',
      items: [
        ConfirmSheetItem(label: 'Service', value: 'Instant Balance Top-Up'),
        ConfirmSheetItem(label: 'Amount', value: formatBdt(amount), isHighlight: true),
        if (desc.isNotEmpty) ConfirmSheetItem(label: 'Note', value: desc),
      ],
      confirmLabel: 'Top-Up Now',
      onConfirmed: () async {
        final repo = ref.read(transactionRepositoryProvider);
        await controller.submit((idempotencyKey) {
          return repo.topUp(
            amount: amount,
            idempotencyKey: idempotencyKey,
            description: desc.isNotEmpty ? desc : null,
          );
        });

        final state = ref.read(moneyMovementControllerProvider);
        if (state.stage == MoneyFlowStage.success && state.transaction != null) {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => ReceiptScreen(transaction: state.transaction!),
              ),
            );
          }
        } else if (state.stage == MoneyFlowStage.unknownOutcome) {
          if (mounted) {
            showErrorSnackBar(context, state.errorMessage ?? 'Status unknown. Check history.');
          }
        } else if (state.stage == MoneyFlowStage.failed) {
          if (mounted) {
            showErrorSnackBar(context, state.errorMessage ?? 'Top-up failed.');
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top-Up Balance'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Simulated / Demo balance top-up for your wallet.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AmountField(
                  controller: _amountController,
                  label: 'Top-Up Amount',
                  hint: '500.00',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  maxLength: 500,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'e.g. Deposit',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const Spacer(),
                PrimaryButton(
                  label: 'Review Top-Up',
                  onPressed: _onContinue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
