import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/caps.dart';
import '../domain/wallet.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return WalletRepository(dio);
});

class WalletRepository {
  final Dio _dio;

  WalletRepository(this._dio);

  Future<Wallet> getMyWallet() async {
    final response = await _dio.get('/wallets/me');
    final data = response.data['data'] as Map<String, dynamic>;
    return Wallet.fromJson(data['wallet'] as Map<String, dynamic>);
  }

  Future<Caps?> getMyCaps(int userId) async {
    final response = await _dio.get('/users/$userId');
    final data = response.data['data'] as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;
    if (user['caps'] != null) {
      return Caps.fromJson(user['caps'] as Map<String, dynamic>);
    }
    return null;
  }
}
