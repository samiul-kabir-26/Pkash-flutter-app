import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'session_controller.dart';

class AgentPendingScreen extends ConsumerWidget {
  const AgentPendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Registration'),
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
                'Approval Pending',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Thank you for registering as an Agent. Your application is currently under review by our administrative team.\n\nOnce approved, you will be able to log in to the Agent portal and process customer cash transactions.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              Card(
                color: Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Verification typically takes 1-2 business days. You will be notified once reviewed.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                icon: const Icon(Icons.support_agent),
                label: const Text('Contact Support'),
                onPressed: () {
                  context.push('/forgot-pin');
                },
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () async {
                  await ref.read(sessionControllerProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
