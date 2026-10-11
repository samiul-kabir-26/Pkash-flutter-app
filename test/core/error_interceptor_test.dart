import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:pkash/core/network/api_exception.dart';
import 'package:pkash/core/network/error_interceptor.dart';

void main() {
  group('ErrorInterceptor Tests', () {
    test('converts 422 validation response with field errors into ApiException', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com/api/v1'));
      final dioAdapter = DioAdapter(dio: dio);
      dio.interceptors.add(ErrorInterceptor());

      dioAdapter.onGet(
        '/auth/user/login',
        (server) => server.reply(
          422,
          {
            'success': false,
            'message': 'The phone number has already been taken.',
            'errors': {
              'phone_number': ['The phone number has already been taken.'],
              'pin': ['PIN must be at least 5 digits.'],
            },
          },
        ),
      );

      try {
        await dio.get('/auth/user/login');
        fail('Should throw DioException');
      } on DioException catch (e) {
        expect(e.error, isA<ApiException>());
        final apiErr = e.error as ApiException;
        expect(apiErr.statusCode, 422);
        expect(apiErr.message, 'The phone number has already been taken.');
        expect(apiErr.fieldErrors['phone_number'], 'The phone number has already been taken.');
        expect(apiErr.fieldErrors['pin'], 'PIN must be at least 5 digits.');
      }
    });

    test('invokes onUnauthorized for 401 on non-login route', () async {
      bool unauthorizedCalled = false;
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com/api/v1'));
      final dioAdapter = DioAdapter(dio: dio);
      dio.interceptors.add(
        ErrorInterceptor(
          onUnauthorized: () {
            unauthorizedCalled = true;
          },
        ),
      );

      dioAdapter.onGet(
        '/wallets/me',
        (server) => server.reply(401, {'message': 'Unauthenticated.'}),
      );

      try {
        await dio.get('/wallets/me');
      } catch (_) {}

      expect(unauthorizedCalled, isTrue);
    });

    test('does NOT invoke onUnauthorized for 401 on login route', () async {
      bool unauthorizedCalled = false;
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com/api/v1'));
      final dioAdapter = DioAdapter(dio: dio);
      dio.interceptors.add(
        ErrorInterceptor(
          onUnauthorized: () {
            unauthorizedCalled = true;
          },
        ),
      );

      dioAdapter.onPost(
        '/auth/user/login',
        (server) => server.reply(401, {'message': 'Invalid credentials.'}),
      );

      try {
        await dio.post('/auth/user/login');
      } catch (_) {}

      expect(unauthorizedCalled, isFalse);
    });
  });
}
