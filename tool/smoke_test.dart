// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:pkash/features/auth/domain/session.dart';
import 'package:pkash/features/wallet/domain/caps.dart';
import 'package:pkash/features/transactions/domain/transaction.dart';
import 'package:pkash/features/wallet/domain/wallet.dart';

void main() async {
  print('=== STARTING LIVE BACKEND SMOKE TEST ===');
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost/api/v1',
    headers: {'Accept': 'application/json'},
  ));

  // 1. User Login
  print('1. Testing User Login (01711112233)...');
  final userLoginRes = await dio.post(
    '/auth/user/login',
    data: {'phone_number': '01711112233', 'pin': '12345'},
  );
  assert(userLoginRes.statusCode == 200);
  final userSession = Session.fromJson(userLoginRes.data['data'] as Map<String, dynamic>);
  print('   ✓ User logged in: ${userSession.user.name} (ID: ${userSession.user.id})');
  print('   ✓ Token abilities: ${userSession.abilities}');

  // 1b. Session check (§6.3)
  print('1b. Testing Session Check (/auth/me)...');
  final meRes = await dio.get(
    '/auth/me',
    options: Options(headers: {'Authorization': 'Bearer ${userSession.token}'}),
  );
  assert(meRes.statusCode == 200 && meRes.data['data']['token'] == null);
  print('   ✓ /auth/me abilities: ${meRes.data['data']['abilities']}');

  // 2. Fetch Wallet with Token
  print('2. Testing Wallet Fetch (/wallets/me)...');
  final walletRes = await dio.get(
    '/wallets/me',
    options: Options(headers: {'Authorization': 'Bearer ${userSession.token}'}),
  );
  assert(walletRes.statusCode == 200);
  final wallet = Wallet.fromJson(walletRes.data['data']['wallet'] as Map<String, dynamic>);
  assert(wallet.kind == 'USER');
  print('   ✓ Wallet fetched: ${wallet.kind} ${wallet.balance} ${wallet.currency}, blocked: ${wallet.isBlocked}');

  // 3. Fetch User Profile + Caps
  print('3. Testing User Profile (/users/${userSession.user.id})...');
  final profileRes = await dio.get(
    '/users/${userSession.user.id}',
    options: Options(headers: {'Authorization': 'Bearer ${userSession.token}'}),
  );
  assert(profileRes.statusCode == 200);
  final capsJson = profileRes.data['data']['user']['caps'] as Map<String, dynamic>;
  final caps = Caps.fromJson(capsJson);
  print('   ✓ Caps fetched: Daily Limit=${caps.dailyCap}, Used=${caps.dailyUsed}');

  // 4. Fetch Transactions History
  print('4. Testing Transactions History (/transactions/history)...');
  final historyRes = await dio.get(
    '/transactions/history',
    queryParameters: {'per_page': 5},
    options: Options(headers: {'Authorization': 'Bearer ${userSession.token}'}),
  );
  assert(historyRes.statusCode == 200);
  final txList = (historyRes.data['data']['transactions'] as List)
      .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
      .toList();
  print('   ✓ Transactions fetched: ${txList.length} transactions');
  for (final tx in txList) {
    print('     • [${tx.type}] ${tx.amount} ${tx.currency} - ${tx.status}');
  }

  // 5. Agent Login
  print('5. Testing Agent Login (01722223344)...');
  final agentLoginRes = await dio.post(
    '/auth/agent/login',
    data: {'phone_number': '01722223344', 'pin': '54321'},
  );
  assert(agentLoginRes.statusCode == 200);
  final agentSession = Session.fromJson(agentLoginRes.data['data'] as Map<String, dynamic>);
  print('   ✓ Agent logged in: ${agentSession.user.name} (ID: ${agentSession.user.id})');
  print('   ✓ Abilities: ${agentSession.abilities}');

  // 6. Fetch Agent Profile
  print('6. Testing Agent Profile (/users/${agentSession.user.id})...');
  final agentProfRes = await dio.get(
    '/users/${agentSession.user.id}',
    options: Options(headers: {'Authorization': 'Bearer ${agentSession.token}'}),
  );
  assert(agentProfRes.statusCode == 200);
  final agentData = agentProfRes.data['data']['user'];
  print('   ✓ Agent status: ${agentData['agent_info']['status']}, commission: ${agentData['agent_info']['total_commission']}');

  // 7. Agent token sees the AGENT wallet (one wallet per role)
  print('7. Testing Agent Wallet (/wallets/me with agent token)...');
  final agentWalletRes = await dio.get(
    '/wallets/me',
    options: Options(headers: {'Authorization': 'Bearer ${agentSession.token}'}),
  );
  final agentWallet = Wallet.fromJson(agentWalletRes.data['data']['wallet'] as Map<String, dynamic>);
  assert(agentWallet.kind == 'AGENT');
  print('   ✓ Agent wallet: ${agentWallet.kind} ${agentWallet.balance}');

  for (final token in [userSession.token, agentSession.token]) {
    await dio.post('/auth/logout', options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  print('=== ALL LIVE BACKEND CHECKS PASSED SUCCESSFULLY ===');
}
