// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Wallet {

 int get id;@JsonKey(name: 'user_id') int get userId;/// `USER` or `AGENT`: one wallet per role (§0 "What changed").
 String get kind;@DecimalJsonConverter() Decimal get balance; String get currency;@JsonKey(name: 'is_blocked') bool get isBlocked;@JsonKey(name: 'blocked_by') int? get blockedBy;@JsonKey(name: 'blocked_at') DateTime? get blockedAt;
/// Create a copy of Wallet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletCopyWith<Wallet> get copyWith => _$WalletCopyWithImpl<Wallet>(this as Wallet, _$identity);

  /// Serializes this Wallet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Wallet;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Wallet&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.balance, _this.balance) || other.balance == _this.balance)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.isBlocked, _this.isBlocked) || other.isBlocked == _this.isBlocked)&&(identical(other.blockedBy, _this.blockedBy) || other.blockedBy == _this.blockedBy)&&(identical(other.blockedAt, _this.blockedAt) || other.blockedAt == _this.blockedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Wallet;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.kind,_this.balance,_this.currency,_this.isBlocked,_this.blockedBy,_this.blockedAt);
}

@override
String toString() {
  final _this = this as Wallet;
  return 'Wallet(id: ${_this.id}, userId: ${_this.userId}, kind: ${_this.kind}, balance: ${_this.balance}, currency: ${_this.currency}, isBlocked: ${_this.isBlocked}, blockedBy: ${_this.blockedBy}, blockedAt: ${_this.blockedAt})';
}


}

/// @nodoc
abstract mixin class $WalletCopyWith<$Res>  {
  factory $WalletCopyWith(Wallet value, $Res Function(Wallet) _then) = _$WalletCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'user_id') int userId, String kind,@DecimalJsonConverter() Decimal balance, String currency,@JsonKey(name: 'is_blocked') bool isBlocked,@JsonKey(name: 'blocked_by') int? blockedBy,@JsonKey(name: 'blocked_at') DateTime? blockedAt
});




}
/// @nodoc
class _$WalletCopyWithImpl<$Res>
    implements $WalletCopyWith<$Res> {
  _$WalletCopyWithImpl(this._self, this._then);

  final Wallet _self;
  final $Res Function(Wallet) _then;

/// Create a copy of Wallet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? kind = null,Object? balance = null,Object? currency = null,Object? isBlocked = null,Object? blockedBy = freezed,Object? blockedAt = freezed,}) {
  return _then(Wallet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as Decimal,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,blockedBy: freezed == blockedBy ? _self.blockedBy : blockedBy // ignore: cast_nullable_to_non_nullable
as int?,blockedAt: freezed == blockedAt ? _self.blockedAt : blockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Wallet].
extension WalletPatterns on Wallet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Wallet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Wallet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Wallet value)  $default,){
final _that = this;
switch (_that) {
case _Wallet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Wallet value)?  $default,){
final _that = this;
switch (_that) {
case _Wallet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'user_id')  int userId,  String kind, @DecimalJsonConverter()  Decimal balance,  String currency, @JsonKey(name: 'is_blocked')  bool isBlocked, @JsonKey(name: 'blocked_by')  int? blockedBy, @JsonKey(name: 'blocked_at')  DateTime? blockedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Wallet() when $default != null:
return $default(_that.id,_that.userId,_that.kind,_that.balance,_that.currency,_that.isBlocked,_that.blockedBy,_that.blockedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'user_id')  int userId,  String kind, @DecimalJsonConverter()  Decimal balance,  String currency, @JsonKey(name: 'is_blocked')  bool isBlocked, @JsonKey(name: 'blocked_by')  int? blockedBy, @JsonKey(name: 'blocked_at')  DateTime? blockedAt)  $default,) {final _that = this;
switch (_that) {
case _Wallet():
return $default(_that.id,_that.userId,_that.kind,_that.balance,_that.currency,_that.isBlocked,_that.blockedBy,_that.blockedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'user_id')  int userId,  String kind, @DecimalJsonConverter()  Decimal balance,  String currency, @JsonKey(name: 'is_blocked')  bool isBlocked, @JsonKey(name: 'blocked_by')  int? blockedBy, @JsonKey(name: 'blocked_at')  DateTime? blockedAt)?  $default,) {final _that = this;
switch (_that) {
case _Wallet() when $default != null:
return $default(_that.id,_that.userId,_that.kind,_that.balance,_that.currency,_that.isBlocked,_that.blockedBy,_that.blockedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Wallet implements Wallet {
  const _Wallet({required this.id, @JsonKey(name: 'user_id') required this.userId, this.kind = 'USER', @DecimalJsonConverter() required this.balance, this.currency = 'BDT', @JsonKey(name: 'is_blocked') this.isBlocked = false, @JsonKey(name: 'blocked_by') this.blockedBy, @JsonKey(name: 'blocked_at') this.blockedAt});
  factory _Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);

@override final  int id;
@override@JsonKey(name: 'user_id') final  int userId;
/// `USER` or `AGENT`: one wallet per role (§0 "What changed").
@override@JsonKey() final  String kind;
@override@DecimalJsonConverter() final  Decimal balance;
@override@JsonKey() final  String currency;
@override@JsonKey(name: 'is_blocked') final  bool isBlocked;
@override@JsonKey(name: 'blocked_by') final  int? blockedBy;
@override@JsonKey(name: 'blocked_at') final  DateTime? blockedAt;

/// Create a copy of Wallet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletCopyWith<_Wallet> get copyWith => __$WalletCopyWithImpl<_Wallet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WalletToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Wallet&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.isBlocked, isBlocked) || other.isBlocked == isBlocked)&&(identical(other.blockedBy, blockedBy) || other.blockedBy == blockedBy)&&(identical(other.blockedAt, blockedAt) || other.blockedAt == blockedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,kind,balance,currency,isBlocked,blockedBy,blockedAt);
}

@override
String toString() {
    return 'Wallet(id: $id, userId: $userId, kind: $kind, balance: $balance, currency: $currency, isBlocked: $isBlocked, blockedBy: $blockedBy, blockedAt: $blockedAt)';
}


}

/// @nodoc
abstract mixin class _$WalletCopyWith<$Res> implements $WalletCopyWith<$Res> {
  factory _$WalletCopyWith(_Wallet value, $Res Function(_Wallet) _then) = __$WalletCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'user_id') int userId, String kind,@DecimalJsonConverter() Decimal balance, String currency,@JsonKey(name: 'is_blocked') bool isBlocked,@JsonKey(name: 'blocked_by') int? blockedBy,@JsonKey(name: 'blocked_at') DateTime? blockedAt
});




}
/// @nodoc
class __$WalletCopyWithImpl<$Res>
    implements _$WalletCopyWith<$Res> {
  __$WalletCopyWithImpl(this._self, this._then);

  final _Wallet _self;
  final $Res Function(_Wallet) _then;

/// Create a copy of Wallet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? kind = null,Object? balance = null,Object? currency = null,Object? isBlocked = null,Object? blockedBy = freezed,Object? blockedAt = freezed,}) {
  return _then(_Wallet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as Decimal,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,blockedBy: freezed == blockedBy ? _self.blockedBy : blockedBy // ignore: cast_nullable_to_non_nullable
as int?,blockedAt: freezed == blockedAt ? _self.blockedAt : blockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
