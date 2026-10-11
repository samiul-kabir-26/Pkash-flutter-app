// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agent_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AgentInfo {

 int? get id;@JsonKey(name: 'user_id') int? get userId; String get status;@NullableDecimalJsonConverter()@JsonKey(name: 'commission_rate') Decimal? get commissionRate;@NullableDecimalJsonConverter()@JsonKey(name: 'total_commission') Decimal? get totalCommission;@JsonKey(name: 'approved_at') DateTime? get approvedAt;
/// Create a copy of AgentInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgentInfoCopyWith<AgentInfo> get copyWith => _$AgentInfoCopyWithImpl<AgentInfo>(this as AgentInfo, _$identity);

  /// Serializes this AgentInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AgentInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgentInfo&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.commissionRate, _this.commissionRate) || other.commissionRate == _this.commissionRate)&&(identical(other.totalCommission, _this.totalCommission) || other.totalCommission == _this.totalCommission)&&(identical(other.approvedAt, _this.approvedAt) || other.approvedAt == _this.approvedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AgentInfo;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.status,_this.commissionRate,_this.totalCommission,_this.approvedAt);
}

@override
String toString() {
  final _this = this as AgentInfo;
  return 'AgentInfo(id: ${_this.id}, userId: ${_this.userId}, status: ${_this.status}, commissionRate: ${_this.commissionRate}, totalCommission: ${_this.totalCommission}, approvedAt: ${_this.approvedAt})';
}


}

/// @nodoc
abstract mixin class $AgentInfoCopyWith<$Res>  {
  factory $AgentInfoCopyWith(AgentInfo value, $Res Function(AgentInfo) _then) = _$AgentInfoCopyWithImpl;
@useResult
$Res call({
 int? id,@JsonKey(name: 'user_id') int? userId, String status,@NullableDecimalJsonConverter()@JsonKey(name: 'commission_rate') Decimal? commissionRate,@NullableDecimalJsonConverter()@JsonKey(name: 'total_commission') Decimal? totalCommission,@JsonKey(name: 'approved_at') DateTime? approvedAt
});




}
/// @nodoc
class _$AgentInfoCopyWithImpl<$Res>
    implements $AgentInfoCopyWith<$Res> {
  _$AgentInfoCopyWithImpl(this._self, this._then);

  final AgentInfo _self;
  final $Res Function(AgentInfo) _then;

/// Create a copy of AgentInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? userId = freezed,Object? status = null,Object? commissionRate = freezed,Object? totalCommission = freezed,Object? approvedAt = freezed,}) {
  return _then(AgentInfo(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,commissionRate: freezed == commissionRate ? _self.commissionRate : commissionRate // ignore: cast_nullable_to_non_nullable
as Decimal?,totalCommission: freezed == totalCommission ? _self.totalCommission : totalCommission // ignore: cast_nullable_to_non_nullable
as Decimal?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AgentInfo].
extension AgentInfoPatterns on AgentInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AgentInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AgentInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AgentInfo value)  $default,){
final _that = this;
switch (_that) {
case _AgentInfo():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AgentInfo value)?  $default,){
final _that = this;
switch (_that) {
case _AgentInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id, @JsonKey(name: 'user_id')  int? userId,  String status, @NullableDecimalJsonConverter()@JsonKey(name: 'commission_rate')  Decimal? commissionRate, @NullableDecimalJsonConverter()@JsonKey(name: 'total_commission')  Decimal? totalCommission, @JsonKey(name: 'approved_at')  DateTime? approvedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AgentInfo() when $default != null:
return $default(_that.id,_that.userId,_that.status,_that.commissionRate,_that.totalCommission,_that.approvedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id, @JsonKey(name: 'user_id')  int? userId,  String status, @NullableDecimalJsonConverter()@JsonKey(name: 'commission_rate')  Decimal? commissionRate, @NullableDecimalJsonConverter()@JsonKey(name: 'total_commission')  Decimal? totalCommission, @JsonKey(name: 'approved_at')  DateTime? approvedAt)  $default,) {final _that = this;
switch (_that) {
case _AgentInfo():
return $default(_that.id,_that.userId,_that.status,_that.commissionRate,_that.totalCommission,_that.approvedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id, @JsonKey(name: 'user_id')  int? userId,  String status, @NullableDecimalJsonConverter()@JsonKey(name: 'commission_rate')  Decimal? commissionRate, @NullableDecimalJsonConverter()@JsonKey(name: 'total_commission')  Decimal? totalCommission, @JsonKey(name: 'approved_at')  DateTime? approvedAt)?  $default,) {final _that = this;
switch (_that) {
case _AgentInfo() when $default != null:
return $default(_that.id,_that.userId,_that.status,_that.commissionRate,_that.totalCommission,_that.approvedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AgentInfo extends AgentInfo {
  const _AgentInfo({this.id, @JsonKey(name: 'user_id') this.userId, this.status = 'PENDING', @NullableDecimalJsonConverter()@JsonKey(name: 'commission_rate') this.commissionRate, @NullableDecimalJsonConverter()@JsonKey(name: 'total_commission') this.totalCommission, @JsonKey(name: 'approved_at') this.approvedAt}): super._();
  factory _AgentInfo.fromJson(Map<String, dynamic> json) => _$AgentInfoFromJson(json);

@override final  int? id;
@override@JsonKey(name: 'user_id') final  int? userId;
@override@JsonKey() final  String status;
@override@NullableDecimalJsonConverter()@JsonKey(name: 'commission_rate') final  Decimal? commissionRate;
@override@NullableDecimalJsonConverter()@JsonKey(name: 'total_commission') final  Decimal? totalCommission;
@override@JsonKey(name: 'approved_at') final  DateTime? approvedAt;

/// Create a copy of AgentInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AgentInfoCopyWith<_AgentInfo> get copyWith => __$AgentInfoCopyWithImpl<_AgentInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AgentInfoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AgentInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.status, status) || other.status == status)&&(identical(other.commissionRate, commissionRate) || other.commissionRate == commissionRate)&&(identical(other.totalCommission, totalCommission) || other.totalCommission == totalCommission)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,status,commissionRate,totalCommission,approvedAt);
}

@override
String toString() {
    return 'AgentInfo(id: $id, userId: $userId, status: $status, commissionRate: $commissionRate, totalCommission: $totalCommission, approvedAt: $approvedAt)';
}


}

/// @nodoc
abstract mixin class _$AgentInfoCopyWith<$Res> implements $AgentInfoCopyWith<$Res> {
  factory _$AgentInfoCopyWith(_AgentInfo value, $Res Function(_AgentInfo) _then) = __$AgentInfoCopyWithImpl;
@override @useResult
$Res call({
 int? id,@JsonKey(name: 'user_id') int? userId, String status,@NullableDecimalJsonConverter()@JsonKey(name: 'commission_rate') Decimal? commissionRate,@NullableDecimalJsonConverter()@JsonKey(name: 'total_commission') Decimal? totalCommission,@JsonKey(name: 'approved_at') DateTime? approvedAt
});




}
/// @nodoc
class __$AgentInfoCopyWithImpl<$Res>
    implements _$AgentInfoCopyWith<$Res> {
  __$AgentInfoCopyWithImpl(this._self, this._then);

  final _AgentInfo _self;
  final $Res Function(_AgentInfo) _then;

/// Create a copy of AgentInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? userId = freezed,Object? status = null,Object? commissionRate = freezed,Object? totalCommission = freezed,Object? approvedAt = freezed,}) {
  return _then(_AgentInfo(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,commissionRate: freezed == commissionRate ? _self.commissionRate : commissionRate // ignore: cast_nullable_to_non_nullable
as Decimal?,totalCommission: freezed == totalCommission ? _self.totalCommission : totalCommission // ignore: cast_nullable_to_non_nullable
as Decimal?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
