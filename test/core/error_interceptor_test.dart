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

    Future<ApiException> errorFor(
      int status,
      Object body, {
      String path = '/wallets/me',
      ErrorInterceptor? interceptor,
    }) async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com/api/v1'));
      DioAdapter(dio: dio).onGet(path, (server) => server.reply(status, body));
      dio.interceptors.add(interceptor ?? ErrorInterceptor());
      try {
        await apiCall(() => dio.get(path));
      } on ApiException catch (e) {
        return e;
      }
      fail('expected an ApiException');
    }

    test('apiCall unwraps DioException so callers can catch ApiException', () async {
      final e = await errorFor(404, {'success': false, 'message': 'Agent user not found.', 'errors': []});
      expect(e.statusCode, 404);
      expect(e.message, 'Agent user not found.');
      expect(e.fieldErrors, isEmpty); // `errors: []` is a list, not a map
    });

    test('handles the real 422 shape (no `success` key)', () async {
      final e = await errorFor(422, {
        'message': 'The phone number must be a valid 11-digit Bangladeshi mobile number.',
        'errors': {
          'agent_phone': ['The phone number must be a valid 11-digit Bangladeshi mobile number.'],
        },
      });
      expect(e.fieldErrors.keys, ['agent_phone']);
    });

    test('handles the Laravel `{message}`-only shape (invalid signature 403)', () async {
      final e = await errorFor(403, {'message': 'Invalid signature.'});
      expect(e.statusCode, 403);
      expect(e.message, 'Invalid signature.');
    });

    test('does NOT invoke onUnauthorized for 401 on register', () async {
      var called = false;
      await errorFor(
        401,
        {'message': 'Unauthenticated.'},
        path: '/auth/register',
        interceptor: ErrorInterceptor(onUnauthorized: () => called = true),
      );
      expect(called, isFalse);
    });

    test('raises the password-change flag only for that exact 403', () async {
      var flagged = 0;
      final interceptor = ErrorInterceptor(onPasswordChangeRequired: () => flagged++);

      final e = await errorFor(
        403,
        {'success': false, 'message': passwordChangeRequiredMessage, 'errors': []},
        interceptor: interceptor,
      );
      expect(isPasswordChangeRequired(e), isTrue);
      expect(flagged, 1);

      final other = await errorFor(
        403,
        {'success': false, 'message': 'Your wallet is blocked.', 'errors': []},
        interceptor: interceptor,
      );
      expect(isPasswordChangeRequired(other), isFalse);
      expect(flagged, 1);
    });
  });
}
