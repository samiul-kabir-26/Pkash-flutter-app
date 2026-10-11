import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/validators.dart';

class PinField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isConfirmation;
  final String? originalPin;
  final String? Function(String?)? customValidator;
  final ValueChanged<String>? onChanged;

  const PinField({
    super.key,
    required this.controller,
    this.label = 'PIN',
    this.hint = '5-10 digit PIN',
    this.isConfirmation = false,
    this.originalPin,
    this.customValidator,
    this.onChanged,
  });

  @override
  State<PinField> createState() => _PinFieldState();
}

class _PinFieldState extends State<PinField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscured,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: () => setState(() => _obscured = !_obscured),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: widget.customValidator ??
          (val) {
            if (widget.isConfirmation) {
              return Validators.validatePinConfirmation(val, widget.originalPin);
            }
            return Validators.validatePin(val);
          },
      onChanged: widget.onChanged,
    );
  }
}
