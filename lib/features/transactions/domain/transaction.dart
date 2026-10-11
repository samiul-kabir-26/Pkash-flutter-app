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
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Transaction;

  Decimal get fee => systemFeeAmount ?? Decimal.zero;
  Decimal get commission => agentCommissionAmount ?? Decimal.zero;
  bool get isCompleted => status == 'COMPLETED';
  bool get isPending => status == 'PENDING';
  bool get isFailed => status == 'FAILED';

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
}
