import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/agent/presentation/agent_home_screen.dart';
import '../../features/agent/presentation/agent_withdrawal_screen.dart';
import '../../features/auth/presentation/agent_pending_screen.dart';
import '../../features/auth/presentation/forgot_pin_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/session_controller.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/qr/presentation/my_qr_screen.dart';
import '../../features/qr/presentation/qr_scanner_screen.dart';
import '../../features/transactions/presentation/history_screen.dart';
import '../../features/transactions/presentation/transaction_detail_screen.dart';
import '../../features/transfer/presentation/cash_in_screen.dart';
import '../../features/transfer/presentation/cash_out_screen.dart';
import '../../features/transfer/presentation/send_money_screen.dart';
import '../../features/transfer/presentation/top_up_screen.dart';
import '../../features/wallet/presentation/user_home_screen.dart';

class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Ref ref) {
    ref.listen(sessionControllerProvider, (_, _) {
      notifyListeners();
    });
  }
}

final routerRefreshNotifierProvider = Provider<RouterRefreshNotifier>((ref) {
  return RouterRefreshNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(routerRefreshNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final sessionState = ref.read(sessionControllerProvider);
      final location = state.uri.path;

      // 1. Session is still initializing from secure storage
      if (sessionState.isLoading) {
        return location == '/splash' ? null : '/splash';
      }

      final session = sessionState.value;

      final publicRoutes = [
        '/login',
        '/register',
        '/agent-pending',
        '/forgot-pin',
      ];
      final isPublic = publicRoutes.contains(location);

      // 2. Not authenticated
      if (session == null) {
        return isPublic ? null : '/login';
      }

      // 3. Authenticated: redirect away from auth / splash screens
      final isAgent = session.panel == 'agent';

      if (location == '/splash' || location == '/login' || location == '/register') {
        return isAgent ? '/agent/home' : '/user/home';
      }

      // 4. Panel boundary guard (enforce token ability §5.7)
      if (!isAgent && location.startsWith('/agent')) {
        return '/user/home';
      }
      if (isAgent && location.startsWith('/user')) {
        return '/agent/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/agent-pending',
        builder: (context, state) => const AgentPendingScreen(),
      ),
      GoRoute(
        path: '/forgot-pin',
        builder: (context, state) => const ForgotPinScreen(),
      ),
      GoRoute(
        path: '/my-qr',
        builder: (context, state) => const MyQrScreen(),
      ),
      GoRoute(
        path: '/scan-qr',
        builder: (context, state) {
          final type = state.uri.queryParameters['type'] ?? 'user';
          return QrScannerScreen(expectedType: type);
        },
      ),

      // Customer Shell Routes with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) {
          return UserScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/user/home',
            builder: (context, state) => const UserHomeScreen(),
          ),
          GoRoute(
            path: '/user/send',
            builder: (context, state) => const SendMoneyScreen(),
          ),
          GoRoute(
            path: '/user/history',
            builder: (context, state) => const HistoryScreen(isAgent: false),
          ),
          GoRoute(
            path: '/user/profile',
            builder: (context, state) => const ProfileScreen(isAgent: false),
          ),
        ],
      ),

      // Customer subroutes
      GoRoute(
        path: '/user/cash-in',
        builder: (context, state) => const CashInScreen(),
      ),
      GoRoute(
        path: '/user/cash-out',
        builder: (context, state) => const CashOutScreen(),
      ),
      GoRoute(
        path: '/user/top-up',
        builder: (context, state) => const TopUpScreen(),
      ),
      GoRoute(
        path: '/user/history/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return TransactionDetailScreen(transactionId: id);
        },
      ),

      // Agent Shell Routes with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) {
          return AgentScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/agent/home',
            builder: (context, state) => const AgentHomeScreen(),
          ),
          GoRoute(
            path: '/agent/withdraw',
            builder: (context, state) => const AgentWithdrawalScreen(),
          ),
          GoRoute(
            path: '/agent/history',
            builder: (context, state) => const HistoryScreen(isAgent: true),
          ),
          GoRoute(
            path: '/agent/profile',
            builder: (context, state) => const ProfileScreen(isAgent: true),
          ),
        ],
      ),

      // Agent subroutes
      GoRoute(
        path: '/agent/history/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return TransactionDetailScreen(transactionId: id);
        },
      ),
    ],
  );
});

class UserScaffold extends StatelessWidget {
  final Widget child;

  const UserScaffold({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/user/home')) return 0;
    if (location.startsWith('/user/send')) return 1;
    if (location.startsWith('/user/history')) return 2;
    if (location.startsWith('/user/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/user/home');
        break;
      case 1:
        context.go('/user/send');
        break;
      case 2:
        context.go('/user/history');
        break;
      case 3:
        context.go('/user/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (idx) => _onItemTapped(idx, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.send_outlined),
            selectedIcon: Icon(Icons.send),
            label: 'Send',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class AgentScaffold extends StatelessWidget {
  final Widget child;

  const AgentScaffold({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/agent/home')) return 0;
    if (location.startsWith('/agent/withdraw')) return 1;
    if (location.startsWith('/agent/history')) return 2;
    if (location.startsWith('/agent/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/agent/home');
        break;
      case 1:
        context.go('/agent/withdraw');
        break;
      case 2:
        context.go('/agent/history');
        break;
      case 3:
        context.go('/agent/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (idx) => _onItemTapped(idx, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Agent Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance),
            label: 'Withdraw',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
