import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/validators.dart';

class AmountField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final Decimal? maxAmount;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  const AmountField({
    super.key,
    required this.controller,
    this.label = 'Amount',
    this.hint = '0.00',
    this.maxAmount,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Text(
            '৳',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (val) => Validators.validateAmount(val, maxAmount: maxAmount),
      onChanged: onChanged,
    );
  }
}
