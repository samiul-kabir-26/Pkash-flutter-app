import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'session_controller.dart';

/// §8.1: reached after AGENT registration or an agent-login 403. The server returns the
/// same 403 for "not approved yet", "suspended" and "no agent role" (G10), so the copy is
/// generic. No wallet or transaction calls happen here.
class AgentPendingScreen extends ConsumerWidget {
  const AgentPendingScreen({super.key});

  void _goToLogin(BuildContext context, WidgetRef ref, Panel panel) {
    final phone = ref.read(loginPrefillProvider)?.phoneNumber ?? '';
    ref.read(loginPrefillProvider.notifier).set(LoginPrefill(panel: panel, phoneNumber: phone));
    context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Access'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.pending_actions_outlined,
                    size: 72,
                    color: Colors.amber.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Agent access not available yet',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Agent access isn't available for this number yet. If you registered recently, "
                'an admin must approve you first. Otherwise contact support.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
              const Spacer(),
              OutlinedButton.icon(
                icon: const Icon(Icons.support_agent),
                label: const Text('Contact Support'),
                onPressed: () => context.push('/forgot-pin'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _goToLogin(context, ref, Panel.user),
                child: const Text('Use the customer app'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _goToLogin(context, ref, Panel.agent),
                child: const Text('Try signing in again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
