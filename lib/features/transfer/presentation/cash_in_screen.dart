import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/money/money.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/amount_field.dart';
import '../../../core/widgets/confirm_sheet.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/snackbar_helpers.dart';
import '../../transactions/data/transaction_repository.dart';
import 'money_movement_controller.dart';
import 'receipt_screen.dart';

class CashInScreen extends ConsumerStatefulWidget {
  const CashInScreen({super.key});

  @override
  ConsumerState<CashInScreen> createState() => _CashInScreenState();
}

class _CashInScreenState extends ConsumerState<CashInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _agentIdController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _agentIdController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _scanQr() async {
    final scannedId = await context.push<String>('/scan-qr?type=agent');
    if (scannedId != null && mounted) {
      _agentIdController.text = scannedId;
    }
  }

  void _onReview() {
    if (!_formKey.currentState!.validate()) return;

    final agentId = int.parse(_agentIdController.text.trim());
    final amount = parseMoney(_amountController.text.trim());
    final desc = _descController.text.trim();

    final controller = ref.read(moneyMovementControllerProvider.notifier);
    controller.enterReview();

    ConfirmSheet.show(
      context,
      title: 'Review Cash-In',
      items: [
        ConfirmSheetItem(label: 'Agent ID', value: '#$agentId'),
        ConfirmSheetItem(label: 'Cash-In Amount', value: formatBdt(amount), isHighlight: true),
        const ConfirmSheetItem(label: 'Fee', value: '৳0.00 (Free)'),
        if (desc.isNotEmpty) ConfirmSheetItem(label: 'Note', value: desc),
      ],
      confirmLabel: 'Confirm Cash-In',
      onConfirmed: () async {
        final repo = ref.read(transactionRepositoryProvider);
        await controller.submit((idempotencyKey) {
          return repo.cashIn(
            agentId: agentId,
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
            showErrorSnackBar(context, state.errorMessage ?? 'Cash-in failed.');
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash-In from Agent'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan Agent QR',
            onPressed: _scanQr,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _agentIdController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Agent ID',
                    hintText: 'Enter agent ID or scan QR',
                    prefixIcon: const Icon(Icons.storefront_outlined),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: _scanQr,
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) => Validators.validateId(val, fieldName: 'Agent ID'),
                ),
                const SizedBox(height: 16),
                AmountField(
                  controller: _amountController,
                  label: 'Amount to Receive',
                  hint: '500.00',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  maxLength: 500,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'e.g. Cash in at store',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const Spacer(),
                PrimaryButton(
                  label: 'Continue',
                  onPressed: _onReview,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
