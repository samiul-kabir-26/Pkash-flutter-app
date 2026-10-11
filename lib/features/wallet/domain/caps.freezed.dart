// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'caps.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Caps {

 int? get id;@JsonKey(name: 'user_id') int? get userId;@DecimalJsonConverter()@JsonKey(name: 'daily_cap') Decimal get dailyCap;@DecimalJsonConverter()@JsonKey(name: 'monthly_cap') Decimal get monthlyCap;@DecimalJsonConverter()@JsonKey(name: 'daily_used') Decimal get dailyUsed;@DecimalJsonConverter()@JsonKey(name: 'monthly_used') Decimal get monthlyUsed;
/// Create a copy of Caps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CapsCopyWith<Caps> get copyWith => _$CapsCopyWithImpl<Caps>(this as Caps, _$identity);

  /// Serializes this Caps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Caps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Caps&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.dailyCap, _this.dailyCap) || other.dailyCap == _this.dailyCap)&&(identical(other.monthlyCap, _this.monthlyCap) || other.monthlyCap == _this.monthlyCap)&&(identical(other.dailyUsed, _this.dailyUsed) || other.dailyUsed == _this.dailyUsed)&&(identical(other.monthlyUsed, _this.monthlyUsed) || other.monthlyUsed == _this.monthlyUsed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Caps;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.dailyCap,_this.monthlyCap,_this.dailyUsed,_this.monthlyUsed);
}

@override
String toString() {
  final _this = this as Caps;
  return 'Caps(id: ${_this.id}, userId: ${_this.userId}, dailyCap: ${_this.dailyCap}, monthlyCap: ${_this.monthlyCap}, dailyUsed: ${_this.dailyUsed}, monthlyUsed: ${_this.monthlyUsed})';
}


}

/// @nodoc
abstract mixin class $CapsCopyWith<$Res>  {
  factory $CapsCopyWith(Caps value, $Res Function(Caps) _then) = _$CapsCopyWithImpl;
@useResult
$Res call({
 int? id,@JsonKey(name: 'user_id') int? userId,@DecimalJsonConverter()@JsonKey(name: 'daily_cap') Decimal dailyCap,@DecimalJsonConverter()@JsonKey(name: 'monthly_cap') Decimal monthlyCap,@DecimalJsonConverter()@JsonKey(name: 'daily_used') Decimal dailyUsed,@DecimalJsonConverter()@JsonKey(name: 'monthly_used') Decimal monthlyUsed
});




}
/// @nodoc
class _$CapsCopyWithImpl<$Res>
    implements $CapsCopyWith<$Res> {
  _$CapsCopyWithImpl(this._self, this._then);

  final Caps _self;
  final $Res Function(Caps) _then;

/// Create a copy of Caps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? userId = freezed,Object? dailyCap = null,Object? monthlyCap = null,Object? dailyUsed = null,Object? monthlyUsed = null,}) {
  return _then(Caps(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,dailyCap: null == dailyCap ? _self.dailyCap : dailyCap // ignore: cast_nullable_to_non_nullable
as Decimal,monthlyCap: null == monthlyCap ? _self.monthlyCap : monthlyCap // ignore: cast_nullable_to_non_nullable
as Decimal,dailyUsed: null == dailyUsed ? _self.dailyUsed : dailyUsed // ignore: cast_nullable_to_non_nullable
as Decimal,monthlyUsed: null == monthlyUsed ? _self.monthlyUsed : monthlyUsed // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [Caps].
extension CapsPatterns on Caps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Caps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Caps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Caps value)  $default,){
final _that = this;
switch (_that) {
case _Caps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Caps value)?  $default,){
final _that = this;
switch (_that) {
case _Caps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id, @JsonKey(name: 'user_id')  int? userId, @DecimalJsonConverter()@JsonKey(name: 'daily_cap')  Decimal dailyCap, @DecimalJsonConverter()@JsonKey(name: 'monthly_cap')  Decimal monthlyCap, @DecimalJsonConverter()@JsonKey(name: 'daily_used')  Decimal dailyUsed, @DecimalJsonConverter()@JsonKey(name: 'monthly_used')  Decimal monthlyUsed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Caps() when $default != null:
return $default(_that.id,_that.userId,_that.dailyCap,_that.monthlyCap,_that.dailyUsed,_that.monthlyUsed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id, @JsonKey(name: 'user_id')  int? userId, @DecimalJsonConverter()@JsonKey(name: 'daily_cap')  Decimal dailyCap, @DecimalJsonConverter()@JsonKey(name: 'monthly_cap')  Decimal monthlyCap, @DecimalJsonConverter()@JsonKey(name: 'daily_used')  Decimal dailyUsed, @DecimalJsonConverter()@JsonKey(name: 'monthly_used')  Decimal monthlyUsed)  $default,) {final _that = this;
switch (_that) {
case _Caps():
return $default(_that.id,_that.userId,_that.dailyCap,_that.monthlyCap,_that.dailyUsed,_that.monthlyUsed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id, @JsonKey(name: 'user_id')  int? userId, @DecimalJsonConverter()@JsonKey(name: 'daily_cap')  Decimal dailyCap, @DecimalJsonConverter()@JsonKey(name: 'monthly_cap')  Decimal monthlyCap, @DecimalJsonConverter()@JsonKey(name: 'daily_used')  Decimal dailyUsed, @DecimalJsonConverter()@JsonKey(name: 'monthly_used')  Decimal monthlyUsed)?  $default,) {final _that = this;
switch (_that) {
case _Caps() when $default != null:
return $default(_that.id,_that.userId,_that.dailyCap,_that.monthlyCap,_that.dailyUsed,_that.monthlyUsed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Caps extends Caps {
  const _Caps({this.id, @JsonKey(name: 'user_id') this.userId, @DecimalJsonConverter()@JsonKey(name: 'daily_cap') required this.dailyCap, @DecimalJsonConverter()@JsonKey(name: 'monthly_cap') required this.monthlyCap, @DecimalJsonConverter()@JsonKey(name: 'daily_used') required this.dailyUsed, @DecimalJsonConverter()@JsonKey(name: 'monthly_used') required this.monthlyUsed}): super._();
  factory _Caps.fromJson(Map<String, dynamic> json) => _$CapsFromJson(json);

@override final  int? id;
@override@JsonKey(name: 'user_id') final  int? userId;
@override@DecimalJsonConverter()@JsonKey(name: 'daily_cap') final  Decimal dailyCap;
@override@DecimalJsonConverter()@JsonKey(name: 'monthly_cap') final  Decimal monthlyCap;
@override@DecimalJsonConverter()@JsonKey(name: 'daily_used') final  Decimal dailyUsed;
@override@DecimalJsonConverter()@JsonKey(name: 'monthly_used') final  Decimal monthlyUsed;

/// Create a copy of Caps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CapsCopyWith<_Caps> get copyWith => __$CapsCopyWithImpl<_Caps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CapsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Caps&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.dailyCap, dailyCap) || other.dailyCap == dailyCap)&&(identical(other.monthlyCap, monthlyCap) || other.monthlyCap == monthlyCap)&&(identical(other.dailyUsed, dailyUsed) || other.dailyUsed == dailyUsed)&&(identical(other.monthlyUsed, monthlyUsed) || other.monthlyUsed == monthlyUsed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,dailyCap,monthlyCap,dailyUsed,monthlyUsed);
}

@override
String toString() {
    return 'Caps(id: $id, userId: $userId, dailyCap: $dailyCap, monthlyCap: $monthlyCap, dailyUsed: $dailyUsed, monthlyUsed: $monthlyUsed)';
}


}

/// @nodoc
abstract mixin class _$CapsCopyWith<$Res> implements $CapsCopyWith<$Res> {
  factory _$CapsCopyWith(_Caps value, $Res Function(_Caps) _then) = __$CapsCopyWithImpl;
@override @useResult
$Res call({
 int? id,@JsonKey(name: 'user_id') int? userId,@DecimalJsonConverter()@JsonKey(name: 'daily_cap') Decimal dailyCap,@DecimalJsonConverter()@JsonKey(name: 'monthly_cap') Decimal monthlyCap,@DecimalJsonConverter()@JsonKey(name: 'daily_used') Decimal dailyUsed,@DecimalJsonConverter()@JsonKey(name: 'monthly_used') Decimal monthlyUsed
});




}
/// @nodoc
class __$CapsCopyWithImpl<$Res>
    implements _$CapsCopyWith<$Res> {
  __$CapsCopyWithImpl(this._self, this._then);

  final _Caps _self;
  final $Res Function(_Caps) _then;

/// Create a copy of Caps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? userId = freezed,Object? dailyCap = null,Object? monthlyCap = null,Object? dailyUsed = null,Object? monthlyUsed = null,}) {
  return _then(_Caps(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,dailyCap: null == dailyCap ? _self.dailyCap : dailyCap // ignore: cast_nullable_to_non_nullable
as Decimal,monthlyCap: null == monthlyCap ? _self.monthlyCap : monthlyCap // ignore: cast_nullable_to_non_nullable
as Decimal,dailyUsed: null == dailyUsed ? _self.dailyUsed : dailyUsed // ignore: cast_nullable_to_non_nullable
as Decimal,monthlyUsed: null == monthlyUsed ? _self.monthlyUsed : monthlyUsed // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}

// dart format on
