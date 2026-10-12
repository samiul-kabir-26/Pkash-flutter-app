import 'package:flutter/material.dart';
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

class SendMoneyScreen extends ConsumerStatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  ConsumerState<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends ConsumerState<SendMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientIdController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _recipientIdController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _scanQr() async {
    final scannedId = await context.push<String>('/scan-qr?type=user');
    if (scannedId != null && mounted) {
      _recipientIdController.text = scannedId;
    }
  }

  Future<void> _onReview() async {
    if (!_formKey.currentState!.validate()) return;

    final recipientId = int.parse(_recipientIdController.text.trim());

    final amount = parseMoney(_amountController.text.trim());
    final desc = _descController.text.trim();

    final controller = ref.read(moneyMovementControllerProvider.notifier);

    controller.enterReview(MoneyIntent(
      type: 'TRANSFER',
      amount: amount,
      counterparty: '$recipientId',
      description: desc,
    ));

    final confirmed = await ConfirmSheet.show(
      context,
      title: 'Review Transfer',
      items: [
        ConfirmSheetItem(label: 'Recipient User ID', value: '#$recipientId'),
        ConfirmSheetItem(label: 'Amount to Send', value: formatBdt(amount), isHighlight: true),
        if (desc.isNotEmpty) ConfirmSheetItem(label: 'Note', value: desc),
      ],
      confirmLabel: 'Confirm & Send',
      onConfirmed: () {
        final repo = ref.read(transactionRepositoryProvider);
        return controller.submit((idempotencyKey) {
          return repo.transfer(
            recipientId: recipientId,
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
    final wallet = ref.watch(walletProvider).value;
    final myId = ref.watch(sessionControllerProvider).value?.user.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Money (P2P)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan QR',
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
                TextFormField(
                  controller: _recipientIdController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Recipient User ID',
                    hintText: 'Enter recipient user ID',
                    prefixIcon: const Icon(Icons.person_search_outlined),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: _scanQr,
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) => Validators.validateRecipientId(val, ownId: myId),
                ),
                const SizedBox(height: 16),
                AmountField(
                  controller: _amountController,
                  label: 'Amount',
                  hint: '500.00',
                  maxAmount: wallet?.balance,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  maxLength: 500,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'e.g. Dinner share',
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
