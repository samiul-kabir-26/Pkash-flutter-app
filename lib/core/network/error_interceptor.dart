import 'package:dio/dio.dart';
import 'api_exception.dart';

class ErrorInterceptor extends Interceptor {
  final void Function()? onUnauthorized;

  ErrorInterceptor({this.onUnauthorized});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final path = err.requestOptions.path;
    final isLoginRoute = path.contains('/auth/user/login') ||
        path.contains('/auth/agent/login') ||
        path.contains('/auth/admin/login');

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

    if (statusCode == 401 && !isLoginRoute) {
      onUnauthorized?.call();
    }

    final apiException = ApiException(
      statusCode: statusCode,
      message: message,
      fieldErrors: fieldErrors,
      data: data,
    );

    return handler.next(
      err.copyWith(
        error: apiException,
      ),
    );
  }
}
