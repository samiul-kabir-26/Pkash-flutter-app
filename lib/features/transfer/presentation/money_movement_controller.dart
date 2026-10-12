import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/network/api_exception.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../transactions/domain/transaction.dart';
import '../../transactions/presentation/transaction_providers.dart';
import '../../wallet/presentation/wallet_providers.dart';

enum MoneyFlowStage {
  form,
  review,
  submitting,
  success,
  failed,
  unknownOutcome,
}

/// Everything that goes into the request body except the key. Two intents are equal only
/// if every field is equal; any change means a new idempotency key (D9, G7).
@immutable
class MoneyIntent {
  /// The transaction type the server should create (`TOP_UP`, `TRANSFER`, `CASH_IN`, ...).
  final String type;
  final Decimal amount;

  /// Recipient ID or agent phone; empty for top-up and withdrawal.
  final String counterparty;
  final String description;

  const MoneyIntent({
    required this.type,
    required this.amount,
    this.counterparty = '',
    this.description = '',
  });

  @override
  bool operator ==(Object other) =>
      other is MoneyIntent &&
      other.type == type &&
      other.amount == amount &&
      other.counterparty == counterparty &&
      other.description == description;

  @override
  int get hashCode => Object.hash(type, amount, counterparty, description);
}

class MoneyMovementState {
  final MoneyFlowStage stage;
  final MoneyIntent? intent;
  final String? idempotencyKey;
  final Transaction? transaction;
  final String? errorMessage;
  final Map<String, String> fieldErrors;
  final bool isRetrying;

  /// The server returned a transaction that doesn't match what was submitted: a key was
  /// reused for a different intent (an app bug, G7). The receipt shows the real transaction.
  final bool receiptMismatch;

  const MoneyMovementState({
    this.stage = MoneyFlowStage.form,
    this.intent,
    this.idempotencyKey,
    this.transaction,
    this.errorMessage,
    this.fieldErrors = const {},
    this.isRetrying = false,
    this.receiptMismatch = false,
  });

  MoneyMovementState copyWith({
    MoneyFlowStage? stage,
    MoneyIntent? intent,
    String? idempotencyKey,
    bool clearIdempotencyKey = false,
    Transaction? transaction,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    bool? isRetrying,
    bool? receiptMismatch,
  }) {
    return MoneyMovementState(
      stage: stage ?? this.stage,
      intent: intent ?? this.intent,
      idempotencyKey: clearIdempotencyKey ? null : (idempotencyKey ?? this.idempotencyKey),
      transaction: transaction ?? this.transaction,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      isRetrying: isRetrying ?? this.isRetrying,
      receiptMismatch: receiptMismatch ?? this.receiptMismatch,
    );
  }
}

/// Backoff between same-key retries after an unknown outcome (§7.2, stage 4c).
final moneyFlowRetryDelaysProvider = Provider<List<Duration>>((ref) => const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
    ]);

/// Flow-scoped: the key dies with the flow.
final moneyMovementControllerProvider =
    NotifierProvider.autoDispose<MoneyMovementController, MoneyMovementState>(
  MoneyMovementController.new,
);

class MoneyMovementController extends Notifier<MoneyMovementState> {
  @override
  MoneyMovementState build() => const MoneyMovementState();

  /// Stage 2. The key is created here, and kept only if the intent is unchanged.
  void enterReview(MoneyIntent intent) {
    final keepKey = state.idempotencyKey != null && state.intent == intent;
    state = state.copyWith(
      stage: MoneyFlowStage.review,
      intent: intent,
      idempotencyKey: keepKey ? state.idempotencyKey : const Uuid().v4(),
      errorMessage: null,
      fieldErrors: {},
    );
  }

  void backToForm() {
    state = state.copyWith(
      stage: MoneyFlowStage.form,
      errorMessage: null,
    );
  }

  Future<void> submit(Future<Transaction> Function(String idempotencyKey) operation) async {
    // Confirm can't fire twice, and nothing is sent without a reviewed intent.
    if (state.stage == MoneyFlowStage.submitting || state.stage == MoneyFlowStage.unknownOutcome) {
      return;
    }
    final key = state.idempotencyKey;
    if (key == null || state.intent == null) {
      throw StateError('submit() called before enterReview()');
    }

    state = state.copyWith(
      stage: MoneyFlowStage.submitting,
      errorMessage: null,
      fieldErrors: {},
    );

    try {
      final tx = await operation(key);
      if (!ref.mounted) return;
      _onSuccess(tx);
    } on NetworkException {
      if (!ref.mounted) return;
      await _resolveUnknownOutcome(operation, key);
    } on ApiException catch (e) {
      if (!ref.mounted) return;
      // Stage 4b: a 4xx/5xx on the first attempt. Money did not move; the next attempt,
      // even for the same intent, gets a fresh key.
      state = state.copyWith(
        stage: MoneyFlowStage.failed,
        clearIdempotencyKey: true,
        errorMessage: e.isServerError ? 'Something went wrong.' : e.message,
        fieldErrors: e.fieldErrors,
      );
    }
  }

  /// Stage 4c: never report "failed". Retry with the same key; the server replays the
  /// original transaction for a repeated key, so retries can't double-charge.
  Future<void> _resolveUnknownOutcome(
    Future<Transaction> Function(String idempotencyKey) operation,
    String key,
  ) async {
    state = state.copyWith(
      stage: MoneyFlowStage.unknownOutcome,
      isRetrying: true,
      errorMessage: "We couldn't confirm this transaction. Checking…",
    );

    for (final delay in ref.read(moneyFlowRetryDelaysProvider)) {
      await Future<void>.delayed(delay);
      if (!ref.mounted) return;

      try {
        final tx = await operation(key);
        if (!ref.mounted) return;
        _onSuccess(tx);
        return;
      } on NetworkException {
        continue;
      } on ApiException {
        // G7: the server checks agent/recipient before the replay lookup, so a 4xx here
        // can hide an original success. Not a definite failure.
        break;
      }
    }

    if (!ref.mounted) return;
    state = state.copyWith(
      stage: MoneyFlowStage.unknownOutcome,
      isRetrying: false,
      errorMessage: 'Status unknown — check your history before trying again.',
    );
  }

  void _onSuccess(Transaction tx) {
    final intent = state.intent!;
    final mismatch = tx.amount != intent.amount || tx.type.toUpperCase() != intent.type;
    if (mismatch) {
      debugPrint(
        'MoneyFlow: receipt mismatch (submitted ${intent.type}, got ${tx.type} #${tx.id}). '
        'An idempotency key was reused for a different intent.',
      );
    }

    state = state.copyWith(
      stage: MoneyFlowStage.success,
      transaction: tx,
      clearIdempotencyKey: true,
      isRetrying: false,
      receiptMismatch: mismatch,
    );

    ref.invalidate(walletProvider);
    ref.invalidate(capsProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(recentTransactionsProvider);
    ref.invalidate(historyNotifierProvider);
  }

  void reset() {
    state = const MoneyMovementState();
  }
}
