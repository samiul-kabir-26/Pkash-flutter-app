import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/pin_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/snackbar_helpers.dart';
import 'session_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();

  // 0: Customer, 1: Agent
  int _selectedPanelIndex = 0;
  bool _isLoading = false;

  // 429: login is throttled to 5 attempts/min; keep the button off for a minute.
  Timer? _cooldown;

  @override
  void initState() {
    super.initState();
    // After a panel switch or agent registration: preselect the panel, prefill the phone.
    final prefill = ref.read(loginPrefillProvider);
    if (prefill != null) {
      _selectedPanelIndex = prefill.panel == Panel.agent ? 1 : 0;
      _phoneController.text = prefill.phoneNumber;
    }
  }

  @override
  void dispose() {
    _cooldown?.cancel();
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _cooldown?.cancel();
    _cooldown = Timer(const Duration(seconds: 60), () {
      if (mounted) setState(() => _cooldown = null);
    });
    setState(() {});
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final phone = _phoneController.text.trim();
    final pin = _pinController.text.trim();

    try {
      if (_selectedPanelIndex == 0) {
        // Customer login
        final session = await ref.read(sessionControllerProvider.notifier).loginCustomer(
              phoneNumber: phone,
              pin: pin,
            );
        if (mounted) {
          showSuccessSnackBar(context, 'Welcome back, ${session.user.name}!');
          context.go('/user/home');
        }
      } else {
        // Agent login
        final session = await ref.read(sessionControllerProvider.notifier).loginAgent(
              phoneNumber: phone,
              pin: pin,
            );
        if (mounted) {
          showSuccessSnackBar(context, 'Welcome, ${session.user.name}!');
          context.go('/agent/home');
        }
      }
    } on ApiException catch (e) {
      if (!mounted) return;

      if (e is NetworkException) {
        showErrorSnackBar(context, 'No connection. Please check your internet connection.');
      } else if (e.isUnauthorized) {
        // Don't reveal whether the phone or the PIN was wrong.
        showErrorSnackBar(context, 'Incorrect phone number or PIN.');
      } else if (e.isForbidden && _selectedPanelIndex == 1) {
        // The agent route returns the same 403 for no role, PENDING, SUSPENDED (G10).
        ref.read(loginPrefillProvider.notifier).set(
              LoginPrefill(panel: Panel.agent, phoneNumber: phone),
            );
        context.go('/agent-pending');
      } else if (e.isForbidden) {
        _showForbiddenDialog(e.message);
      } else if (e.isRateLimited) {
        showErrorSnackBar(context, 'Too many attempts, try again in a minute.');
        _startCooldown();
      } else if (e.isServerError) {
        showErrorSnackBar(context, 'Something went wrong.');
      } else {
        showErrorSnackBar(context, e.message);
      }
    } catch (_) {
      if (mounted) showErrorSnackBar(context, 'Something went wrong.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showForbiddenDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Access Restricted'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/forgot-pin');
            },
            child: const Text('Contact Support'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to Pkash',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select your account portal to sign in',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                  ),
                  const SizedBox(height: 28),
                  // Customer | Agent Toggle
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(
                        value: 0,
                        label: Text('Customer'),
                        icon: Icon(Icons.person_outline),
                      ),
                      ButtonSegment(
                        value: 1,
                        label: Text('Agent'),
                        icon: Icon(Icons.storefront_outlined),
                      ),
                    ],
                    selected: {_selectedPanelIndex},
                    onSelectionChanged: (set) {
                      setState(() => _selectedPanelIndex = set.first);
                    },
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '017XXXXXXXX',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: Validators.validatePhone,
                  ),
                  const SizedBox(height: 18),
                  PinField(
                    controller: _pinController,
                    label: 'PIN',
                    hint: 'Enter your 5-10 digit PIN',
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/forgot-pin'),
                      child: const Text('Forgot PIN?'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: _selectedPanelIndex == 0 ? 'Log In as Customer' : 'Log In as Agent',
                    isLoading: _isLoading,
                    onPressed: _cooldown != null ? null : _handleLogin,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        child: const Text('Register here'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
