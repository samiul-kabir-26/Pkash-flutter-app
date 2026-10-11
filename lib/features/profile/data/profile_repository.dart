import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../../agent/domain/agent_info.dart';
import '../../auth/domain/auth_user.dart';
import '../../wallet/domain/caps.dart';
import '../../wallet/domain/wallet.dart';

class FullUserProfile {
  final AuthUser user;
  final Wallet? wallet;
  final Caps? caps;
  final AgentInfo? agentInfo;

  const FullUserProfile({
    required this.user,
    this.wallet,
    this.caps,
    this.agentInfo,
  });
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ProfileRepository(dio);
});

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Future<FullUserProfile> getProfile(int userId) async {
    final response = await _dio.get('/users/$userId');
    final data = response.data['data']['user'] as Map<String, dynamic>;

    final user = AuthUser.fromJson(data);
    Wallet? wallet;
    if (data['wallet'] != null) {
      wallet = Wallet.fromJson(data['wallet'] as Map<String, dynamic>);
    }
    Caps? caps;
    if (data['caps'] != null) {
      caps = Caps.fromJson(data['caps'] as Map<String, dynamic>);
    }
    AgentInfo? agentInfo;
    if (data['agent_info'] != null) {
      agentInfo = AgentInfo.fromJson(data['agent_info'] as Map<String, dynamic>);
    }

    return FullUserProfile(
      user: user,
      wallet: wallet,
      caps: caps,
      agentInfo: agentInfo,
    );
  }

  Future<AuthUser> updateProfile(int userId, {String? name, String? address}) async {
    final response = await _dio.patch(
      '/users/$userId',
      data: {
        'name': ?name,
        'address': ?address,
      },
    );
    final data = response.data['data']['user'] as Map<String, dynamic>;
    return AuthUser.fromJson(data);
  }
}
