import 'package:flutter_test/flutter_test.dart';
import 'package:solarconnect_app/services/socket_service.dart';

void main() {
  group('SocketService lifecycle', () {
    test('connect creates a socket instance and exposes connection state', () {
      final service = SocketService();

      service.connect(
        url: 'http://localhost:3000/energy',
        token: 'demo-token',
      );

      expect(service.socket, isNotNull);
      expect(service.url, 'http://localhost:3000/energy');
      expect(service.isConnected, isFalse);

      service.disconnect();
    });

    test('heartbeat response handler does not throw', () {
      final service = SocketService();

      expect(() => service.handleHeartbeatPing(), returnsNormally);
    });
  });
}
