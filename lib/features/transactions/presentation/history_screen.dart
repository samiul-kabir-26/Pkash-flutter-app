import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/presentation/session_controller.dart';
import 'transaction_providers.dart';
import 'transaction_tile.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  final bool isAgent;

  const HistoryScreen({super.key, this.isAgent = false});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _scrollController = ScrollController();

  // Wallet-scoped history (§7.7, §8.4). Users never see COMMISSION_PAYOUT.
  static const _userFilterChips = {
    null: 'All',
    'TRANSFER': 'Send/Receive',
    'CASH_IN': 'Cash-in',
    'CASH_OUT': 'Cash-out',
    'TOP_UP': 'Top-up',
  };

  static const _agentFilterChips = {
    null: 'All',
    'CASH_IN': 'Cash-in',
    'CASH_OUT': 'Cash-out',
    'COMMISSION_PAYOUT': 'Commission',
    'AGENT_WITHDRAWAL': 'Withdrawal',
  };

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
    final panel = widget.isAgent ? Panel.agent : Panel.user;

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
              children: chips.entries.map((chip) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(chip.value),
                    selected: historyState.type == chip.key,
                    onSelected: (_) {
                      ref.read(historyNotifierProvider.notifier).setFilterType(chip.key);
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
                  ? ListView(
                      // Scrollable so pull-to-refresh also works on the empty/error state.
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 120),
                      children: [
                      Column(
                        children: [
                          Icon(Icons.history_toggle_off,
                              size: 56, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            historyState.error != null
                                ? _errorText(historyState.error!)
                                : 'No transactions yet',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      ],
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
                        return TransactionTile(
                          transaction: tx,
                          panel: panel,
                          myUserId: myId,
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

String _errorText(Object error) {
  if (error is NetworkException) return 'No connection. Pull down to retry.';
  if (error is ApiException && !error.isServerError) return error.message;
  return 'Something went wrong. Pull down to retry.';
}
