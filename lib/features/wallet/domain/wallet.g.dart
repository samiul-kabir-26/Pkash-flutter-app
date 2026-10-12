// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Wallet _$WalletFromJson(Map<String, dynamic> json) => _Wallet(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  kind: json['kind'] as String? ?? 'USER',
  balance: const DecimalJsonConverter().fromJson(json['balance']),
  currency: json['currency'] as String? ?? 'BDT',
  isBlocked: json['is_blocked'] as bool? ?? false,
  blockedBy: (json['blocked_by'] as num?)?.toInt(),
  blockedAt: json['blocked_at'] == null
      ? null
      : DateTime.parse(json['blocked_at'] as String),
);

Map<String, dynamic> _$WalletToJson(_Wallet instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'kind': instance.kind,
  'balance': const DecimalJsonConverter().toJson(instance.balance),
  'currency': instance.currency,
  'is_blocked': instance.isBlocked,
  'blocked_by': instance.blockedBy,
  'blocked_at': instance.blockedAt?.toIso8601String(),
};
