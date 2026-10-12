import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/money/money.dart';
import '../../../core/network/api_exception.dart';
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

  /// Wallet-scoped: returns rows touching the wallet that matches the token's ability.
  Future<PaginatedTransactions> getHistory({
    int page = 1,
    int perPage = 20,
    String? type,
    String? status,
    String? fromDate,
    String? toDate,
  }) => apiCall(() async {
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
        final transactions = (data['transactions'] as List)
            .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
            .toList();
        final pagination = Pagination.fromJson(data['pagination'] as Map<String, dynamic>);

        return PaginatedTransactions(
          transactions: transactions,
          pagination: pagination,
        );
      });

  Future<Transaction> getTransaction(int id) => apiCall(() async {
        final response = await _dio.get('/transactions/$id');
        return _transactionFrom(response);
      });

  Future<Transaction> topUp({
    required Decimal amount,
    required String idempotencyKey,
    String? description,
  }) => _post('/transactions/top-up', {
        'amount': toApiAmount(amount),
        'idempotency_key': idempotencyKey,
        if (description != null && description.isNotEmpty) 'description': description,
      });

  Future<Transaction> transfer({
    required int recipientId,
    required Decimal amount,
    required String idempotencyKey,
    String? description,
  }) => _post('/transactions/transfer', {
        'recipient_id': recipientId,
        'amount': toApiAmount(amount),
        'idempotency_key': idempotencyKey,
        if (description != null && description.isNotEmpty) 'description': description,
      });

  Future<Transaction> cashIn({
    required String agentPhone,
    required Decimal amount,
    required String idempotencyKey,
    String? description,
  }) => _post('/transactions/cash-in', {
        'agent_phone': agentPhone,
        'amount': toApiAmount(amount),
        'idempotency_key': idempotencyKey,
        if (description != null && description.isNotEmpty) 'description': description,
      });

  Future<Transaction> cashOut({
    required String agentPhone,
    required Decimal amount,
    required String idempotencyKey,
    String? description,
  }) => _post('/transactions/cash-out', {
        'agent_phone': agentPhone,
        'amount': toApiAmount(amount),
        'idempotency_key': idempotencyKey,
        if (description != null && description.isNotEmpty) 'description': description,
      });

  Future<Transaction> agentWithdrawal({
    required Decimal amount,
    required String idempotencyKey,
    String? description,
  }) => _post('/transactions/agent/withdrawal', {
        'amount': toApiAmount(amount),
        'idempotency_key': idempotencyKey,
        if (description != null && description.isNotEmpty) 'description': description,
      });

  Future<Transaction> _post(String path, Map<String, dynamic> body) => apiCall(() async {
        final response = await _dio.post(path, data: body);
        return _transactionFrom(response);
      });

  Transaction _transactionFrom(Response<dynamic> response) {
    final data = response.data['data'] as Map<String, dynamic>;
    return Transaction.fromJson(data['transaction'] as Map<String, dynamic>);
  }
}
