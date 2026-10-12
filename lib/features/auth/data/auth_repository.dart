import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/auth_user.dart';
import '../domain/session.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});

/// `GET /auth/me`: who the token belongs to and what it may do (`token` is null).
class MeResult {
  final AuthUser user;
  final List<String> abilities;

  const MeResult({required this.user, required this.abilities});
}

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<Session> loginUser({
    required String phoneNumber,
    required String pin,
  }) => apiCall(() async {
        final response = await _dio.post(
          '/auth/user/login',
          data: {
            'phone_number': phoneNumber,
            'pin': pin,
          },
        );
        return Session.fromJson(response.data['data'] as Map<String, dynamic>);
      });

  Future<Session> loginAgent({
    required String phoneNumber,
    required String pin,
  }) => apiCall(() async {
        final response = await _dio.post(
          '/auth/agent/login',
          data: {
            'phone_number': phoneNumber,
            'pin': pin,
          },
        );
        return Session.fromJson(response.data['data'] as Map<String, dynamic>);
      });

  Future<Session> register({
    required String name,
    required String phoneNumber,
    required String pin,
    required String pinConfirmation,
    required String role, // 'USER' or 'AGENT'
  }) => apiCall(() async {
        final response = await _dio.post(
          '/auth/register',
          data: {
            'name': name,
            'phone_number': phoneNumber,
            'pin': pin,
            'pin_confirmation': pinConfirmation,
            'role': role,
          },
        );
        return Session.fromJson(response.data['data'] as Map<String, dynamic>);
      });

  Future<MeResult> me() => apiCall(() async {
        final response = await _dio.get('/auth/me');
        final data = response.data['data'] as Map<String, dynamic>;
        return MeResult(
          user: AuthUser.fromJson(data['user'] as Map<String, dynamic>),
          abilities: (data['abilities'] as List? ?? const []).map((e) => e.toString()).toList(),
        );
      });

  /// Deletes the current token and returns a new one (D8). Requires the current one to be valid.
  Future<({String token, List<String> abilities})> refreshToken() => apiCall(() async {
        final response = await _dio.post('/auth/refresh-token');
        final data = response.data['data'] as Map<String, dynamic>;
        return (
          token: data['token'] as String,
          abilities: (data['abilities'] as List? ?? const []).map((e) => e.toString()).toList(),
        );
      });

  /// Revokes the stored token, or [token] when given (a token that was never stored, §6.5).
  Future<void> logout({String? token}) async {
    try {
      await _dio.post(
        '/auth/logout',
        options: token == null ? null : Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (_) {
      // Ignored: network failure during logout shouldn't prevent local teardown
    }
  }
}
