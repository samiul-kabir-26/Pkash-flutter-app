import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/money/money.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/presentation/session_controller.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../transactions/presentation/transaction_providers.dart';
import '../../transactions/presentation/transaction_tile.dart';
import '../../wallet/presentation/user_home_screen.dart';
import '../../wallet/presentation/wallet_providers.dart';

class AgentHomeScreen extends ConsumerStatefulWidget {
  const AgentHomeScreen({super.key});

  @override
  ConsumerState<AgentHomeScreen> createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends ConsumerState<AgentHomeScreen> {
  bool _balanceRevealed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = ref.watch(sessionControllerProvider).value;
    final walletAsync = ref.watch(walletProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final recentTxAsync = ref.watch(recentTransactionsProvider);

    final agentInfo = profileAsync.value?.agentInfo;
    final commissionRate = agentInfo?.commissionRate != null ? formatRate(agentInfo!.rate) : '—';
    final totalCommission = agentInfo?.commission ?? Decimal.zero;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: const Icon(Icons.storefront, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session?.user.name ?? 'Agent Store',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  session?.user.phoneNumber ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2),
            tooltip: 'Agent QR',
            onPressed: () => context.push('/my-qr'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(walletProvider);
          ref.invalidate(userProfileProvider);
          ref.invalidate(recentTransactionsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (walletAsync.value?.isBlocked ?? false)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.block, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your agent wallet is blocked. Contact support.',
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              // Balance Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: theme.colorScheme.primary,
                child: InkWell(
                  onTap: () {
                    setState(() => _balanceRevealed = !_balanceRevealed);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Agent Wallet Balance',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            Icon(
                              _balanceRevealed
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        walletAsync.when(
                          data: (wallet) => Text(
                            _balanceRevealed ? formatBdt(wallet.balance) : '৳ ••••••',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          loading: () => const SizedBox(
                            height: 38,
                            child: Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          ),
                          error: (err, _) => Text(
                            walletErrorText(err, panel: Panel.agent),
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _balanceRevealed ? 'Tap to hide' : 'Tap to reveal balance',
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              Text(
                'Customer cash-ins are paid from this wallet. If it runs low, their cash-ins fail.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),

              // Commission Earnings Card
              Card(
                elevation: 0,
                color: Colors.teal.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.teal.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Commission Rate: $commissionRate',
                            style: TextStyle(fontSize: 13, color: Colors.teal.shade800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatBdt(totalCommission),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Total Commission Earned',
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                      FilledButton.tonal(
                        onPressed: walletAsync.hasValue && !walletAsync.value!.isBlocked
                            ? () => context.push('/agent/withdraw')
                            : null,
                        child: const Text('Withdraw'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Prominent "My Agent QR" Banner
              Card(
                elevation: 0,
                color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  onTap: () => context.push('/my-qr'),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.qr_code_2, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Show Agent QR',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Customers scan this for Cash-In & Cash-Out',
                                style: TextStyle(fontSize: 13, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Recent Activity Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Agent Activity',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => context.go('/agent/history'),
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Recent Agent Activity List
              recentTxAsync.when(
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(Icons.history, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            'No agent transactions yet',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    );
                  }

                  final myId = session?.user.id ?? 0;

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (ctx, index) {
                      final tx = transactions[index];
                      return TransactionTile(
                        transaction: tx,
                        panel: Panel.agent,
                        myUserId: myId,
                        onTap: () => context.push('/agent/history/${tx.id}'),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(err is NetworkException ? 'No connection.' : 'Could not load activity.'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
