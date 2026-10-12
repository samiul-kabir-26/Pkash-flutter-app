import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/storage/secure_token_storage.dart';
import '../data/auth_repository.dart';
import '../domain/auth_user.dart';
import '../domain/session.dart';

export '../domain/panel.dart';

final sessionControllerProvider =
    AsyncNotifierProvider<SessionController, Session?>(SessionController.new);

/// Who is signed in, on which panel. Every user-scoped provider (wallet, caps, history,
/// profile) watches this, so logout, login as someone else, or a panel switch drops their
/// cached data and the other wallet never flashes (§6.3).
final sessionScopeProvider = Provider<({int userId, Panel panel})?>((ref) {
  final session = ref.watch(sessionControllerProvider.select((s) => s.value));
  if (session == null) return null;
  return (userId: session.user.id, panel: session.panel);
});

/// What the login screen should preselect after a panel switch or an agent-pending redirect.
class LoginPrefill {
  final Panel panel;
  final String phoneNumber;

  const LoginPrefill({required this.panel, this.phoneNumber = ''});
}

class LoginPrefillNotifier extends Notifier<LoginPrefill?> {
  @override
  LoginPrefill? build() => null;

  void set(LoginPrefill? value) => state = value;
}

final loginPrefillProvider =
    NotifierProvider<LoginPrefillNotifier, LoginPrefill?>(LoginPrefillNotifier.new);

class SessionController extends AsyncNotifier<Session?> {
  late SecureTokenStorage _tokenStorage;
  late AuthRepository _authRepository;

  /// D8: rotate the token at most once per app launch.
  static bool _rotatedThisLaunch = false;

  @override
  FutureOr<Session?> build() async {
    _tokenStorage = ref.watch(secureTokenStorageProvider);
    _authRepository = ref.watch(authRepositoryProvider);

    // Any 401 outside the credential routes means the session is over.
    ref.listen<int>(unauthenticatedEventProvider, (prev, next) {
      if (next > 0 && state.value != null) {
        _expireSession();
      }
    });

    final stored = await _tokenStorage.readSession();
    if (stored == null) {
      return null;
    }

    try {
      // GET /auth/me is the cheap "is my token alive and who am I" check (§6.3).
      final me = await _authRepository.me();
      final session = Session(
        token: stored.token,
        abilities: me.abilities.isNotEmpty ? me.abilities : stored.abilities,
        user: me.user,
      );
      await _persist(session);
      _rotateTokenOncePerLaunch();
      return session;
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await _tokenStorage.clear();
        return null;
      }
      // 403 "must change your password": the interceptor already raised the flag and the
      // router shows /account-action-needed. Offline / 5xx: keep the stored session.
      return _sessionFromStorage(stored);
    }
  }

  Session _sessionFromStorage(StoredSessionData stored) {
    final panel = Panel.fromAbilities(stored.abilities);
    return Session(
      token: stored.token,
      abilities: stored.abilities,
      user: AuthUser(
        id: stored.userId,
        name: panel == Panel.agent ? 'Agent' : 'Customer',
        phoneNumber: stored.phoneNumber,
        roles: [panel.role],
      ),
    );
  }

  Future<void> _persist(Session session) {
    return _tokenStorage.saveSession(
      token: session.token,
      panel: session.panel.name,
      abilities: session.abilities,
      userId: session.user.id,
      phoneNumber: session.user.phoneNumber,
    );
  }

  void _rotateTokenOncePerLaunch() {
    if (_rotatedThisLaunch) return;
    _rotatedThisLaunch = true;

    unawaited(() async {
      try {
        final rotated = await _authRepository.refreshToken();
        final current = state.value;
        if (current == null || !ref.mounted) return;
        await _tokenStorage.updateToken(rotated.token, rotated.abilities);
        state = AsyncData(current.copyWith(token: rotated.token, abilities: rotated.abilities));
      } on ApiException {
        // A 401 is handled by the interceptor. If the response was lost, the old token is
        // already deleted server-side and the next call logs the user out (accepted in D8).
      }
    }());
  }

  /// Login does not put the controller into a loading state: the router would swap the
  /// login screen for the splash and the error would have nowhere to show.
  Future<Session> loginCustomer({
    required String phoneNumber,
    required String pin,
  }) async {
    final session = await _authRepository.loginUser(phoneNumber: phoneNumber, pin: pin);
    await _startSession(session);
    return session;
  }

  Future<Session> loginAgent({
    required String phoneNumber,
    required String pin,
  }) async {
    final session = await _authRepository.loginAgent(phoneNumber: phoneNumber, pin: pin);
    await _startSession(session);
    return session;
  }

  Future<void> _startSession(Session session) async {
    await _persist(session);
    ref.read(passwordChangeRequiredProvider.notifier).set(false);
    ref.read(loginPrefillProvider.notifier).set(null);
    state = AsyncData(session);
  }

  /// USER registration starts a session. AGENT registration does not (D16, G5): the token
  /// the server returns while the agent is PENDING is revoked straight away.
  Future<Session> register({
    required String name,
    required String phoneNumber,
    required String pin,
    required String pinConfirmation,
    required String role,
  }) async {
    final session = await _authRepository.register(
      name: name,
      phoneNumber: phoneNumber,
      pin: pin,
      pinConfirmation: pinConfirmation,
      role: role,
    );

    if (role == 'USER') {
      await _startSession(session);
    } else {
      await _authRepository.logout(token: session.token);
      ref.read(loginPrefillProvider.notifier).set(
            LoginPrefill(panel: Panel.agent, phoneNumber: phoneNumber),
          );
    }
    return session;
  }

  /// §9.2: on resume after a while in the background, confirm the token is still alive.
  /// A 401 ends the session through the interceptor; offline keeps it.
  Future<void> revalidate() async {
    final current = state.value;
    if (current == null) return;
    try {
      final me = await _authRepository.me();
      if (!ref.mounted || state.value?.token != current.token) return;
      final session = current.copyWith(user: me.user);
      await _persist(session);
      state = AsyncData(session);
    } on ApiException {
      // 401 / 403 are handled by the interceptor callbacks.
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    await _endSession();
  }

  /// D1: one session at a time. Switching = log out, then log in on the other route with
  /// the phone prefilled.
  Future<void> switchPanel() async {
    final current = state.value;
    if (current == null) return;
    // Set before logging out: the router redirects to /login as soon as the session ends.
    ref.read(loginPrefillProvider.notifier).set(
          LoginPrefill(panel: current.panel.other, phoneNumber: current.user.phoneNumber),
        );
    await logout();
  }

  Future<void> _expireSession() => _endSession();

  Future<void> _endSession() async {
    await _tokenStorage.clear();
    ref.read(passwordChangeRequiredProvider.notifier).set(false);
    state = const AsyncData(null);
  }
}
