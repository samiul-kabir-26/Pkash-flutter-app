import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/session.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<Session> loginUser({
    required String phoneNumber,
    required String pin,
  }) async {
    final response = await _dio.post(
      '/auth/user/login',
      data: {
        'phone_number': phoneNumber,
        'pin': pin,
      },
    );
    return Session.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Session> loginAgent({
    required String phoneNumber,
    required String pin,
  }) async {
    final response = await _dio.post(
      '/auth/agent/login',
      data: {
        'phone_number': phoneNumber,
        'pin': pin,
      },
    );
    return Session.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Session> register({
    required String name,
    required String phoneNumber,
    required String pin,
    required String pinConfirmation,
    required String role, // 'USER' or 'AGENT'
  }) async {
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
  }

  Future<Map<String, dynamic>> refreshToken() async {
    final response = await _dio.post('/auth/refresh-token');
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {
      // Ignored: network failure during logout shouldn't prevent local teardown
    }
  }
}
