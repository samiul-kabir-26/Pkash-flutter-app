import 'dart:convert';
import 'dart:io';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pkash/features/agent/domain/agent_info.dart';
import 'package:pkash/features/auth/domain/session.dart';
import 'package:pkash/features/transactions/domain/pagination.dart';
import 'package:pkash/features/transactions/domain/transaction.dart';
import 'package:pkash/features/wallet/domain/caps.dart';
import 'package:pkash/features/wallet/domain/wallet.dart';

void main() {
  group('Fixture Parsing Tests', () {
    test('parses auth_user_login fixture into Session', () {
      final file = File('test/fixtures/auth_user_login.json');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final session = Session.fromJson(json['data'] as Map<String, dynamic>);

      expect(session.user.id, 4);
      expect(session.user.phoneNumber, '01711112233');
      expect(session.panel, 'user');
      expect(session.abilities, contains('user'));
    });

    test('parses auth_agent_login fixture into Session with panel agent', () {
      final file = File('test/fixtures/auth_agent_login.json');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final session = Session.fromJson(json['data'] as Map<String, dynamic>);

      expect(session.user.id, 5);
      expect(session.panel, 'agent');
      expect(session.abilities, contains('agent'));
    });

    test('parses wallet_me fixture into Wallet', () {
      final file = File('test/fixtures/wallet_me.json');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final wallet = Wallet.fromJson(json['data']['wallet'] as Map<String, dynamic>);

      expect(wallet.id, 1);
      expect(wallet.userId, 4);
      expect(wallet.balance, Decimal.parse('550'));
      expect(wallet.isBlocked, isFalse);
    });

    test('parses user_profile fixture caps and wallet', () {
      final file = File('test/fixtures/user_profile.json');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final user = json['data']['user'] as Map<String, dynamic>;

      final wallet = Wallet.fromJson(user['wallet'] as Map<String, dynamic>);
      final caps = Caps.fromJson(user['caps'] as Map<String, dynamic>);

      expect(wallet.balance, Decimal.parse('550.00'));
      expect(caps.dailyCap, Decimal.parse('10000.00'));
      expect(caps.dailyUsed, Decimal.parse('500.00'));
      expect(caps.remainingDaily, Decimal.parse('9500.00'));
    });

    test('parses agent_profile fixture agent_info', () {
      final file = File('test/fixtures/agent_profile.json');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final user = json['data']['user'] as Map<String, dynamic>;

      final agentInfo = AgentInfo.fromJson(user['agent_info'] as Map<String, dynamic>);

      expect(agentInfo.isApproved, isTrue);
      expect(agentInfo.commissionRate, Decimal.parse('0.0100'));
      expect(agentInfo.totalCommission, Decimal.parse('0.50'));
    });

    test('parses transaction_history fixture into Transaction list and Pagination', () {
      final file = File('test/fixtures/transaction_history.json');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;

      final txListJson = (data['transactions'] ?? data['items']) as List;
      final transactions = txListJson
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList();
      final pagination = Pagination.fromJson(data['pagination'] as Map<String, dynamic>);

      expect(transactions.length, 2);
      expect(transactions.first.type, 'CASH_OUT');
      expect(transactions.first.amount, Decimal.fromInt(50));
      expect(transactions.first.systemFeeAmount, Decimal.parse('2.5'));
      expect(transactions[1].type, 'TOP_UP');
      expect(pagination.total, 2);
      expect(pagination.currentPage, 1);
    });
  });
}
