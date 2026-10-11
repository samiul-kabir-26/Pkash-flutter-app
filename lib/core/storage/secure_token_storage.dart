import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoredSessionData {
  final String token;
  final String panel; // 'user' or 'agent'
  final List<String> abilities;
  final int userId;

  const StoredSessionData({
    required this.token,
    required this.panel,
    required this.abilities,
    required this.userId,
  });
}

class SecureTokenStorage {
  final FlutterSecureStorage _storage;

  static const String _keyToken = 'auth_token';
  static const String _keyPanel = 'auth_panel';
  static const String _keyAbilities = 'auth_abilities';
  static const String _keyUserId = 'auth_user_id';
  static const String _keyAppLock = 'app_lock_enabled';

  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<String?> readToken() async {
    return await _storage.read(key: _keyToken);
  }

  Future<String?> readPanel() async {
    return await _storage.read(key: _keyPanel);
  }

  Future<StoredSessionData?> readSession() async {
    final token = await _storage.read(key: _keyToken);
    final panel = await _storage.read(key: _keyPanel);
    final abilitiesJson = await _storage.read(key: _keyAbilities);
    final userIdStr = await _storage.read(key: _keyUserId);

    if (token == null || panel == null || userIdStr == null) {
      return null;
    }

    final userId = int.tryParse(userIdStr);
    if (userId == null) return null;

    List<String> abilities = [];
    if (abilitiesJson != null) {
      try {
        final decoded = jsonDecode(abilitiesJson);
        if (decoded is List) {
          abilities = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }

    return StoredSessionData(
      token: token,
      panel: panel,
      abilities: abilities,
      userId: userId,
    );
  }

  Future<void> saveSession({
    required String token,
    required String panel,
    required List<String> abilities,
    required int userId,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyPanel, value: panel);
    await _storage.write(key: _keyAbilities, value: jsonEncode(abilities));
    await _storage.write(key: _keyUserId, value: userId.toString());
  }

  Future<void> updateToken(String token, List<String> abilities) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyAbilities, value: jsonEncode(abilities));
  }

  Future<void> clear() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyPanel);
    await _storage.delete(key: _keyAbilities);
    await _storage.delete(key: _keyUserId);
  }

  Future<bool> isAppLockEnabled() async {
    final value = await _storage.read(key: _keyAppLock);
    return value == 'true';
  }

  Future<void> setAppLockEnabled(bool enabled) async {
    await _storage.write(key: _keyAppLock, value: enabled ? 'true' : 'false');
  }
}
