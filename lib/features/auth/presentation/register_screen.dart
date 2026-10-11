import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/pin_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/snackbar_helpers.dart';
import 'session_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _pinConfirmController = TextEditingController();

  int _selectedRoleIndex = 0; // 0: USER (Customer), 1: AGENT
  bool _isLoading = false;
  String? _phoneServerError;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _pinConfirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() => _phoneServerError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final pin = _pinController.text.trim();
    final pinConfirmation = _pinConfirmController.text.trim();
    final role = _selectedRoleIndex == 0 ? 'USER' : 'AGENT';

    try {
      await ref.read(sessionControllerProvider.notifier).register(
            name: name,
            phoneNumber: phone,
            pin: pin,
            pinConfirmation: pinConfirmation,
            role: role,
          );

      if (!mounted) return;

      if (role == 'USER') {
        showSuccessSnackBar(context, 'Account created! You received a ৳50.00 signup bonus.');
        context.go('/user/home');
      } else {
        context.go('/agent-pending');
      }
    } on ApiException catch (e) {
      if (!mounted) return;

      if (e.isValidationError) {
        if (e.fieldErrors.containsKey('phone_number')) {
          setState(() {
            _phoneServerError = e.fieldErrors['phone_number'];
          });
          _formKey.currentState?.validate();
        } else {
          showErrorSnackBar(context, e.message);
        }
      } else {
        showErrorSnackBar(context, e.message);
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'Could not connect to server. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Join Pkash',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Select account type and complete registration',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 20),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(
                      value: 0,
                      label: Text('Customer (User)'),
                      icon: Icon(Icons.person_outline),
                    ),
                    ButtonSegment(
                      value: 1,
                      label: Text('Agent (Store)'),
                      icon: Icon(Icons.storefront_outlined),
                    ),
                  ],
                  selected: {_selectedRoleIndex},
                  onSelectionChanged: (set) {
                    setState(() => _selectedRoleIndex = set.first);
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full legal name',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '017XXXXXXXX',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    errorText: _phoneServerError,
                  ),
                  validator: (val) {
                    if (_phoneServerError != null) return _phoneServerError;
                    return Validators.validatePhone(val);
                  },
                  onChanged: (_) {
                    if (_phoneServerError != null) {
                      setState(() => _phoneServerError = null);
                    }
                  },
                ),
                const SizedBox(height: 16),
                PinField(
                  controller: _pinController,
                  label: '5-10 Digit PIN',
                  hint: 'Choose a secure PIN',
                ),
                const SizedBox(height: 16),
                PinField(
                  controller: _pinConfirmController,
                  label: 'Confirm PIN',
                  hint: 'Re-enter your PIN',
                  isConfirmation: true,
                  originalPin: _pinController.text,
                  customValidator: (val) {
                    return Validators.validatePinConfirmation(val, _pinController.text);
                  },
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: _selectedRoleIndex == 0 ? 'Register as Customer' : 'Register as Agent',
                  isLoading: _isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Log In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
