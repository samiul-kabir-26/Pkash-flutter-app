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
import '../../wallet/presentation/wallet_providers.dart';
import 'money_flow_outcome.dart';
import 'money_movement_controller.dart';

/// §7.4: the customer names the agent by phone (QR or typed). A fee applies on top of the
/// amount; until a quote endpoint exists (G4) the exact fee is only shown on the receipt.
class CashOutScreen extends ConsumerStatefulWidget {
  const CashOutScreen({super.key});

  @override
  ConsumerState<CashOutScreen> createState() => _CashOutScreenState();
}

class _CashOutScreenState extends ConsumerState<CashOutScreen> {
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
      type: 'CASH_OUT',
      amount: amount,
      counterparty: agentPhone,
      description: desc,
    ));

    final confirmed = await ConfirmSheet.show(
      context,
      title: 'Review Cash-Out',
      items: [
        ConfirmSheetItem(label: 'Agent phone', value: agentPhone),
        ConfirmSheetItem(label: 'Cash-Out Amount', value: formatBdt(amount), isHighlight: true),
        // Never hardcode the rate: admins change it.
        const ConfirmSheetItem(label: 'Fee', value: 'Added on top; shown on receipt'),
        if (desc.isNotEmpty) ConfirmSheetItem(label: 'Note', value: desc),
      ],
      confirmLabel: 'Confirm Cash-Out',
      onConfirmed: () {
        final repo = ref.read(transactionRepositoryProvider);
        return controller.submit((idempotencyKey) {
          return repo.cashOut(
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
    final wallet = ref.watch(walletProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash-Out via Agent'),
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
                if (wallet != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Available Balance:', style: TextStyle(color: Colors.grey)),
                      Text(
                        formatBdt(wallet.balance),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade800),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'A cash-out fee applies and is deducted in addition to the amount. The exact fee appears on your receipt.',
                          style: TextStyle(fontSize: 13, color: Colors.orange.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
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
                  label: 'Amount to Withdraw',
                  hint: '500.00',
                  maxAmount: wallet?.balance,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  maxLength: 500,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'e.g. Counter withdrawal',
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
