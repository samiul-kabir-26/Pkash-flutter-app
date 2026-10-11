import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/session_controller.dart';
import '../data/wallet_repository.dart';
import '../domain/caps.dart';
import '../domain/wallet.dart';

final walletProvider = FutureProvider.autoDispose<Wallet>((ref) async {
  final repo = ref.watch(walletRepositoryProvider);
  return repo.getMyWallet();
});

final capsProvider = FutureProvider.autoDispose<Caps?>((ref) async {
  final session = ref.watch(sessionControllerProvider).value;
  if (session == null) return null;
  final repo = ref.watch(walletRepositoryProvider);
  return repo.getMyCaps(session.user.id);
});
