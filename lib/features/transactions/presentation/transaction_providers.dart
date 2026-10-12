import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/session_controller.dart';
import '../data/transaction_repository.dart';
import '../domain/pagination.dart';
import '../domain/transaction.dart';

/// The 5 most recent rows for the home screens of either panel.
final recentTransactionsProvider = FutureProvider.autoDispose<List<Transaction>>((ref) async {
  final scope = ref.watch(sessionScopeProvider);
  if (scope == null) return const [];
  final repo = ref.watch(transactionRepositoryProvider);
  final result = await repo.getHistory(perPage: 5);
  return result.transactions;
});

final singleTransactionProvider =
    FutureProvider.autoDispose.family<Transaction, int>((ref, id) async {
  ref.watch(sessionScopeProvider);
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getTransaction(id);
});

class HistoryFilterState {
  final String? type;
  final int page;
  final List<Transaction> items;
  final Pagination? pagination;
  final bool isLoading;
  final bool hasMore;
  final Object? error;

  const HistoryFilterState({
    this.type,
    this.page = 1,
    this.items = const [],
    this.pagination,
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  HistoryFilterState copyWith({
    String? type,
    bool clearType = false,
    int? page,
    List<Transaction>? items,
    Pagination? pagination,
    bool? isLoading,
    bool? hasMore,
    Object? error,
  }) {
    return HistoryFilterState(
      type: clearType ? null : (type ?? this.type),
      page: page ?? this.page,
      items: items ?? this.items,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

/// Infinite scroll over `data.transactions`, stopping at `current_page == last_page`.
final historyNotifierProvider =
    NotifierProvider.autoDispose<HistoryNotifier, HistoryFilterState>(HistoryNotifier.new);

class HistoryNotifier extends Notifier<HistoryFilterState> {
  @override
  HistoryFilterState build() {
    ref.watch(sessionScopeProvider);
    Future.microtask(loadFirstPage);
    return const HistoryFilterState(isLoading: true);
  }

  Future<void> loadFirstPage() async {
    state = state.copyWith(page: 1, items: [], isLoading: true, hasMore: true);
    final repo = ref.read(transactionRepositoryProvider);

    try {
      final res = await repo.getHistory(page: 1, perPage: 20, type: state.type);
      if (!ref.mounted) return;
      state = state.copyWith(
        items: res.transactions,
        pagination: res.pagination,
        isLoading: false,
        hasMore: res.pagination.currentPage < res.pagination.lastPage,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, hasMore: false, error: e);
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    final nextPage = state.page + 1;
    state = state.copyWith(isLoading: true);
    final repo = ref.read(transactionRepositoryProvider);

    try {
      final res = await repo.getHistory(page: nextPage, perPage: 20, type: state.type);
      if (!ref.mounted) return;
      state = state.copyWith(
        page: nextPage,
        items: [...state.items, ...res.transactions],
        pagination: res.pagination,
        isLoading: false,
        hasMore: res.pagination.currentPage < res.pagination.lastPage,
      );
    } catch (_) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false);
    }
  }

  void setFilterType(String? type) {
    if (state.type == type) return;
    state = state.copyWith(type: type, clearType: type == null);
    loadFirstPage();
  }
}
