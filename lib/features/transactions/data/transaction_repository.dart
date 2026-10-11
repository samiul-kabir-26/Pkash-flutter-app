import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/money/money.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/pagination.dart';
import '../domain/transaction.dart';

class PaginatedTransactions {
  final List<Transaction> transactions;
  final Pagination pagination;

  const PaginatedTransactions({
    required this.transactions,
    required this.pagination,
  });
}

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return TransactionRepository(dio);
});

class TransactionRepository {
  final Dio _dio;

  TransactionRepository(this._dio);

  Future<PaginatedTransactions> getHistory({
    int page = 1,
    int perPage = 20,
    String? type,
    String? status,
    String? fromDate,
    String? toDate,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (type != null && type.isNotEmpty && type != 'ALL') 'type': type,
      if (status != null && status.isNotEmpty) 'status': status,
      'from_date': ?fromDate,
      'to_date': ?toDate,
    };

    final response = await _dio.get(
      '/transactions/history',
      queryParameters: queryParams,
    );

    final data = response.data['data'] as Map<String, dynamic>;
    final txListJson = (data['transactions'] ?? data['items'] ?? []) as List;
    final transactions = txListJson
        .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination = Pagination.fromJson(data['pagination'] as Map<String, dynamic>);

    return PaginatedTransactions(
      transactions: transactions,
      pagination: pagination,
    );
  }

  Future<Transaction> getTransaction(int id) async {
    final response = await _dio.get('/transactions/$id');
    final data = response.data['data'] as Map<String, dynamic>;
    return Transaction.fromJson(data['transaction'] as Map<String, dynamic>);
  }

  Future<Transaction> topUp({
    required Decimal amount,
    required String idempotencyKey,
    String? description,
  }) async {
    final response = await _dio.post(
      '/transactions/top-up',
      data: {
        'amount': toApiAmount(amount),
        'idempotency_key': idempotencyKey,
        if (description != null && description.isNotEmpty) 'description': description,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return Transaction.fromJson(data['transaction'] as Map<String, dynamic>);
  }

  Future<Transaction> transfer({
    required int recipientId,
    required Decimal amount,
    required String idempotencyKey,
    String? description,
  }) async {
    final response = await _dio.post(
      '/transactions/transfer',
      data: {
        'recipient_id': recipientId,
        'amount': toApiAmount(amount),
        'idempotency_key': idempotencyKey,
        if (description != null && description.isNotEmpty) 'description': description,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return Transaction.fromJson(data['transaction'] as Map<String, dynamic>);
  }

  Future<Transaction> cashIn({
    required int agentId,
    required Decimal amount,
    required String idempotencyKey,
    String? description,
  }) async {
    final response = await _dio.post(
      '/transactions/cash-in',
      data: {
        'agent_id': agentId,
        'amount': toApiAmount(amount),
        'idempotency_key': idempotencyKey,
        if (description != null && description.isNotEmpty) 'description': description,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return Transaction.fromJson(data['transaction'] as Map<String, dynamic>);
  }

  Future<Transaction> cashOut({
    required int agentId,
    required Decimal amount,
    required String idempotencyKey,
    String? description,
  }) async {
    final response = await _dio.post(
      '/transactions/cash-out',
      data: {
        'agent_id': agentId,
        'amount': toApiAmount(amount),
        'idempotency_key': idempotencyKey,
        if (description != null && description.isNotEmpty) 'description': description,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return Transaction.fromJson(data['transaction'] as Map<String, dynamic>);
  }

  Future<Transaction> agentWithdrawal({
    required Decimal amount,
    required String idempotencyKey,
    String? description,
  }) async {
    final response = await _dio.post(
      '/transactions/agent/withdrawal',
      data: {
        'amount': toApiAmount(amount),
        'idempotency_key': idempotencyKey,
        if (description != null && description.isNotEmpty) 'description': description,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return Transaction.fromJson(data['transaction'] as Map<String, dynamic>);
  }
}
