import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/money/money.dart';
import '../../auth/presentation/session_controller.dart';
import '../../transactions/data/transaction_repository.dart';
import '../../transactions/domain/transaction_direction.dart';
import 'wallet_providers.dart';

final recentTransactionsProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  final result = await repo.getHistory(perPage: 5);
  return result.transactions;
});

class UserHomeScreen extends ConsumerStatefulWidget {
  const UserHomeScreen({super.key});

  @override
  ConsumerState<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends ConsumerState<UserHomeScreen> {
  bool _balanceRevealed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = ref.watch(sessionControllerProvider).value;
    final walletAsync = ref.watch(walletProvider);
    final capsAsync = ref.watch(capsProvider);
    final recentTxAsync = ref.watch(recentTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(Icons.person, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session?.user.name ?? 'Customer',
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
            icon: const Icon(Icons.qr_code),
            tooltip: 'My QR',
            onPressed: () => context.push('/my-qr'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(walletProvider);
          ref.invalidate(capsProvider);
          ref.invalidate(recentTransactionsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Blocked Wallet Banner
              walletAsync.maybeWhen(
                data: (wallet) {
                  if (wallet.isBlocked) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.block, color: Colors.red.shade700, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Wallet Blocked',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Your wallet is blocked. Sending and withdrawing are disabled. Contact support.',
                                  style: TextStyle(fontSize: 13, color: Colors.red.shade800),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                orElse: () => const SizedBox.shrink(),
              ),

              // Balance Card (Tap-to-reveal)
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
                              'Available Balance',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            Icon(
                              _balanceRevealed ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        walletAsync.when(
                          data: (wallet) {
                            return Text(
                              _balanceRevealed ? formatBdt(wallet.balance) : '৳ ••••••',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            );
                          },
                          loading: () => const SizedBox(
                            height: 38,
                            child: Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          ),
                          error: (_, _) => const Text(
                            'Error loading balance',
                            style: TextStyle(color: Colors.white, fontSize: 16),
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

              const SizedBox(height: 20),

              // Quick Actions
              walletAsync.maybeWhen(
                data: (wallet) => _buildQuickActions(context, isBlocked: wallet.isBlocked),
                orElse: () => _buildQuickActions(context, isBlocked: false),
              ),

              const SizedBox(height: 20),

              // Caps Card
              capsAsync.maybeWhen(
                data: (caps) {
                  if (caps == null) return const SizedBox.shrink();
                  final dailyProgress = caps.dailyCap > Decimal.zero
                      ? (caps.dailyUsed.toDouble() / caps.dailyCap.toDouble()).clamp(0.0, 1.0)
                      : 0.0;
                  final monthlyProgress = caps.monthlyCap > Decimal.zero
                      ? (caps.monthlyUsed.toDouble() / caps.monthlyCap.toDouble()).clamp(0.0, 1.0)
                      : 0.0;

                  return Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Transaction Limits',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Daily Used: ${formatBdt(caps.dailyUsed)}', style: const TextStyle(fontSize: 13)),
                              Text('Limit: ${formatBdt(caps.dailyCap)}', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: dailyProgress,
                            backgroundColor: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Monthly Used: ${formatBdt(caps.monthlyUsed)}', style: const TextStyle(fontSize: 13)),
                              Text('Limit: ${formatBdt(caps.monthlyCap)}', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: monthlyProgress,
                            backgroundColor: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              ),

              const SizedBox(height: 20),

              // Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => context.go('/user/history'),
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Recent Transactions List
              recentTxAsync.when(
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            'No transactions yet',
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
                      final dir = directionFor(tx, myId);
                      final isInbound = dir == TransactionDirection.inbound;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isInbound ? Colors.green.shade50 : Colors.red.shade50,
                          child: Icon(
                            isInbound ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isInbound ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                        title: Text(
                          tx.type.replaceAll('_', ' '),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        subtitle: Text(
                          tx.createdAt != null
                              ? '${tx.createdAt!.toLocal().day}/${tx.createdAt!.toLocal().month}/${tx.createdAt!.toLocal().year}'
                              : '',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Text(
                          '${isInbound ? '+' : '-'}${formatBdt(tx.amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isInbound ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                        onTap: () {
                          context.push('/user/history/${tx.id}');
                        },
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
                  child: Text('Could not load transactions: $err'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, {required bool isBlocked}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionItem(
              context,
              icon: Icons.send_outlined,
              label: 'Send',
              color: Colors.blue,
              onTap: isBlocked ? null : () => context.push('/user/send'),
            ),
            _buildActionItem(
              context,
              icon: Icons.arrow_downward_outlined,
              label: 'Cash-In',
              color: Colors.green,
              onTap: isBlocked ? null : () => context.push('/user/cash-in'),
            ),
            _buildActionItem(
              context,
              icon: Icons.arrow_upward_outlined,
              label: 'Cash-Out',
              color: Colors.orange,
              onTap: isBlocked ? null : () => context.push('/user/cash-out'),
            ),
            _buildActionItem(
              context,
              icon: Icons.add_circle_outline,
              label: 'Top-Up',
              color: Colors.purple,
              onTap: isBlocked ? null : () => context.push('/user/top-up'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    final disabled = onTap == null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: disabled ? Colors.grey.shade200 : color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: disabled ? Colors.grey.shade400 : color,
                size: 26,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: disabled ? Colors.grey.shade400 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
