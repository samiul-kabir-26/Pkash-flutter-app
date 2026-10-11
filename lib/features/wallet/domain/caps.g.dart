// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'caps.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Caps _$CapsFromJson(Map<String, dynamic> json) => _Caps(
  id: (json['id'] as num?)?.toInt(),
  userId: (json['user_id'] as num?)?.toInt(),
  dailyCap: const DecimalJsonConverter().fromJson(json['daily_cap']),
  monthlyCap: const DecimalJsonConverter().fromJson(json['monthly_cap']),
  dailyUsed: const DecimalJsonConverter().fromJson(json['daily_used']),
  monthlyUsed: const DecimalJsonConverter().fromJson(json['monthly_used']),
);

Map<String, dynamic> _$CapsToJson(_Caps instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'daily_cap': const DecimalJsonConverter().toJson(instance.dailyCap),
  'monthly_cap': const DecimalJsonConverter().toJson(instance.monthlyCap),
  'daily_used': const DecimalJsonConverter().toJson(instance.dailyUsed),
  'monthly_used': const DecimalJsonConverter().toJson(instance.monthlyUsed),
};
