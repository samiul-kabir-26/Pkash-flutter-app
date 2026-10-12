import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/env.dart';
import '../storage/secure_token_storage.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';

final secureTokenStorageProvider = Provider<SecureTokenStorage>((ref) {
  return SecureTokenStorage();
});

class UnauthenticatedEventNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void trigger() => state++;
}

// A callback notifier that SessionController can listen to for 401 unauthenticated events
final unauthenticatedEventProvider =
    NotifierProvider<UnauthenticatedEventNotifier, int>(UnauthenticatedEventNotifier.new);

/// Set when any call returns 403 "You must change your password before proceeding." (§6.7).
class PasswordChangeRequiredNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final passwordChangeRequiredProvider =
    NotifierProvider<PasswordChangeRequiredNotifier, bool>(PasswordChangeRequiredNotifier.new);

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureTokenStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(storage),
    ErrorInterceptor(
      onUnauthorized: () {
        ref.read(unauthenticatedEventProvider.notifier).trigger();
      },
      onPasswordChangeRequired: () {
        ref.read(passwordChangeRequiredProvider.notifier).set(true);
      },
    ),
  ]);

  return dio;
});
