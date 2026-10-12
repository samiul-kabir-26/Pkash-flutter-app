import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/money/money.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/snackbar_helpers.dart';
import '../../auth/presentation/session_controller.dart';
import '../data/profile_repository.dart';
import 'profile_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final bool isAgent;

  const ProfileScreen({super.key, this.isAgent = false});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _localAuth = LocalAuthentication();

  bool _isEditing = false;
  bool _isSaving = false;
  bool _appLockEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadAppLockStatus();
  }

  Future<void> _loadAppLockStatus() async {
    final storage = ref.read(secureTokenStorageProvider);
    final enabled = await storage.isAppLockEnabled();
    if (mounted) setState(() => _appLockEnabled = enabled);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleAppLockToggle(bool enable) async {
    final storage = ref.read(secureTokenStorageProvider);
    if (enable) {
      final canAuth = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
      if (!canAuth) {
        if (mounted) {
          showErrorSnackBar(context, 'Device does not support biometric or PIN security.');
        }
        return;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to enable App Lock',
        biometricOnly: false,
      );

      if (authenticated) {
        await storage.setAppLockEnabled(true);
        if (mounted) setState(() => _appLockEnabled = true);
      }
    } else {
      await storage.setAppLockEnabled(false);
      if (mounted) setState(() => _appLockEnabled = false);
    }
  }

  Future<void> _handleSaveProfile(int userId) async {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final nameError = Validators.validateName(name);
    if (nameError != null) {
      showErrorSnackBar(context, nameError);
      return;
    }
    setState(() => _isSaving = true);

    try {
      final repo = ref.read(profileRepositoryProvider);
      await repo.updateProfile(userId, name: name, address: address);
      ref.invalidate(userProfileProvider);
      if (mounted) {
        showSuccessSnackBar(context, 'Profile updated successfully.');
        setState(() => _isEditing = false);
      }
    } on ApiException catch (e) {
      if (mounted) {
        showErrorSnackBar(
          context,
          e.isServerError ? 'Something went wrong.' : (e.fieldErrors.values.firstOrNull ?? e.message),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _confirmLogout() {
    final router = GoRouter.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(sessionControllerProvider.notifier).logout();
              router.go('/login');
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  /// D1: one session at a time. Switching logs out and opens the other login, prefilled.
  void _confirmSwitchPanel() {
    final target = widget.isAgent ? 'Customer' : 'Agent';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Switch to $target panel'),
        content: Text(
          'You will be signed out and asked for your PIN on the $target login. '
          'Each panel has its own wallet and history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(sessionControllerProvider.notifier).switchPanel();
            },
            child: const Text('Switch'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(userProfileProvider);
    final session = ref.watch(sessionControllerProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Profile',
              onPressed: () {
                final user = profileAsync.value?.user ?? session?.user;
                if (user != null) {
                  _nameController.text = user.name;
                  _addressController.text = user.address ?? '';
                }
                setState(() => _isEditing = true);
              },
            ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          final user = profile.user;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(
                          widget.isAgent ? Icons.storefront : Icons.person,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (user.isVerified)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, size: 16, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  user.phoneNumber,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),

                if (_isEditing) ...[
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Edit Information',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: Validators.validateName,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              labelText: 'Address',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => setState(() => _isEditing = false),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: PrimaryButton(
                                  label: 'Save Changes',
                                  isLoading: _isSaving,
                                  onPressed: () => _handleSaveProfile(user.id),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                if (widget.isAgent && profile.agentInfo != null) ...[
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.percent, color: Colors.teal),
                          title: const Text('Commission rate'),
                          trailing: Text(
                            profile.agentInfo!.commissionRate != null
                                ? formatRate(profile.agentInfo!.rate)
                                : '—',
                          ),
                        ),
                        if (profile.agentInfo!.approvedAt != null) ...[
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.verified_outlined, color: Colors.teal),
                            title: const Text('Approved on'),
                            trailing: Text(
                              MaterialLocalizations.of(context)
                                  .formatMediumDate(profile.agentInfo!.approvedAt!.toLocal()),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Action Tiles Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.qr_code, color: Colors.blue),
                        title: const Text('My QR Code'),
                        subtitle: const Text('View and share personal QR code'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/my-qr'),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: const Icon(Icons.fingerprint, color: Colors.purple),
                        title: const Text('App Lock'),
                        subtitle: const Text('Require fingerprint or device PIN'),
                        value: _appLockEnabled,
                        onChanged: _handleAppLockToggle,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.lock_reset, color: Colors.orange),
                        title: const Text('Change PIN'),
                        subtitle: const Text('PIN changes go through customer care'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/forgot-pin'),
                      ),
                      if (profile.hasRole(widget.isAgent ? 'USER' : 'AGENT')) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            widget.isAgent ? Icons.person_outline : Icons.storefront_outlined,
                            color: Colors.indigo,
                          ),
                          title: Text(
                            widget.isAgent ? 'Switch to Customer panel' : 'Switch to Agent panel',
                          ),
                          subtitle: const Text('Signs out of this panel'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _confirmSwitchPanel,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Logout Button
                OutlinedButton.icon(
                  onPressed: _confirmLogout,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Log Out', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(err is NetworkException ? 'No connection.' : 'Could not load your profile.'),
              ElevatedButton(
                onPressed: () => ref.invalidate(userProfileProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
