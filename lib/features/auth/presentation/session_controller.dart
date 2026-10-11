import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/storage/secure_token_storage.dart';
import '../data/auth_repository.dart';
import '../domain/auth_user.dart';
import '../domain/session.dart';

final sessionControllerProvider =
    AsyncNotifierProvider<SessionController, Session?>(SessionController.new);

class SessionController extends AsyncNotifier<Session?> {
  late final SecureTokenStorage _tokenStorage;
  late final AuthRepository _authRepository;

  @override
  FutureOr<Session?> build() async {
    _tokenStorage = ref.watch(secureTokenStorageProvider);
    _authRepository = ref.watch(authRepositoryProvider);

    // Listen to 401 unauthenticated events from Dio ErrorInterceptor
    ref.listen<int>(unauthenticatedEventProvider, (prev, next) {
      if (next > 0) {
        logout();
      }
    });

    final stored = await _tokenStorage.readSession();
    if (stored == null) {
      return null;
    }

    try {
      // Rotate token on cold start as per Decision D8
      final refreshed = await _authRepository.refreshToken();
      final newToken = refreshed['token'] as String;
      final abilitiesList = (refreshed['abilities'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          stored.abilities;

      await _tokenStorage.updateToken(newToken, abilitiesList);

      // Return a basic session from stored credentials
      return Session(
        token: newToken,
        abilities: abilitiesList,
        user: _createPlaceholderUser(stored.userId, stored.panel),
      );
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        // Token is invalid/revoked on backend
        await _tokenStorage.clear();
        return null;
      }
      // On network error, keep stored session
      return Session(
        token: stored.token,
        abilities: stored.abilities,
        user: _createPlaceholderUser(stored.userId, stored.panel),
      );
    } catch (_) {
      return Session(
        token: stored.token,
        abilities: stored.abilities,
        user: _createPlaceholderUser(stored.userId, stored.panel),
      );
    }
  }

  static AuthUser _createPlaceholderUser(int id, String panel) {
    return AuthUser(
      id: id,
      name: panel == 'agent' ? 'Agent' : 'Customer',
      phoneNumber: '',
      roles: panel == 'agent' ? const ['AGENT'] : const ['USER'],
    );
  }

  Future<Session> loginCustomer({
    required String phoneNumber,
    required String pin,
  }) async {
    state = const AsyncLoading();
    try {
      final session = await _authRepository.loginUser(
        phoneNumber: phoneNumber,
        pin: pin,
      );

      await _tokenStorage.saveSession(
        token: session.token,
        panel: 'user',
        abilities: session.abilities,
        userId: session.user.id,
      );

      state = AsyncData(session);
      return session;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<Session> loginAgent({
    required String phoneNumber,
    required String pin,
  }) async {
    state = const AsyncLoading();
    try {
      final session = await _authRepository.loginAgent(
        phoneNumber: phoneNumber,
        pin: pin,
      );

      await _tokenStorage.saveSession(
        token: session.token,
        panel: 'agent',
        abilities: session.abilities,
        userId: session.user.id,
      );

      state = AsyncData(session);
      return session;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<Session> register({
    required String name,
    required String phoneNumber,
    required String pin,
    required String pinConfirmation,
    required String role,
  }) async {
    state = const AsyncLoading();
    try {
      final session = await _authRepository.register(
        name: name,
        phoneNumber: phoneNumber,
        pin: pin,
        pinConfirmation: pinConfirmation,
        role: role,
      );

      if (role == 'USER') {
        await _tokenStorage.saveSession(
          token: session.token,
          panel: 'user',
          abilities: session.abilities,
          userId: session.user.id,
        );
        state = AsyncData(session);
      } else {
        // AGENT: do not store as active session (G5 - agent needs approval)
        state = const AsyncData(null);
      }

      return session;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    await _tokenStorage.clear();
    state = const AsyncData(null);
  }
}
