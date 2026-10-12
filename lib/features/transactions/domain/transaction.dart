import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/money/decimal_converter.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
abstract class Transaction with _$Transaction {
  const Transaction._();

  const factory Transaction({
    required int id,
    @JsonKey(name: 'user_id') int? userId,
    @JsonKey(name: 'agent_id') int? agentId,
    @JsonKey(name: 'sender_id') int? senderId,
    @JsonKey(name: 'recipient_id') int? recipientId,
    @JsonKey(name: 'initiated_by') int? initiatedBy,
    required String type,
    @DecimalJsonConverter() required Decimal amount,
    @NullableDecimalJsonConverter() @JsonKey(name: 'system_fee_amount') Decimal? systemFeeAmount,
    @NullableDecimalJsonConverter() @JsonKey(name: 'agent_commission_amount') Decimal? agentCommissionAmount,
    @Default('BDT') String currency,
    String? description,
    @Default('COMPLETED') String status,
    @JsonKey(name: 'idempotency_key') String? idempotencyKey,
    @NullableDecimalJsonConverter() @JsonKey(name: 'sender_wallet_balance_after') Decimal? senderWalletBalanceAfter,
    @NullableDecimalJsonConverter() @JsonKey(name: 'recipient_wallet_balance_after') Decimal? recipientWalletBalanceAfter,
    @NullableDecimalJsonConverter() @JsonKey(name: 'agent_wallet_balance_after') Decimal? agentWalletBalanceAfter,
    Map<String, dynamic>? meta,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Transaction;

  Decimal get fee => systemFeeAmount ?? Decimal.zero;
  Decimal get commission => agentCommissionAmount ?? Decimal.zero;
  bool get isCompleted => status == 'COMPLETED';
  bool get isPending => status == 'PENDING';
  bool get isFailed => status == 'FAILED';

  /// Only the viewer's own `*_balance_after` key is present (§7.8); the others are absent.
  Decimal? get myBalanceAfter =>
      senderWalletBalanceAfter ?? recipientWalletBalanceAfter ?? agentWalletBalanceAfter;

  /// COMMISSION_PAYOUT rows point at their cash-out through `meta.related_transaction_id`.
  int? get relatedTransactionId {
    final value = meta?['related_transaction_id'];
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
}
