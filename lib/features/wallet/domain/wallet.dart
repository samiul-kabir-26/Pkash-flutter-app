import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/money/decimal_converter.dart';

part 'wallet.freezed.dart';
part 'wallet.g.dart';

@freezed
abstract class Wallet with _$Wallet {
  const factory Wallet({
    required int id,
    @JsonKey(name: 'user_id') required int userId,
    /// `USER` or `AGENT`: one wallet per role (§0 "What changed").
    @Default('USER') String kind,
    @DecimalJsonConverter() required Decimal balance,
    @Default('BDT') String currency,
    @JsonKey(name: 'is_blocked') @Default(false) bool isBlocked,
    @JsonKey(name: 'blocked_by') int? blockedBy,
    @JsonKey(name: 'blocked_at') DateTime? blockedAt,
  }) = _Wallet;

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);
}
