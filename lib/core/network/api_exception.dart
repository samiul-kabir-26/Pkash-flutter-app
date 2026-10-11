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
