import 'dart:convert';
import 'dart:io';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pkash/features/agent/domain/agent_info.dart';
import 'package:pkash/features/auth/domain/auth_user.dart';
import 'package:pkash/features/auth/domain/session.dart';
import 'package:pkash/features/transactions/domain/pagination.dart';
import 'package:pkash/features/transactions/domain/transaction.dart';
import 'package:pkash/features/wallet/domain/caps.dart';
import 'package:pkash/features/wallet/domain/wallet.dart';

/// Fixtures are real responses saved from the running API (G6), tokens redacted.
Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/fixtures/$name').readAsStringSync()) as Map<String, dynamic>;

void main() {
  group('Fixture Parsing Tests', () {
    test('parses auth_user_login fixture into Session', () {
      final session = Session.fromJson(fixture('auth_user_login.json')['data'] as Map<String, dynamic>);

      expect(session.user.id, 4);
      expect(session.user.phoneNumber, '01711112233');
      expect(session.panel, Panel.user);
      expect(session.abilities, contains('user'));
    });

    test('parses auth_agent_login fixture into Session with panel agent', () {
      final session = Session.fromJson(fixture('auth_agent_login.json')['data'] as Map<String, dynamic>);

      expect(session.user.id, 5);
      expect(session.panel, Panel.agent);
      expect(session.abilities, contains('agent'));
    });

    test('parses GET /auth/me (token null) into user + abilities', () {
      final data = fixture('auth_me_user.json')['data'] as Map<String, dynamic>;
      final user = AuthUser.fromJson(data['user'] as Map<String, dynamic>);

      expect(data['token'], isNull);
      expect(user.id, 4);
      expect(user.roles, ['USER']);
      expect(data['abilities'], ['user']);
    });

    test('parses wallet_me fixtures with kind (float balance)', () {
      final userWallet = Wallet.fromJson(fixture('wallet_me.json')['data']['wallet'] as Map<String, dynamic>);
      final agentWallet =
          Wallet.fromJson(fixture('wallet_me_agent.json')['data']['wallet'] as Map<String, dynamic>);

      expect(userWallet.kind, 'USER');
      expect(userWallet.balance, Decimal.parse('517.5'));
      expect(userWallet.isBlocked, isFalse);
      expect(userWallet.blockedBy, isNull);
      expect(agentWallet.kind, 'AGENT');
    });

    test('parses user_profile wallets[] (string balances) and caps', () {
      final user = fixture('user_profile.json')['data']['user'] as Map<String, dynamic>;

      final wallets =
          (user['wallets'] as List).map((e) => Wallet.fromJson(e as Map<String, dynamic>)).toList();
      final caps = Caps.fromJson(user['caps'] as Map<String, dynamic>);

      expect(wallets.single.kind, 'USER');
      expect(wallets.single.balance, Decimal.parse('517.50'));
      expect(caps.dailyCap, Decimal.parse('10000.00'));
      expect(caps.dailyUsed, Decimal.parse('50.00'));
      expect(caps.remainingDaily, Decimal.parse('9950.00'));
      expect(user['agent_info'], isNull);
    });

    test('parses agent_profile fixture agent_info', () {
      final user = fixture('agent_profile.json')['data']['user'] as Map<String, dynamic>;
      final agentInfo = AgentInfo.fromJson(user['agent_info'] as Map<String, dynamic>);

      expect(agentInfo.isApproved, isTrue);
      expect(agentInfo.commissionRate, Decimal.parse('0.0100'));
      expect(agentInfo.totalCommission, Decimal.parse('0.50'));
    });

    test('parses user history: data.transactions, only own *_balance_after present', () {
      final data = fixture('transaction_history.json')['data'] as Map<String, dynamic>;
      final txJson = data['transactions'] as List;
      final transactions = txJson.map((e) => Transaction.fromJson(e as Map<String, dynamic>)).toList();
      final pagination = Pagination.fromJson(data['pagination'] as Map<String, dynamic>);

      final cashOut = transactions.first;
      expect(cashOut.type, 'CASH_OUT');
      expect(cashOut.amount, Decimal.fromInt(50));
      expect(cashOut.systemFeeAmount, Decimal.parse('2.5'));
      // Other sides' keys are absent, not null.
      expect((txJson.first as Map).containsKey('agent_wallet_balance_after'), isFalse);
      expect((txJson.first as Map).containsKey('sender_wallet_id'), isFalse);
      expect(cashOut.agentWalletBalanceAfter, isNull);
      expect(cashOut.myBalanceAfter, Decimal.parse('517.5'));

      expect(transactions.last.type, 'TOP_UP');
      expect(transactions.last.myBalanceAfter, Decimal.fromInt(550));
      expect(pagination.total, 3);
      expect(pagination.currentPage, 1);
    });

    test('parses agent history: commission row links to its cash-out via meta', () {
      final data = fixture('transaction_history_agent.json')['data'] as Map<String, dynamic>;
      final transactions = (data['transactions'] as List)
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList();

      final commission = transactions.firstWhere((t) => t.type == 'COMMISSION_PAYOUT');
      final cashOut = transactions.firstWhere((t) => t.type == 'CASH_OUT');

      expect(commission.relatedTransactionId, cashOut.id);
      expect(cashOut.relatedTransactionId, isNull);
      expect(cashOut.myBalanceAfter, Decimal.parse('80.5'));
      expect(transactions.map((t) => t.type), isNot(contains('TOP_UP')));
    });
  });
}
