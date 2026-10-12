import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/money/money.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/amount_field.dart';
import '../../../core/widgets/confirm_sheet.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/presentation/session_controller.dart';
import '../../transactions/data/transaction_repository.dart';
import 'money_flow_outcome.dart';
import 'money_movement_controller.dart';

/// §7.5: the customer names the agent by phone (typed or scanned). Free, no caps.
class CashInScreen extends ConsumerStatefulWidget {
  const CashInScreen({super.key});

  @override
  ConsumerState<CashInScreen> createState() => _CashInScreenState();
}

class _CashInScreenState extends ConsumerState<CashInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _agentPhoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _agentPhoneController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _scanQr() async {
    final scannedPhone = await context.push<String>('/scan-qr?type=agent');
    if (scannedPhone != null && mounted) {
      _agentPhoneController.text = scannedPhone;
    }
  }

  Future<void> _onReview() async {
    if (!_formKey.currentState!.validate()) return;

    final agentPhone = _agentPhoneController.text.trim();
    final amount = parseMoney(_amountController.text.trim());
    final desc = _descController.text.trim();

    final controller = ref.read(moneyMovementControllerProvider.notifier);
    controller.enterReview(MoneyIntent(
      type: 'CASH_IN',
      amount: amount,
      counterparty: agentPhone,
      description: desc,
    ));

    final confirmed = await ConfirmSheet.show(
      context,
      title: 'Review Cash-In',
      items: [
        ConfirmSheetItem(label: 'Agent phone', value: agentPhone),
        ConfirmSheetItem(label: 'Cash-In Amount', value: formatBdt(amount), isHighlight: true),
        const ConfirmSheetItem(label: 'Fee', value: '৳0.00 (Free)'),
        if (desc.isNotEmpty) ConfirmSheetItem(label: 'Note', value: desc),
      ],
      confirmLabel: 'Confirm Cash-In',
      onConfirmed: () {
        final repo = ref.read(transactionRepositoryProvider);
        return controller.submit((idempotencyKey) {
          return repo.cashIn(
            agentPhone: agentPhone,
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
    final ownPhone = ref.watch(sessionControllerProvider).value?.user.phoneNumber;

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
                  controller: _agentPhoneController,
                  keyboardType: TextInputType.phone,
                  autocorrect: false,
                  enableSuggestions: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Agent phone number',
                    hintText: 'Enter agent phone or scan QR',
                    prefixIcon: const Icon(Icons.storefront_outlined),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: _scanQr,
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) => Validators.validateAgentPhone(val, ownPhone: ownPhone),
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
