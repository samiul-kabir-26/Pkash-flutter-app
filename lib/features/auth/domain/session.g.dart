// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Session _$SessionFromJson(Map<String, dynamic> json) => _Session(
  token: json['token'] as String,
  tokenType: json['token_type'] as String? ?? 'Bearer',
  abilities:
      (json['abilities'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SessionToJson(_Session instance) => <String, dynamic>{
  'token': instance.token,
  'token_type': instance.tokenType,
  'abilities': instance.abilities,
  'user': instance.user,
};
