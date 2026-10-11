import 'package:decimal/decimal.dart';
import 'package:json_annotation/json_annotation.dart';
import 'money.dart';

class DecimalJsonConverter implements JsonConverter<Decimal, Object?> {
  const DecimalJsonConverter();

  @override
  Decimal fromJson(Object? json) => parseMoney(json);

  @override
  Object? toJson(Decimal object) => toApiAmount(object);
}

class NullableDecimalJsonConverter implements JsonConverter<Decimal?, Object?> {
  const NullableDecimalJsonConverter();

  @override
  Decimal? fromJson(Object? json) {
    if (json == null) return null;
    return parseMoney(json);
  }

  @override
  Object? toJson(Decimal? object) {
    if (object == null) return null;
    return toApiAmount(object);
  }
}
