import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/session_controller.dart';
import 'l10n/app_localizations.dart';

class PkashApp extends ConsumerStatefulWidget {
  const PkashApp({super.key});

  @override
  ConsumerState<PkashApp> createState() => _PkashAppState();
}

class _PkashAppState extends ConsumerState<PkashApp> {
  static const _revalidateAfter = Duration(minutes: 5);

  late final AppLifecycleListener _lifecycle;
  DateTime? _pausedAt;

  @override
  void initState() {
    super.initState();
    // §9.2: after ≥5 minutes in the background, check the session with GET /auth/me.
    _lifecycle = AppLifecycleListener(
      onHide: () => _pausedAt = DateTime.now(),
      onShow: () {
        final pausedAt = _pausedAt;
        _pausedAt = null;
        if (pausedAt != null && DateTime.now().difference(pausedAt) >= _revalidateAfter) {
          ref.read(sessionControllerProvider.notifier).revalidate();
        }
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Pkash',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE2136E), // Pkash vibrant brand color
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2136E), width: 1.8),
          ),
        ),
      ),
    );
  }
}
