import 'package:freezed_annotation/freezed_annotation.dart';
import 'auth_user.dart';

part 'session.freezed.dart';
part 'session.g.dart';

@freezed
abstract class Session with _$Session {
  const Session._();

  const factory Session({
    required String token,
    @JsonKey(name: 'token_type') @Default('Bearer') String tokenType,
    @Default([]) List<String> abilities,
    required AuthUser user,
  }) = _Session;

  String get panel => abilities.contains('agent') ? 'agent' : 'user';

  factory Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);
}
