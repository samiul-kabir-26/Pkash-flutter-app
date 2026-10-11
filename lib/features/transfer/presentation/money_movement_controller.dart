import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/network/api_exception.dart';
import '../../transactions/domain/transaction.dart';
import '../../wallet/presentation/wallet_providers.dart';

enum MoneyFlowStage {
  form,
  review,
  submitting,
  success,
  failed,
  unknownOutcome,
}

class MoneyMovementState {
  final MoneyFlowStage stage;
  final String? idempotencyKey;
  final Transaction? transaction;
  final String? errorMessage;
  final Map<String, String> fieldErrors;
  final bool isRetrying;

  const MoneyMovementState({
    this.stage = MoneyFlowStage.form,
    this.idempotencyKey,
    this.transaction,
    this.errorMessage,
    this.fieldErrors = const {},
    this.isRetrying = false,
  });

  MoneyMovementState copyWith({
    MoneyFlowStage? stage,
    String? idempotencyKey,
    Transaction? transaction,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    bool? isRetrying,
  }) {
    return MoneyMovementState(
      stage: stage ?? this.stage,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      transaction: transaction ?? this.transaction,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      isRetrying: isRetrying ?? this.isRetrying,
    );
  }
}

final moneyMovementControllerProvider =
    NotifierProvider.autoDispose<MoneyMovementController, MoneyMovementState>(
  MoneyMovementController.new,
);

class MoneyMovementController extends Notifier<MoneyMovementState> {
  @override
  MoneyMovementState build() => const MoneyMovementState();

  void enterReview() {
    // Generate fresh idempotency key when entering review step
    state = state.copyWith(
      stage: MoneyFlowStage.review,
      idempotencyKey: const Uuid().v4(),
      errorMessage: null,
      fieldErrors: {},
    );
  }

  void backToForm() {
    // If user goes back to form to change intent, discard review state
    state = state.copyWith(
      stage: MoneyFlowStage.form,
      errorMessage: null,
    );
  }

  Future<void> submit(Future<Transaction> Function(String idempotencyKey) operation) async {
    final key = state.idempotencyKey ?? const Uuid().v4();
    state = state.copyWith(
      stage: MoneyFlowStage.submitting,
      idempotencyKey: key,
      errorMessage: null,
    );

    try {
      final tx = await operation(key);
      _onSuccess(tx);
    } on NetworkException {
      // Stage 4c: Unknown outcome. Do NOT report failed! Retry with SAME idempotency key.
      await _handleUnknownOutcome(operation, key);
    } on ApiException catch (e) {
      // Stage 4b: Definite failure
      state = state.copyWith(
        stage: MoneyFlowStage.failed,
        errorMessage: e.message,
        fieldErrors: e.fieldErrors,
      );
    } catch (e) {
      state = state.copyWith(
        stage: MoneyFlowStage.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _handleUnknownOutcome(
    Future<Transaction> Function(String idempotencyKey) operation,
    String key,
  ) async {
    state = state.copyWith(
      stage: MoneyFlowStage.unknownOutcome,
      isRetrying: true,
      errorMessage: 'We could not confirm this transaction. Checking status...',
    );

    // Wait a brief moment before idempotent retry
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (!ref.mounted) return;

    try {
      // Retry with the EXACT SAME idempotency key
      final tx = await operation(key);
      if (!ref.mounted) return;
      _onSuccess(tx);
    } on NetworkException {
      if (!ref.mounted) return;
      // Still unknown: advise checking history, do not auto-generate a new key
      state = state.copyWith(
        stage: MoneyFlowStage.unknownOutcome,
        isRetrying: false,
        errorMessage: 'Status unknown — check your transaction history before trying again.',
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        stage: MoneyFlowStage.failed,
        isRetrying: false,
        errorMessage: e.message,
        fieldErrors: e.fieldErrors,
      );
    } catch (e) {
      state = state.copyWith(
        stage: MoneyFlowStage.failed,
        isRetrying: false,
        errorMessage: e.toString(),
      );
    }
  }

  void _onSuccess(Transaction tx) {
    state = state.copyWith(
      stage: MoneyFlowStage.success,
      transaction: tx,
      isRetrying: false,
    );
    // Invalidate wallet so screens reflect new balance
    ref.invalidate(walletProvider);
  }

  void reset() {
    state = const MoneyMovementState();
  }
}
