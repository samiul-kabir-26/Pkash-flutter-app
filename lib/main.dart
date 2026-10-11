import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'app.dart';
import 'core/storage/secure_token_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // App lock check on cold start if enabled and session exists (§9.3)
  final tokenStorage = SecureTokenStorage();
  final isAppLock = await tokenStorage.isAppLockEnabled();
  final token = await tokenStorage.readToken();

  if (isAppLock && token != null) {
    final localAuth = LocalAuthentication();
    final canCheck = await localAuth.canCheckBiometrics || await localAuth.isDeviceSupported();
    if (canCheck) {
      try {
        final authenticated = await localAuth.authenticate(
          localizedReason: 'Authenticate to access Pkash',
          persistAcrossBackgrounding: true,
        );
        if (!authenticated) {
          return;
        }
      } catch (_) {}
    }
  }

  runApp(
    const ProviderScope(
      child: PkashApp(),
    ),
  );
}
