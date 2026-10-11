import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/money/decimal_converter.dart';

part 'caps.freezed.dart';
part 'caps.g.dart';

@freezed
abstract class Caps with _$Caps {
  const Caps._();

  const factory Caps({
    int? id,
    @JsonKey(name: 'user_id') int? userId,
    @DecimalJsonConverter() @JsonKey(name: 'daily_cap') required Decimal dailyCap,
    @DecimalJsonConverter() @JsonKey(name: 'monthly_cap') required Decimal monthlyCap,
    @DecimalJsonConverter() @JsonKey(name: 'daily_used') required Decimal dailyUsed,
    @DecimalJsonConverter() @JsonKey(name: 'monthly_used') required Decimal monthlyUsed,
  }) = _Caps;

  Decimal get remainingDaily => dailyCap - dailyUsed > Decimal.zero ? dailyCap - dailyUsed : Decimal.zero;
  Decimal get remainingMonthly => monthlyCap - monthlyUsed > Decimal.zero ? monthlyCap - monthlyUsed : Decimal.zero;

  factory Caps.fromJson(Map<String, dynamic> json) => _$CapsFromJson(json);
}
