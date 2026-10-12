import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/money/money.dart';
import '../../../core/widgets/amount_field.dart';
import '../../../core/widgets/confirm_sheet.dart';
import '../../../core/widgets/primary_button.dart';
import '../../transactions/data/transaction_repository.dart';
import '../../transfer/presentation/money_flow_outcome.dart';
import '../../transfer/presentation/money_movement_controller.dart';
import '../../wallet/presentation/wallet_providers.dart';

class AgentWithdrawalScreen extends ConsumerStatefulWidget {
  const AgentWithdrawalScreen({super.key});

  @override
  ConsumerState<AgentWithdrawalScreen> createState() => _AgentWithdrawalScreenState();
}

class _AgentWithdrawalScreenState extends ConsumerState<AgentWithdrawalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _onReview() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = parseMoney(_amountController.text.trim());
    final desc = _descController.text.trim();

    final controller = ref.read(moneyMovementControllerProvider.notifier);

    controller.enterReview(MoneyIntent(type: 'AGENT_WITHDRAWAL', amount: amount, description: desc));

    final confirmed = await ConfirmSheet.show(
      context,
      title: 'Confirm Agent Withdrawal',
      items: [
        ConfirmSheetItem(label: 'Service', value: 'Agent Bank/Counter Withdrawal'),
        ConfirmSheetItem(label: 'Withdrawal Amount', value: formatBdt(amount), isHighlight: true),
        if (desc.isNotEmpty) ConfirmSheetItem(label: 'Note', value: desc),
      ],
      confirmLabel: 'Withdraw Now',
      onConfirmed: () {
        final repo = ref.read(transactionRepositoryProvider);
        return controller.submit((idempotencyKey) {
          return repo.agentWithdrawal(
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
    await showMoneyFlowOutcome(context, ref, historyRoute: '/agent/history', homeRoute: '/agent/home');
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Withdrawal'),
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
                AmountField(
                  controller: _amountController,
                  label: 'Withdrawal Amount',
                  hint: '1000.00',
                  maxAmount: wallet?.balance,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  maxLength: 500,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'e.g. Weekly earnings withdrawal',
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
