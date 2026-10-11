import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';
part 'auth_user.g.dart';

@freezed
abstract class AuthUser with _$AuthUser {
  const factory AuthUser({
    required int id,
    required String name,
    @JsonKey(name: 'phone_number') required String phoneNumber,
    String? email,
    String? address,
    @Default([]) List<String> roles,
    @JsonKey(name: 'is_active') @Default('ACTIVE') String isActive,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
  }) = _AuthUser;

  factory AuthUser.fromJson(Map<String, dynamic> json) => _$AuthUserFromJson(json);
}
