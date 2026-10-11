// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Transaction _$TransactionFromJson(Map<String, dynamic> json) => _Transaction(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num?)?.toInt(),
  agentId: (json['agent_id'] as num?)?.toInt(),
  senderId: (json['sender_id'] as num?)?.toInt(),
  recipientId: (json['recipient_id'] as num?)?.toInt(),
  initiatedBy: (json['initiated_by'] as num?)?.toInt(),
  type: json['type'] as String,
  amount: const DecimalJsonConverter().fromJson(json['amount']),
  systemFeeAmount: const NullableDecimalJsonConverter().fromJson(
    json['system_fee_amount'],
  ),
  agentCommissionAmount: const NullableDecimalJsonConverter().fromJson(
    json['agent_commission_amount'],
  ),
  currency: json['currency'] as String? ?? 'BDT',
  description: json['description'] as String?,
  status: json['status'] as String? ?? 'COMPLETED',
  idempotencyKey: json['idempotency_key'] as String?,
  senderWalletBalanceAfter: const NullableDecimalJsonConverter().fromJson(
    json['sender_wallet_balance_after'],
  ),
  recipientWalletBalanceAfter: const NullableDecimalJsonConverter().fromJson(
    json['recipient_wallet_balance_after'],
  ),
  agentWalletBalanceAfter: const NullableDecimalJsonConverter().fromJson(
    json['agent_wallet_balance_after'],
  ),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$TransactionToJson(_Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'agent_id': instance.agentId,
      'sender_id': instance.senderId,
      'recipient_id': instance.recipientId,
      'initiated_by': instance.initiatedBy,
      'type': instance.type,
      'amount': const DecimalJsonConverter().toJson(instance.amount),
      'system_fee_amount': const NullableDecimalJsonConverter().toJson(
        instance.systemFeeAmount,
      ),
      'agent_commission_amount': const NullableDecimalJsonConverter().toJson(
        instance.agentCommissionAmount,
      ),
      'currency': instance.currency,
      'description': instance.description,
      'status': instance.status,
      'idempotency_key': instance.idempotencyKey,
      'sender_wallet_balance_after': const NullableDecimalJsonConverter()
          .toJson(instance.senderWalletBalanceAfter),
      'recipient_wallet_balance_after': const NullableDecimalJsonConverter()
          .toJson(instance.recipientWalletBalanceAfter),
      'agent_wallet_balance_after': const NullableDecimalJsonConverter().toJson(
        instance.agentWalletBalanceAfter,
      ),
      'created_at': instance.createdAt?.toIso8601String(),
    };
