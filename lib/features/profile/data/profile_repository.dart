import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_provider.dart';
import '../../agent/domain/agent_info.dart';
import '../../auth/domain/auth_user.dart';
import '../../auth/domain/panel.dart';
import '../../wallet/domain/caps.dart';
import '../../wallet/domain/wallet.dart';

/// `GET /users/{self}`. It returns **both** wallets and `agent_info` whatever the token;
/// screens pick what belongs to the current panel (§7.9).
class FullUserProfile {
  final AuthUser user;
  final List<Wallet> wallets;
  final Caps? caps;
  final AgentInfo? agentInfo;

  const FullUserProfile({
    required this.user,
    this.wallets = const [],
    this.caps,
    this.agentInfo,
  });

  Wallet? walletFor(Panel panel) {
    for (final wallet in wallets) {
      if (wallet.kind == panel.role) return wallet;
    }
    return null;
  }

  bool hasRole(String role) => user.roles.contains(role);
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ProfileRepository(dio);
});

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Future<FullUserProfile> getProfile(int userId) => apiCall(() async {
        final response = await _dio.get('/users/$userId');
        final data = response.data['data']['user'] as Map<String, dynamic>;

        final wallets = (data['wallets'] as List? ?? const [])
            .map((e) => Wallet.fromJson(e as Map<String, dynamic>))
            .toList();
        Caps? caps;
        if (data['caps'] != null) {
          caps = Caps.fromJson(data['caps'] as Map<String, dynamic>);
        }
        AgentInfo? agentInfo;
        if (data['agent_info'] != null) {
          agentInfo = AgentInfo.fromJson(data['agent_info'] as Map<String, dynamic>);
        }

        return FullUserProfile(
          user: AuthUser.fromJson(data),
          wallets: wallets,
          caps: caps,
          agentInfo: agentInfo,
        );
      });

  /// Only name and address are editable; email, phone, password and role are prohibited (422).
  Future<AuthUser> updateProfile(int userId, {String? name, String? address}) => apiCall(() async {
        final response = await _dio.patch(
          '/users/$userId',
          data: {
            'name': ?name,
            'address': ?address,
          },
        );
        final data = response.data['data']['user'] as Map<String, dynamic>;
        return AuthUser.fromJson(data);
      });
}
