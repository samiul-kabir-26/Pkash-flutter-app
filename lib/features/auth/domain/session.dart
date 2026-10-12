import 'package:freezed_annotation/freezed_annotation.dart';
import 'auth_user.dart';
import 'panel.dart';

export 'panel.dart';

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

  Panel get panel => Panel.fromAbilities(abilities);

  factory Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);
}
