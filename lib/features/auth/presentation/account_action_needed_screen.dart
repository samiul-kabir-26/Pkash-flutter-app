import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'session_controller.dart';

/// §6.7: a staff member with an unfinished invite who also holds USER/AGENT and signed in
/// by PIN gets 403 "You must change your password before proceeding." on every
/// wallet/transaction/user route.
class AccountActionNeededScreen extends ConsumerWidget {
  const AccountActionNeededScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Action needed'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.admin_panel_settings_outlined, size: 72, color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                'Finish setting up your account',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Finish setting up your staff account on the web, then sign in again.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => ref.read(sessionControllerProvider.notifier).logout(),
                child: const Text('Log out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
