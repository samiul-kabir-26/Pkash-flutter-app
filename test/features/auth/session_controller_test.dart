import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pkash/core/network/api_exception.dart';
import 'package:pkash/core/network/dio_provider.dart';
import 'package:pkash/core/storage/secure_token_storage.dart';
import 'package:pkash/features/auth/data/auth_repository.dart';
import 'package:pkash/features/auth/domain/auth_user.dart';
import 'package:pkash/features/auth/domain/session.dart';
import 'package:pkash/features/auth/presentation/session_controller.dart';

class InMemoryStorage extends SecureTokenStorage {
  StoredSessionData? stored;
  int clears = 0;

  @override
  Future<StoredSessionData?> readSession() async => stored;

  @override
  Future<String?> readToken() async => stored?.token;

  @override
  Future<void> saveSession({
    required String token,
    required String panel,
    required List<String> abilities,
    required int userId,
    required String phoneNumber,
  }) async {
    stored = StoredSessionData(
      token: token,
      panel: panel,
      abilities: abilities,
      userId: userId,
      phoneNumber: phoneNumber,
    );
  }

  @override
  Future<void> updateToken(String token, List<String> abilities) async {}

  @override
  Future<void> clear() async {
    clears++;
    stored = null;
  }
}

const dualRoleUser = AuthUser(
  id: 9,
  name: 'Dual',
  phoneNumber: '01799998888',
  roles: ['USER', 'AGENT'],
);

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository() : super(Dio());

  Object? meError;
  final revokedTokens = <String?>[];

  Session _session(List<String> abilities) =>
      Session(token: 'tok-${abilities.first}', abilities: abilities, user: dualRoleUser);

  @override
  Future<Session> loginUser({required String phoneNumber, required String pin}) async =>
      _session(['user']);

  @override
  Future<Session> loginAgent({required String phoneNumber, required String pin}) async =>
      _session(['agent']);

  @override
  Future<Session> register({
    required String name,
    required String phoneNumber,
    required String pin,
    required String pinConfirmation,
    required String role,
  }) async =>
      _session([role == 'AGENT' ? 'agent' : 'user']);

  @override
  Future<MeResult> me() async {
    if (meError != null) throw meError!;
    return const MeResult(user: dualRoleUser, abilities: ['user']);
  }

  @override
  Future<({String token, List<String> abilities})> refreshToken() async =>
      (token: 'rotated', abilities: const ['user']);

  @override
  Future<void> logout({String? token}) async => revokedTokens.add(token);
}

void main() {
  late InMemoryStorage storage;
  late FakeAuthRepository repo;
  late ProviderContainer container;

  setUp(() {
    storage = InMemoryStorage();
    repo = FakeAuthRepository();
  });

  // Built lazily so a test can seed storage before the controller reads it.
  ProviderContainer start() {
    container = ProviderContainer(
      overrides: [
        secureTokenStorageProvider.overrideWithValue(storage),
        authRepositoryProvider.overrideWithValue(repo),
      ],
    );
    container.listen(sessionControllerProvider, (_, _) {});
    container.listen(sessionScopeProvider, (_, _) {});
    addTearDown(container.dispose);
    return container;
  }

  SessionController controller() => container.read(sessionControllerProvider.notifier);

  test('login persists the session, phone included, and sets the scope', () async {
    await start().read(sessionControllerProvider.future);
    await controller().loginCustomer(phoneNumber: '01799998888', pin: '12345');

    expect(storage.stored?.token, 'tok-user');
    expect(storage.stored?.phoneNumber, '01799998888');
    expect(container.read(sessionScopeProvider), (userId: 9, panel: Panel.user));
  });

  test('cold start: /auth/me 401 clears storage and yields no session', () async {
    storage.stored = const StoredSessionData(
      token: 'dead',
      panel: 'user',
      abilities: ['user'],
      userId: 9,
    );
    repo.meError = const ApiException(statusCode: 401, message: 'Unauthenticated.');

    expect(await start().read(sessionControllerProvider.future), isNull);
    expect(storage.stored, isNull);
  });

  test('cold start offline keeps the stored session', () async {
    storage.stored = const StoredSessionData(
      token: 'tok',
      panel: 'agent',
      abilities: ['agent'],
      userId: 9,
      phoneNumber: '01799998888',
    );
    repo.meError = const NetworkException();

    final session = await start().read(sessionControllerProvider.future);
    expect(session?.panel, Panel.agent);
    expect(session?.user.phoneNumber, '01799998888');
  });

  test('AGENT registration never yields an agent session and revokes the token (D16)', () async {
    await start().read(sessionControllerProvider.future);
    await controller().register(
      name: 'New Agent',
      phoneNumber: '01799998888',
      pin: '12345',
      pinConfirmation: '12345',
      role: 'AGENT',
    );

    expect(container.read(sessionControllerProvider).value, isNull);
    expect(storage.stored, isNull);
    expect(repo.revokedTokens, ['tok-agent']);
    expect(container.read(loginPrefillProvider)?.panel, Panel.agent);
  });

  test('logout clears storage and the session scope (user-scoped providers reset)', () async {
    await start().read(sessionControllerProvider.future);
    await controller().loginAgent(phoneNumber: '01799998888', pin: '12345');
    expect(container.read(sessionScopeProvider)?.panel, Panel.agent);

    await controller().logout();

    expect(storage.stored, isNull);
    expect(container.read(sessionScopeProvider), isNull);
  });

  test('switchPanel logs out and preselects the other panel with the phone prefilled', () async {
    await start().read(sessionControllerProvider.future);
    await controller().loginCustomer(phoneNumber: '01799998888', pin: '12345');

    await controller().switchPanel();

    expect(container.read(sessionControllerProvider).value, isNull);
    final prefill = container.read(loginPrefillProvider);
    expect(prefill?.panel, Panel.agent);
    expect(prefill?.phoneNumber, '01799998888');
  });
}
