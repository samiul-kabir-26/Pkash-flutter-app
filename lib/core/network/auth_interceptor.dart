import 'package:dio/dio.dart';
import '../storage/secure_token_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureTokenStorage _tokenStorage;

  AuthInterceptor(this._tokenStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers['Accept'] = 'application/json';

    // An explicit header wins (e.g. revoking a token that was never stored, §6.5).
    final token = options.headers.containsKey('Authorization') ? null : await _tokenStorage.readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }
}
