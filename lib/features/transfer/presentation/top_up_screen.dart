import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/money/money.dart';
import '../../../core/widgets/amount_field.dart';
import '../../../core/widgets/confirm_sheet.dart';
import '../../../core/widgets/primary_button.dart';
import '../../transactions/data/transaction_repository.dart';
import 'money_flow_outcome.dart';
import 'money_movement_controller.dart';

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

  Future<void> _onContinue() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(moneyMovementControllerProvider.notifier);
    final amount = parseMoney(_amountController.text.trim());
    final desc = _descController.text.trim();

    controller.enterReview(MoneyIntent(type: 'TOP_UP', amount: amount, description: desc));

    final confirmed = await ConfirmSheet.show(
      context,
      title: 'Confirm Demo Top-Up',
      items: [
        const ConfirmSheetItem(label: 'Service', value: 'Demo top-up (no real funding source)'),
        ConfirmSheetItem(label: 'Amount', value: formatBdt(amount), isHighlight: true),
        if (desc.isNotEmpty) ConfirmSheetItem(label: 'Note', value: desc),
      ],
      confirmLabel: 'Top-Up Now',
      onConfirmed: () {
        final repo = ref.read(transactionRepositoryProvider);
        return controller.submit((idempotencyKey) {
          return repo.topUp(
            amount: amount,
            idempotencyKey: idempotencyKey,
            description: desc.isNotEmpty ? desc : null,
          );
        });
      },
    );

    if (!mounted) return;
    if (confirmed != true) {
      controller.backToForm();
      return;
    }
    await showMoneyFlowOutcome(context, ref, historyRoute: '/user/history', homeRoute: '/user/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Top-Up'),
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
