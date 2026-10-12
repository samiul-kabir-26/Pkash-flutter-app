import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/session_controller.dart';
import '../data/wallet_repository.dart';
import '../domain/caps.dart';
import '../domain/wallet.dart';

/// The wallet of the current panel (USER or AGENT), chosen server-side by the token.
final walletProvider = FutureProvider.autoDispose<Wallet>((ref) async {
  final scope = ref.watch(sessionScopeProvider);
  if (scope == null) throw StateError('Not authenticated');
  final repo = ref.watch(walletRepositoryProvider);
  return repo.getMyWallet();
});

final capsProvider = FutureProvider.autoDispose<Caps?>((ref) async {
  final scope = ref.watch(sessionScopeProvider);
  if (scope == null) return null;
  final repo = ref.watch(walletRepositoryProvider);
  return repo.getMyCaps(scope.userId);
});
