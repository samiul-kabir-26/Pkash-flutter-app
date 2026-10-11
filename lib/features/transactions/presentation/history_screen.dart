import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/money/money.dart';
import '../../auth/presentation/session_controller.dart';
import '../data/transaction_repository.dart';
import '../domain/pagination.dart';
import '../domain/transaction.dart';
import '../domain/transaction_direction.dart';

class HistoryFilterState {
  final String? type;
  final int page;
  final List<Transaction> items;
  final Pagination? pagination;
  final bool isLoading;
  final bool hasMore;

  const HistoryFilterState({
    this.type,
    this.page = 1,
    this.items = const [],
    this.pagination,
    this.isLoading = false,
    this.hasMore = true,
  });

  HistoryFilterState copyWith({
    String? type,
    int? page,
    List<Transaction>? items,
    Pagination? pagination,
    bool? isLoading,
    bool? hasMore,
  }) {
    return HistoryFilterState(
      type: type ?? this.type,
      page: page ?? this.page,
      items: items ?? this.items,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

final historyNotifierProvider =
    NotifierProvider.autoDispose<HistoryNotifier, HistoryFilterState>(HistoryNotifier.new);

class HistoryNotifier extends Notifier<HistoryFilterState> {
  @override
  HistoryFilterState build() {
    loadFirstPage();
    return const HistoryFilterState(isLoading: true);
  }

  Future<void> loadFirstPage() async {
    state = state.copyWith(page: 1, items: [], isLoading: true, hasMore: true);
    final repo = ref.read(transactionRepositoryProvider);

    try {
      final res = await repo.getHistory(
        page: 1,
        perPage: 20,
        type: state.type,
      );
      if (!ref.mounted) return;
      state = state.copyWith(
        items: res.transactions,
        pagination: res.pagination,
        isLoading: false,
        hasMore: res.pagination.currentPage < res.pagination.lastPage,
      );
    } catch (_) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    final nextPage = state.page + 1;
    state = state.copyWith(isLoading: true);
    final repo = ref.read(transactionRepositoryProvider);

    try {
      final res = await repo.getHistory(
        page: nextPage,
        perPage: 20,
        type: state.type,
      );
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
    state = state.copyWith(type: type);
    loadFirstPage();
  }
}

class HistoryScreen extends ConsumerStatefulWidget {
  final bool isAgent;

  const HistoryScreen({super.key, this.isAgent = false});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _scrollController = ScrollController();

  final _userFilterChips = const [
    'ALL',
    'TRANSFER',
    'TOP_UP',
    'CASH_IN',
    'CASH_OUT',
  ];

  final _agentFilterChips = const [
    'ALL',
    'CASH_IN',
    'CASH_OUT',
    'AGENT_WITHDRAWAL',
    'COMMISSION_PAYOUT',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(historyNotifierProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyNotifierProvider);
    final session = ref.watch(sessionControllerProvider).value;
    final myId = session?.user.id ?? 0;

    final chips = widget.isAgent ? _agentFilterChips : _userFilterChips;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: chips.map((chip) {
                final isSelected = (chip == 'ALL' && historyState.type == null) ||
                    (historyState.type == chip);
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(chip.replaceAll('_', ' ')),
                    selected: isSelected,
                    onSelected: (_) {
                      ref
                          .read(historyNotifierProvider.notifier)
                          .setFilterType(chip == 'ALL' ? null : chip);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),

          // Transaction List with Infinite Scroll & Pull-to-refresh
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(historyNotifierProvider.notifier).loadFirstPage();
              },
              child: historyState.items.isEmpty && !historyState.isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_toggle_off,
                              size: 56, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            'No transactions found',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: historyState.items.length +
                          (historyState.hasMore ? 1 : 0),
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (ctx, index) {
                        if (index == historyState.items.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final tx = historyState.items[index];
                        final dir = directionFor(tx, myId);
                        final isInbound = dir == TransactionDirection.inbound;

                        final dateFormatted = tx.createdAt != null
                            ? DateFormat('dd MMM yyyy, hh:mm a')
                                .format(tx.createdAt!.toLocal())
                            : '';

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isInbound
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            child: Icon(
                              isInbound
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: isInbound
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                          title: Text(
                            tx.type.replaceAll('_', ' '),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          subtitle: Text(
                            dateFormatted,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isInbound ? '+' : '-'}${formatBdt(tx.amount)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isInbound
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                ),
                              ),
                              if (tx.status != 'COMPLETED')
                                Text(
                                  tx.status,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.orange.shade800),
                                ),
                            ],
                          ),
                          onTap: () {
                            final routePrefix =
                                widget.isAgent ? '/agent/history' : '/user/history';
                            context.push('$routePrefix/${tx.id}');
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
