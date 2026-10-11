import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/money/decimal_converter.dart';

part 'agent_info.freezed.dart';
part 'agent_info.g.dart';

@freezed
abstract class AgentInfo with _$AgentInfo {
  const AgentInfo._();

  const factory AgentInfo({
    int? id,
    @JsonKey(name: 'user_id') int? userId,
    @Default('PENDING') String status,
    @NullableDecimalJsonConverter() @JsonKey(name: 'commission_rate') Decimal? commissionRate,
    @NullableDecimalJsonConverter() @JsonKey(name: 'total_commission') Decimal? totalCommission,
    @JsonKey(name: 'approved_at') DateTime? approvedAt,
  }) = _AgentInfo;

  Decimal get rate => commissionRate ?? Decimal.zero;
  Decimal get commission => totalCommission ?? Decimal.zero;
  bool get isApproved => status == 'APPROVED';
  bool get isPending => status == 'PENDING';
  bool get isSuspended => status == 'SUSPENDED';

  factory AgentInfo.fromJson(Map<String, dynamic> json) => _$AgentInfoFromJson(json);
}
