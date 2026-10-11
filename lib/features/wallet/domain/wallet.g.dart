// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Wallet _$WalletFromJson(Map<String, dynamic> json) => _Wallet(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  balance: const DecimalJsonConverter().fromJson(json['balance']),
  currency: json['currency'] as String? ?? 'BDT',
  isBlocked: json['is_blocked'] as bool? ?? false,
);

Map<String, dynamic> _$WalletToJson(_Wallet instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'balance': const DecimalJsonConverter().toJson(instance.balance),
  'currency': instance.currency,
  'is_blocked': instance.isBlocked,
};
