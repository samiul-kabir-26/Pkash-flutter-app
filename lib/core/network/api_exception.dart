import 'package:dio/dio.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final Map<String, String> fieldErrors;
  final dynamic data;

  const ApiException({
    this.statusCode,
    required this.message,
    this.fieldErrors = const {},
    this.data,
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isValidationError => statusCode == 422;
  bool get isRateLimited => statusCode == 429;
  bool get isServerError => statusCode != null && statusCode! >= 500;

  @override
  String toString() => 'ApiException(status: $statusCode, message: $message, errors: $fieldErrors)';
}

class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'Network connection failed. Please check your internet connection.',
  }) : super(statusCode: null);
}

/// The one place where a server message is matched (§5.4): a staff member with an
/// unfinished invite gets this 403 on every wallet/transaction/user route.
const passwordChangeRequiredMessage = 'You must change your password before proceeding.';

bool isPasswordChangeRequired(ApiException e) =>
    e.isForbidden && e.message.trim() == passwordChangeRequiredMessage;

/// Dio always throws [DioException]; the ErrorInterceptor stores the typed error in
/// `DioException.error`. Repositories wrap calls with this so callers can branch on
/// [ApiException] / [NetworkException] directly.
Future<T> apiCall<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (e) {
    final error = e.error;
    if (error is ApiException) throw error;
    if (e.response == null) throw const NetworkException();
    throw ApiException(
      statusCode: e.response?.statusCode,
      message: 'An unexpected error occurred.',
    );
  }
}
