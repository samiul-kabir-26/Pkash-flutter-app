import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pkash/app.dart';
import 'package:pkash/core/network/dio_provider.dart';
import 'package:pkash/core/storage/secure_token_storage.dart';

class FakeSecureTokenStorage extends SecureTokenStorage {
  @override
  Future<StoredSessionData?> readSession() async => null;

  @override
  Future<String?> readToken() async => null;

  @override
  Future<bool> isAppLockEnabled() async => false;
}

void main() {
  testWidgets('App loads LoginScreen and displays Customer and Agent portals',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureTokenStorageProvider.overrideWithValue(FakeSecureTokenStorage()),
        ],
        child: const PkashApp(),
      ),
    );

    // Pump past splash screen
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Pkash'), findsOneWidget);
    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Agent'), findsOneWidget);
    expect(find.byType(TextFormField), findsWidgets);
    expect(find.text('Log In as Customer'), findsOneWidget);

    // Tap on Agent toggle
    await tester.tap(find.text('Agent'));
    await tester.pumpAndSettle();

    expect(find.text('Log In as Agent'), findsOneWidget);
  });
}
