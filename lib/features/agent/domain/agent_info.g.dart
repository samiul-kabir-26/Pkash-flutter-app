// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AgentInfo _$AgentInfoFromJson(Map<String, dynamic> json) => _AgentInfo(
  id: (json['id'] as num?)?.toInt(),
  userId: (json['user_id'] as num?)?.toInt(),
  status: json['status'] as String? ?? 'PENDING',
  commissionRate: const NullableDecimalJsonConverter().fromJson(
    json['commission_rate'],
  ),
  totalCommission: const NullableDecimalJsonConverter().fromJson(
    json['total_commission'],
  ),
  approvedAt: json['approved_at'] == null
      ? null
      : DateTime.parse(json['approved_at'] as String),
);

Map<String, dynamic> _$AgentInfoToJson(_AgentInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'status': instance.status,
      'commission_rate': const NullableDecimalJsonConverter().toJson(
        instance.commissionRate,
      ),
      'total_commission': const NullableDecimalJsonConverter().toJson(
        instance.totalCommission,
      ),
      'approved_at': instance.approvedAt?.toIso8601String(),
    };
