import 'package:dio/dio.dart';
import 'api_exception.dart';

class ErrorInterceptor extends Interceptor {
  final void Function()? onUnauthorized;
  final void Function()? onPasswordChangeRequired;

  ErrorInterceptor({this.onUnauthorized, this.onPasswordChangeRequired});

  // A 401 on these means "wrong credentials" (or a token already gone), not "session over".
  static const _credentialRoutes = [
    '/auth/user/login',
    '/auth/agent/login',
    '/auth/register',
    '/auth/logout',
  ];

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final path = err.requestOptions.path;
    final isCredentialRoute = _credentialRoutes.any(path.contains);

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return handler.next(
        err.copyWith(
          error: const NetworkException(),
        ),
      );
    }

    final response = err.response;
    int? statusCode = response?.statusCode;
    String message = 'An unexpected error occurred.';
    Map<String, String> fieldErrors = {};
    dynamic data;

    // Three body shapes (§5.3): envelope, validation without `success`, and `{message}` only.
    // `errors` may be an empty list instead of a map.
    if (response?.data != null && response!.data is Map) {
      final resData = response.data as Map;
      data = resData['data'];

      if (resData['message'] is String && (resData['message'] as String).isNotEmpty) {
        message = resData['message'] as String;
      }

      if (resData['errors'] is Map) {
        final errorsMap = resData['errors'] as Map;
        errorsMap.forEach((key, val) {
          if (val is List && val.isNotEmpty) {
            fieldErrors[key.toString()] = val.first.toString();
          } else if (val is String) {
            fieldErrors[key.toString()] = val;
          }
        });
      }
    } else if (response?.statusMessage != null && response!.statusMessage!.isNotEmpty) {
      message = response.statusMessage!;
    }

    final apiException = ApiException(
      statusCode: statusCode,
      message: message,
      fieldErrors: fieldErrors,
      data: data,
    );

    if (statusCode == 401 && !isCredentialRoute) {
      onUnauthorized?.call();
    }
    if (isPasswordChangeRequired(apiException)) {
      onPasswordChangeRequired?.call();
    }

    return handler.next(
      err.copyWith(
        error: apiException,
      ),
    );
  }
}
