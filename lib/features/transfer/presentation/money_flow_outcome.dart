import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'money_movement_controller.dart';
import 'receipt_screen.dart';

/// Shared stage 4 handling (§7.2) for every money screen, called after the confirm sheet
/// has closed: receipt on success, verbatim server message on a definite failure, and a
/// "check your history" prompt when the outcome is unknown.
Future<void> showMoneyFlowOutcome(
  BuildContext context,
  WidgetRef ref, {
  required String historyRoute,
  required String homeRoute,
}) async {
  final state = ref.read(moneyMovementControllerProvider);

  switch (state.stage) {
    case MoneyFlowStage.success:
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ReceiptScreen(
            transaction: state.transaction!,
            homeRoute: homeRoute,
            mismatch: state.receiptMismatch,
          ),
        ),
      );
    case MoneyFlowStage.failed:
      final fieldMessages = state.fieldErrors.values.toList();
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Transaction not completed'),
          content: Text(
            fieldMessages.isNotEmpty
                ? fieldMessages.join('\n')
                : (state.errorMessage ?? 'Something went wrong.'),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    case MoneyFlowStage.unknownOutcome:
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Status unknown'),
          content: Text(
            '${state.errorMessage ?? 'We could not confirm this transaction.'}\n\n'
            'Do not send it again until you have checked your history.',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.go(historyRoute);
              },
              child: const Text('View history'),
            ),
          ],
        ),
      );
    case MoneyFlowStage.form:
    case MoneyFlowStage.review:
    case MoneyFlowStage.submitting:
      break;
  }
}
