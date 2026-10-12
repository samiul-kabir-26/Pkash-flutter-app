import 'package:flutter_test/flutter_test.dart';
import 'package:pkash/features/qr/domain/qr_payload.dart';

void main() {
  group('QR payload (§9.1)', () {
    test('builds v1 agent (phone) and user (id) payloads', () {
      expect(buildAgentQr('01712345678'), 'walletms:v1:agent:01712345678');
      expect(buildUserQr(42), 'walletms:v1:user:42');
    });

    test('parses a valid agent QR into the phone number', () {
      final result = parseQrPayload('walletms:v1:agent:01712345678', expected: QrTargetType.agent);
      expect(result, isA<QrParsed>());
      expect((result as QrParsed).value, '01712345678');
    });

    test('parses a valid user QR into the user id', () {
      final result = parseQrPayload('walletms:v1:user:42', expected: QrTargetType.user);
      expect((result as QrParsed).value, '42');
    });

    final rejected = <String, (String, QrTargetType)>{
      'wrong prefix': ('otherapp:v1:agent:01712345678', QrTargetType.agent),
      'wrong version': ('walletms:v9:agent:01712345678', QrTargetType.agent),
      'user QR on an agent screen': ('walletms:v1:user:42', QrTargetType.agent),
      'agent QR on the send screen': ('walletms:v1:agent:01712345678', QrTargetType.user),
      'bad agent phone': ('walletms:v1:agent:01212345678', QrTargetType.agent),
      'old v1 agent QR with an id': ('walletms:v1:agent:5', QrTargetType.agent),
      'non-numeric user id': ('walletms:v1:user:abc', QrTargetType.user),
      'zero user id': ('walletms:v1:user:0', QrTargetType.user),
      'bare integer': ('42', QrTargetType.user),
      'random url': ('https://example.com', QrTargetType.user),
    };

    rejected.forEach((name, input) {
      test('rejects $name', () {
        expect(parseQrPayload(input.$1, expected: input.$2), isA<QrRejected>());
      });
    });

    test('wrong type gives a specific reason', () {
      final result = parseQrPayload('walletms:v1:user:42', expected: QrTargetType.agent);
      expect((result as QrRejected).reason, 'This is not an agent QR.');
    });
  });
}
