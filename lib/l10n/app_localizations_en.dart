// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Pkash';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get customer => 'Customer';

  @override
  String get agent => 'Agent';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phoneHint => '017XXXXXXXX';

  @override
  String get pin => 'PIN';

  @override
  String get pinHint => '5-10 digit PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get name => 'Full Name';

  @override
  String get nameHint => 'Enter your full name';

  @override
  String get login => 'Log In';

  @override
  String get register => 'Register';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get forgotPin => 'Forgot PIN?';

  @override
  String get forgotPinInfo =>
      'For security reasons, PIN recovery cannot be done automatically. Please contact Customer Care at support@pkash.local or call our helpline. Our staff will verify your identity and send an official one-time PIN reset link.';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get invalidPhone =>
      'Please enter a valid 11-digit Bangladeshi mobile number (e.g. 017XXXXXXXX).';

  @override
  String get invalidPin => 'PIN must be between 5 and 10 digits.';

  @override
  String get pinMismatch => 'PINs do not match.';

  @override
  String get nameRequired => 'Name is required.';

  @override
  String get agentPendingTitle => 'Account Pending Approval';

  @override
  String get agentPendingMessage =>
      'Your agent registration has been received and is pending administrator review. Once verified and approved, you can log in to your agent panel.';

  @override
  String get logout => 'Log Out';

  @override
  String get home => 'Home';

  @override
  String get sendMoney => 'Send Money';

  @override
  String get cashIn => 'Cash In';

  @override
  String get cashOut => 'Cash Out';

  @override
  String get topUp => 'Top Up';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get history => 'History';

  @override
  String get profile => 'Profile';

  @override
  String get myQr => 'My QR';

  @override
  String get scanQr => 'Scan QR';

  @override
  String get balance => 'Balance';

  @override
  String get tapToReveal => 'Tap to reveal balance';

  @override
  String get walletBlocked =>
      'Your wallet is blocked. Contact support immediately.';

  @override
  String get dailyCap => 'Daily Limit';

  @override
  String get monthlyCap => 'Monthly Limit';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get seeAll => 'See All';

  @override
  String get noTransactions => 'No transactions yet.';

  @override
  String get amount => 'Amount';

  @override
  String get amountHint => '0.00';

  @override
  String get description => 'Note / Description';

  @override
  String get descriptionHint => 'Optional note (max 500 chars)';

  @override
  String get recipientId => 'Recipient User ID';

  @override
  String get agentId => 'Agent ID';

  @override
  String get review => 'Review Transfer';

  @override
  String get confirm => 'Confirm & Send';

  @override
  String get cancel => 'Cancel';

  @override
  String get selfTransferError => 'You cannot send money to yourself.';

  @override
  String get insufficientBalance =>
      'Insufficient balance for this transaction.';

  @override
  String get capExceeded => 'Transaction cap exceeded.';

  @override
  String get cashOutFeeNotice =>
      'A cash-out fee applies and is deducted in addition to the amount. Exact fee will be shown on your receipt.';

  @override
  String get transactionSuccess => 'Transaction Successful';

  @override
  String get transactionFailed => 'Transaction Failed';

  @override
  String get transactionUnknown => 'Transaction Outcome Unknown';

  @override
  String get transactionUnknownMsg =>
      'We could not verify the outcome of this transaction due to a network timeout. Retrying securely...';

  @override
  String get checkHistory => 'Check History';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get receipt => 'Receipt';

  @override
  String get transactionId => 'Transaction ID';

  @override
  String get type => 'Type';

  @override
  String get fee => 'Fee';

  @override
  String get commission => 'Commission';

  @override
  String get totalDebited => 'Total Debited';

  @override
  String get balanceAfter => 'New Balance';

  @override
  String get date => 'Date';

  @override
  String get appLock => 'App Lock (Biometrics/PIN)';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get save => 'Save';

  @override
  String get address => 'Address';

  @override
  String get addressHint => 'Enter your address';

  @override
  String get retry => 'Retry';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';
}
