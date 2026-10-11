// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Transaction {

 int get id;@JsonKey(name: 'user_id') int? get userId;@JsonKey(name: 'agent_id') int? get agentId;@JsonKey(name: 'sender_id') int? get senderId;@JsonKey(name: 'recipient_id') int? get recipientId;@JsonKey(name: 'initiated_by') int? get initiatedBy; String get type;@DecimalJsonConverter() Decimal get amount;@NullableDecimalJsonConverter()@JsonKey(name: 'system_fee_amount') Decimal? get systemFeeAmount;@NullableDecimalJsonConverter()@JsonKey(name: 'agent_commission_amount') Decimal? get agentCommissionAmount; String get currency; String? get description; String get status;@JsonKey(name: 'idempotency_key') String? get idempotencyKey;@NullableDecimalJsonConverter()@JsonKey(name: 'sender_wallet_balance_after') Decimal? get senderWalletBalanceAfter;@NullableDecimalJsonConverter()@JsonKey(name: 'recipient_wallet_balance_after') Decimal? get recipientWalletBalanceAfter;@NullableDecimalJsonConverter()@JsonKey(name: 'agent_wallet_balance_after') Decimal? get agentWalletBalanceAfter;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionCopyWith<Transaction> get copyWith => _$TransactionCopyWithImpl<Transaction>(this as Transaction, _$identity);

  /// Serializes this Transaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Transaction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Transaction&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.agentId, _this.agentId) || other.agentId == _this.agentId)&&(identical(other.senderId, _this.senderId) || other.senderId == _this.senderId)&&(identical(other.recipientId, _this.recipientId) || other.recipientId == _this.recipientId)&&(identical(other.initiatedBy, _this.initiatedBy) || other.initiatedBy == _this.initiatedBy)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.systemFeeAmount, _this.systemFeeAmount) || other.systemFeeAmount == _this.systemFeeAmount)&&(identical(other.agentCommissionAmount, _this.agentCommissionAmount) || other.agentCommissionAmount == _this.agentCommissionAmount)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.idempotencyKey, _this.idempotencyKey) || other.idempotencyKey == _this.idempotencyKey)&&(identical(other.senderWalletBalanceAfter, _this.senderWalletBalanceAfter) || other.senderWalletBalanceAfter == _this.senderWalletBalanceAfter)&&(identical(other.recipientWalletBalanceAfter, _this.recipientWalletBalanceAfter) || other.recipientWalletBalanceAfter == _this.recipientWalletBalanceAfter)&&(identical(other.agentWalletBalanceAfter, _this.agentWalletBalanceAfter) || other.agentWalletBalanceAfter == _this.agentWalletBalanceAfter)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Transaction;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.agentId,_this.senderId,_this.recipientId,_this.initiatedBy,_this.type,_this.amount,_this.systemFeeAmount,_this.agentCommissionAmount,_this.currency,_this.description,_this.status,_this.idempotencyKey,_this.senderWalletBalanceAfter,_this.recipientWalletBalanceAfter,_this.agentWalletBalanceAfter,_this.createdAt);
}

@override
String toString() {
  final _this = this as Transaction;
  return 'Transaction(id: ${_this.id}, userId: ${_this.userId}, agentId: ${_this.agentId}, senderId: ${_this.senderId}, recipientId: ${_this.recipientId}, initiatedBy: ${_this.initiatedBy}, type: ${_this.type}, amount: ${_this.amount}, systemFeeAmount: ${_this.systemFeeAmount}, agentCommissionAmount: ${_this.agentCommissionAmount}, currency: ${_this.currency}, description: ${_this.description}, status: ${_this.status}, idempotencyKey: ${_this.idempotencyKey}, senderWalletBalanceAfter: ${_this.senderWalletBalanceAfter}, recipientWalletBalanceAfter: ${_this.recipientWalletBalanceAfter}, agentWalletBalanceAfter: ${_this.agentWalletBalanceAfter}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $TransactionCopyWith<$Res>  {
  factory $TransactionCopyWith(Transaction value, $Res Function(Transaction) _then) = _$TransactionCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'user_id') int? userId,@JsonKey(name: 'agent_id') int? agentId,@JsonKey(name: 'sender_id') int? senderId,@JsonKey(name: 'recipient_id') int? recipientId,@JsonKey(name: 'initiated_by') int? initiatedBy, String type,@DecimalJsonConverter() Decimal amount,@NullableDecimalJsonConverter()@JsonKey(name: 'system_fee_amount') Decimal? systemFeeAmount,@NullableDecimalJsonConverter()@JsonKey(name: 'agent_commission_amount') Decimal? agentCommissionAmount, String currency, String? description, String status,@JsonKey(name: 'idempotency_key') String? idempotencyKey,@NullableDecimalJsonConverter()@JsonKey(name: 'sender_wallet_balance_after') Decimal? senderWalletBalanceAfter,@NullableDecimalJsonConverter()@JsonKey(name: 'recipient_wallet_balance_after') Decimal? recipientWalletBalanceAfter,@NullableDecimalJsonConverter()@JsonKey(name: 'agent_wallet_balance_after') Decimal? agentWalletBalanceAfter,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$TransactionCopyWithImpl<$Res>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._self, this._then);

  final Transaction _self;
  final $Res Function(Transaction) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = freezed,Object? agentId = freezed,Object? senderId = freezed,Object? recipientId = freezed,Object? initiatedBy = freezed,Object? type = null,Object? amount = null,Object? systemFeeAmount = freezed,Object? agentCommissionAmount = freezed,Object? currency = null,Object? description = freezed,Object? status = null,Object? idempotencyKey = freezed,Object? senderWalletBalanceAfter = freezed,Object? recipientWalletBalanceAfter = freezed,Object? agentWalletBalanceAfter = freezed,Object? createdAt = freezed,}) {
  return _then(Transaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,agentId: freezed == agentId ? _self.agentId : agentId // ignore: cast_nullable_to_non_nullable
as int?,senderId: freezed == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as int?,recipientId: freezed == recipientId ? _self.recipientId : recipientId // ignore: cast_nullable_to_non_nullable
as int?,initiatedBy: freezed == initiatedBy ? _self.initiatedBy : initiatedBy // ignore: cast_nullable_to_non_nullable
as int?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Decimal,systemFeeAmount: freezed == systemFeeAmount ? _self.systemFeeAmount : systemFeeAmount // ignore: cast_nullable_to_non_nullable
as Decimal?,agentCommissionAmount: freezed == agentCommissionAmount ? _self.agentCommissionAmount : agentCommissionAmount // ignore: cast_nullable_to_non_nullable
as Decimal?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,senderWalletBalanceAfter: freezed == senderWalletBalanceAfter ? _self.senderWalletBalanceAfter : senderWalletBalanceAfter // ignore: cast_nullable_to_non_nullable
as Decimal?,recipientWalletBalanceAfter: freezed == recipientWalletBalanceAfter ? _self.recipientWalletBalanceAfter : recipientWalletBalanceAfter // ignore: cast_nullable_to_non_nullable
as Decimal?,agentWalletBalanceAfter: freezed == agentWalletBalanceAfter ? _self.agentWalletBalanceAfter : agentWalletBalanceAfter // ignore: cast_nullable_to_non_nullable
as Decimal?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Transaction].
extension TransactionPatterns on Transaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Transaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Transaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Transaction value)  $default,){
final _that = this;
switch (_that) {
case _Transaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Transaction value)?  $default,){
final _that = this;
switch (_that) {
case _Transaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'user_id')  int? userId, @JsonKey(name: 'agent_id')  int? agentId, @JsonKey(name: 'sender_id')  int? senderId, @JsonKey(name: 'recipient_id')  int? recipientId, @JsonKey(name: 'initiated_by')  int? initiatedBy,  String type, @DecimalJsonConverter()  Decimal amount, @NullableDecimalJsonConverter()@JsonKey(name: 'system_fee_amount')  Decimal? systemFeeAmount, @NullableDecimalJsonConverter()@JsonKey(name: 'agent_commission_amount')  Decimal? agentCommissionAmount,  String currency,  String? description,  String status, @JsonKey(name: 'idempotency_key')  String? idempotencyKey, @NullableDecimalJsonConverter()@JsonKey(name: 'sender_wallet_balance_after')  Decimal? senderWalletBalanceAfter, @NullableDecimalJsonConverter()@JsonKey(name: 'recipient_wallet_balance_after')  Decimal? recipientWalletBalanceAfter, @NullableDecimalJsonConverter()@JsonKey(name: 'agent_wallet_balance_after')  Decimal? agentWalletBalanceAfter, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that.id,_that.userId,_that.agentId,_that.senderId,_that.recipientId,_that.initiatedBy,_that.type,_that.amount,_that.systemFeeAmount,_that.agentCommissionAmount,_that.currency,_that.description,_that.status,_that.idempotencyKey,_that.senderWalletBalanceAfter,_that.recipientWalletBalanceAfter,_that.agentWalletBalanceAfter,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'user_id')  int? userId, @JsonKey(name: 'agent_id')  int? agentId, @JsonKey(name: 'sender_id')  int? senderId, @JsonKey(name: 'recipient_id')  int? recipientId, @JsonKey(name: 'initiated_by')  int? initiatedBy,  String type, @DecimalJsonConverter()  Decimal amount, @NullableDecimalJsonConverter()@JsonKey(name: 'system_fee_amount')  Decimal? systemFeeAmount, @NullableDecimalJsonConverter()@JsonKey(name: 'agent_commission_amount')  Decimal? agentCommissionAmount,  String currency,  String? description,  String status, @JsonKey(name: 'idempotency_key')  String? idempotencyKey, @NullableDecimalJsonConverter()@JsonKey(name: 'sender_wallet_balance_after')  Decimal? senderWalletBalanceAfter, @NullableDecimalJsonConverter()@JsonKey(name: 'recipient_wallet_balance_after')  Decimal? recipientWalletBalanceAfter, @NullableDecimalJsonConverter()@JsonKey(name: 'agent_wallet_balance_after')  Decimal? agentWalletBalanceAfter, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Transaction():
return $default(_that.id,_that.userId,_that.agentId,_that.senderId,_that.recipientId,_that.initiatedBy,_that.type,_that.amount,_that.systemFeeAmount,_that.agentCommissionAmount,_that.currency,_that.description,_that.status,_that.idempotencyKey,_that.senderWalletBalanceAfter,_that.recipientWalletBalanceAfter,_that.agentWalletBalanceAfter,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'user_id')  int? userId, @JsonKey(name: 'agent_id')  int? agentId, @JsonKey(name: 'sender_id')  int? senderId, @JsonKey(name: 'recipient_id')  int? recipientId, @JsonKey(name: 'initiated_by')  int? initiatedBy,  String type, @DecimalJsonConverter()  Decimal amount, @NullableDecimalJsonConverter()@JsonKey(name: 'system_fee_amount')  Decimal? systemFeeAmount, @NullableDecimalJsonConverter()@JsonKey(name: 'agent_commission_amount')  Decimal? agentCommissionAmount,  String currency,  String? description,  String status, @JsonKey(name: 'idempotency_key')  String? idempotencyKey, @NullableDecimalJsonConverter()@JsonKey(name: 'sender_wallet_balance_after')  Decimal? senderWalletBalanceAfter, @NullableDecimalJsonConverter()@JsonKey(name: 'recipient_wallet_balance_after')  Decimal? recipientWalletBalanceAfter, @NullableDecimalJsonConverter()@JsonKey(name: 'agent_wallet_balance_after')  Decimal? agentWalletBalanceAfter, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that.id,_that.userId,_that.agentId,_that.senderId,_that.recipientId,_that.initiatedBy,_that.type,_that.amount,_that.systemFeeAmount,_that.agentCommissionAmount,_that.currency,_that.description,_that.status,_that.idempotencyKey,_that.senderWalletBalanceAfter,_that.recipientWalletBalanceAfter,_that.agentWalletBalanceAfter,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Transaction extends Transaction {
  const _Transaction({required this.id, @JsonKey(name: 'user_id') this.userId, @JsonKey(name: 'agent_id') this.agentId, @JsonKey(name: 'sender_id') this.senderId, @JsonKey(name: 'recipient_id') this.recipientId, @JsonKey(name: 'initiated_by') this.initiatedBy, required this.type, @DecimalJsonConverter() required this.amount, @NullableDecimalJsonConverter()@JsonKey(name: 'system_fee_amount') this.systemFeeAmount, @NullableDecimalJsonConverter()@JsonKey(name: 'agent_commission_amount') this.agentCommissionAmount, this.currency = 'BDT', this.description, this.status = 'COMPLETED', @JsonKey(name: 'idempotency_key') this.idempotencyKey, @NullableDecimalJsonConverter()@JsonKey(name: 'sender_wallet_balance_after') this.senderWalletBalanceAfter, @NullableDecimalJsonConverter()@JsonKey(name: 'recipient_wallet_balance_after') this.recipientWalletBalanceAfter, @NullableDecimalJsonConverter()@JsonKey(name: 'agent_wallet_balance_after') this.agentWalletBalanceAfter, @JsonKey(name: 'created_at') this.createdAt}): super._();
  factory _Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);

@override final  int id;
@override@JsonKey(name: 'user_id') final  int? userId;
@override@JsonKey(name: 'agent_id') final  int? agentId;
@override@JsonKey(name: 'sender_id') final  int? senderId;
@override@JsonKey(name: 'recipient_id') final  int? recipientId;
@override@JsonKey(name: 'initiated_by') final  int? initiatedBy;
@override final  String type;
@override@DecimalJsonConverter() final  Decimal amount;
@override@NullableDecimalJsonConverter()@JsonKey(name: 'system_fee_amount') final  Decimal? systemFeeAmount;
@override@NullableDecimalJsonConverter()@JsonKey(name: 'agent_commission_amount') final  Decimal? agentCommissionAmount;
@override@JsonKey() final  String currency;
@override final  String? description;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'idempotency_key') final  String? idempotencyKey;
@override@NullableDecimalJsonConverter()@JsonKey(name: 'sender_wallet_balance_after') final  Decimal? senderWalletBalanceAfter;
@override@NullableDecimalJsonConverter()@JsonKey(name: 'recipient_wallet_balance_after') final  Decimal? recipientWalletBalanceAfter;
@override@NullableDecimalJsonConverter()@JsonKey(name: 'agent_wallet_balance_after') final  Decimal? agentWalletBalanceAfter;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionCopyWith<_Transaction> get copyWith => __$TransactionCopyWithImpl<_Transaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Transaction&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.agentId, agentId) || other.agentId == agentId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.recipientId, recipientId) || other.recipientId == recipientId)&&(identical(other.initiatedBy, initiatedBy) || other.initiatedBy == initiatedBy)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.systemFeeAmount, systemFeeAmount) || other.systemFeeAmount == systemFeeAmount)&&(identical(other.agentCommissionAmount, agentCommissionAmount) || other.agentCommissionAmount == agentCommissionAmount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey)&&(identical(other.senderWalletBalanceAfter, senderWalletBalanceAfter) || other.senderWalletBalanceAfter == senderWalletBalanceAfter)&&(identical(other.recipientWalletBalanceAfter, recipientWalletBalanceAfter) || other.recipientWalletBalanceAfter == recipientWalletBalanceAfter)&&(identical(other.agentWalletBalanceAfter, agentWalletBalanceAfter) || other.agentWalletBalanceAfter == agentWalletBalanceAfter)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,agentId,senderId,recipientId,initiatedBy,type,amount,systemFeeAmount,agentCommissionAmount,currency,description,status,idempotencyKey,senderWalletBalanceAfter,recipientWalletBalanceAfter,agentWalletBalanceAfter,createdAt);
}

@override
String toString() {
    return 'Transaction(id: $id, userId: $userId, agentId: $agentId, senderId: $senderId, recipientId: $recipientId, initiatedBy: $initiatedBy, type: $type, amount: $amount, systemFeeAmount: $systemFeeAmount, agentCommissionAmount: $agentCommissionAmount, currency: $currency, description: $description, status: $status, idempotencyKey: $idempotencyKey, senderWalletBalanceAfter: $senderWalletBalanceAfter, recipientWalletBalanceAfter: $recipientWalletBalanceAfter, agentWalletBalanceAfter: $agentWalletBalanceAfter, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TransactionCopyWith<$Res> implements $TransactionCopyWith<$Res> {
  factory _$TransactionCopyWith(_Transaction value, $Res Function(_Transaction) _then) = __$TransactionCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'user_id') int? userId,@JsonKey(name: 'agent_id') int? agentId,@JsonKey(name: 'sender_id') int? senderId,@JsonKey(name: 'recipient_id') int? recipientId,@JsonKey(name: 'initiated_by') int? initiatedBy, String type,@DecimalJsonConverter() Decimal amount,@NullableDecimalJsonConverter()@JsonKey(name: 'system_fee_amount') Decimal? systemFeeAmount,@NullableDecimalJsonConverter()@JsonKey(name: 'agent_commission_amount') Decimal? agentCommissionAmount, String currency, String? description, String status,@JsonKey(name: 'idempotency_key') String? idempotencyKey,@NullableDecimalJsonConverter()@JsonKey(name: 'sender_wallet_balance_after') Decimal? senderWalletBalanceAfter,@NullableDecimalJsonConverter()@JsonKey(name: 'recipient_wallet_balance_after') Decimal? recipientWalletBalanceAfter,@NullableDecimalJsonConverter()@JsonKey(name: 'agent_wallet_balance_after') Decimal? agentWalletBalanceAfter,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$TransactionCopyWithImpl<$Res>
    implements _$TransactionCopyWith<$Res> {
  __$TransactionCopyWithImpl(this._self, this._then);

  final _Transaction _self;
  final $Res Function(_Transaction) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = freezed,Object? agentId = freezed,Object? senderId = freezed,Object? recipientId = freezed,Object? initiatedBy = freezed,Object? type = null,Object? amount = null,Object? systemFeeAmount = freezed,Object? agentCommissionAmount = freezed,Object? currency = null,Object? description = freezed,Object? status = null,Object? idempotencyKey = freezed,Object? senderWalletBalanceAfter = freezed,Object? recipientWalletBalanceAfter = freezed,Object? agentWalletBalanceAfter = freezed,Object? createdAt = freezed,}) {
  return _then(_Transaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,agentId: freezed == agentId ? _self.agentId : agentId // ignore: cast_nullable_to_non_nullable
as int?,senderId: freezed == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as int?,recipientId: freezed == recipientId ? _self.recipientId : recipientId // ignore: cast_nullable_to_non_nullable
as int?,initiatedBy: freezed == initiatedBy ? _self.initiatedBy : initiatedBy // ignore: cast_nullable_to_non_nullable
as int?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Decimal,systemFeeAmount: freezed == systemFeeAmount ? _self.systemFeeAmount : systemFeeAmount // ignore: cast_nullable_to_non_nullable
as Decimal?,agentCommissionAmount: freezed == agentCommissionAmount ? _self.agentCommissionAmount : agentCommissionAmount // ignore: cast_nullable_to_non_nullable
as Decimal?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,senderWalletBalanceAfter: freezed == senderWalletBalanceAfter ? _self.senderWalletBalanceAfter : senderWalletBalanceAfter // ignore: cast_nullable_to_non_nullable
as Decimal?,recipientWalletBalanceAfter: freezed == recipientWalletBalanceAfter ? _self.recipientWalletBalanceAfter : recipientWalletBalanceAfter // ignore: cast_nullable_to_non_nullable
as Decimal?,agentWalletBalanceAfter: freezed == agentWalletBalanceAfter ? _self.agentWalletBalanceAfter : agentWalletBalanceAfter // ignore: cast_nullable_to_non_nullable
as Decimal?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
