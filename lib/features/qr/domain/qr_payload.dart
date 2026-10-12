import '../../../core/utils/validators.dart';

/// `walletms:v1:agent:<phone_number>` / `walletms:v1:user:<user_id>` (§9.1).
/// Carries only public identifiers; the prefix check prevents mistakes, it is not security.
enum QrTargetType { user, agent }

const _prefix = 'walletms';
const _version = 'v1';

String buildAgentQr(String phoneNumber) => '$_prefix:$_version:agent:$phoneNumber';

String buildUserQr(int userId) => '$_prefix:$_version:user:$userId';

sealed class QrParseResult {
  const QrParseResult();
}

class QrParsed extends QrParseResult {
  final QrTargetType type;

  /// Agent phone number, or user ID as a string.
  final String value;

  const QrParsed(this.type, this.value);
}

class QrRejected extends QrParseResult {
  final String reason;

  const QrRejected(this.reason);
}

QrParseResult parseQrPayload(String raw, {required QrTargetType expected}) {
  final parts = raw.trim().split(':');
  if (parts.length != 4 || parts[0] != _prefix) {
    return const QrRejected('This is not a Pkash QR code.');
  }
  if (parts[1] != _version) {
    return const QrRejected('This QR code version is not supported. Please update the app.');
  }

  final type = switch (parts[2]) {
    'agent' => QrTargetType.agent,
    'user' => QrTargetType.user,
    _ => null,
  };
  if (type == null) {
    return const QrRejected('This is not a Pkash QR code.');
  }
  if (type != expected) {
    return QrRejected(
      expected == QrTargetType.agent ? 'This is not an agent QR.' : 'This is not a customer QR.',
    );
  }

  final value = parts[3];
  switch (type) {
    case QrTargetType.agent:
      if (Validators.validatePhone(value) != null) {
        return const QrRejected('This agent QR has an invalid phone number.');
      }
    case QrTargetType.user:
      final id = int.tryParse(value);
      if (id == null || id <= 0) {
        return const QrRejected('This customer QR has an invalid user ID.');
      }
  }
  return QrParsed(type, value);
}
