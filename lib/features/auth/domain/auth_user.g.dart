// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthUser _$AuthUserFromJson(Map<String, dynamic> json) => _AuthUser(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  phoneNumber: json['phone_number'] as String,
  email: json['email'] as String?,
  address: json['address'] as String?,
  roles:
      (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isActive: json['is_active'] as String? ?? 'ACTIVE',
  isVerified: json['is_verified'] as bool? ?? false,
);

Map<String, dynamic> _$AuthUserToJson(_AuthUser instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'phone_number': instance.phoneNumber,
  'email': instance.email,
  'address': instance.address,
  'roles': instance.roles,
  'is_active': instance.isActive,
  'is_verified': instance.isVerified,
};
