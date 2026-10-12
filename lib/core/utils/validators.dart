import 'package:decimal/decimal.dart';

class Validators {
  static final RegExp _phoneRegex = RegExp(r'^01[3-9]\d{8}$');
  static final RegExp _digitsOnlyRegex = RegExp(r'^\d+$');

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required.';
    }
    final trimmed = value.trim();
    if (!_phoneRegex.hasMatch(trimmed)) {
      return 'Enter a valid Bangladeshi phone number (e.g. 01712345678).';
    }
    return null;
  }

  static String? validatePin(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN is required.';
    }
    if (!_digitsOnlyRegex.hasMatch(value)) {
      return 'PIN must contain digits only.';
    }
    if (value.length < 5 || value.length > 10) {
      return 'PIN must be between 5 and 10 digits.';
    }
    return null;
  }

  static String? validatePinConfirmation(String? value, String? pin) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your PIN.';
    }
    if (value != pin) {
      return 'PINs do not match.';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required.';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters.';
    }
    if (value.trim().length > 255) {
      return 'Name cannot exceed 255 characters.';
    }
    return null;
  }

  static String? validateAmount(String? value, {Decimal? maxAmount}) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required.';
    }
    final trimmed = value.trim();
    final parsed = Decimal.tryParse(trimmed);
    if (parsed == null || parsed <= Decimal.zero) {
      return 'Enter a valid amount greater than 0.';
    }
    // Check decimal places
    final parts = trimmed.split('.');
    if (parts.length > 1 && parts[1].length > 2) {
      return 'Amount cannot have more than 2 decimal places.';
    }
    if (maxAmount != null && parsed > maxAmount) {
      return 'Amount exceeds available balance ($maxAmount).';
    }
    return null;
  }

  static String? validateId(String? value, {String fieldName = 'ID'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return 'Enter a valid positive integer for $fieldName.';
    }
    return null;
  }

  /// `agent_phone` for cash-in / cash-out: BD phone, and not your own number.
  static String? validateAgentPhone(String? value, {String? ownPhone}) {
    final phoneError = validatePhone(value);
    if (phoneError != null) return phoneError;
    if (ownPhone != null && ownPhone.isNotEmpty && value!.trim() == ownPhone) {
      return 'The agent must be a different user.';
    }
    return null;
  }

  /// `recipient_id` for transfers: positive integer, and not your own ID.
  static String? validateRecipientId(String? value, {int? ownId}) {
    final idError = validateId(value, fieldName: 'Recipient ID');
    if (idError != null) return idError;
    if (ownId != null && int.parse(value!.trim()) == ownId) {
      return "You can't send money to yourself.";
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value != null && value.length > 500) {
      return 'Description cannot exceed 500 characters.';
    }
    return null;
  }
}
