import 'package:flutter_test/flutter_test.dart';
import 'package:solarconnect_app/services/socket_service.dart';

group('Realtime notification and settings integration', () {
  test('SocketService exposes a live notification stream for websocket events', () {
    final service = SocketService();

    expect(service.liveNotificationStream, isA<Stream<Map<String, dynamic>>>());

    expect(
      () => service.connect(
        url: 'http://localhost:3000/energy',
        token: 'demo-token',
      ),
      returnsNormally,
    );

    service.disconnect();
  });
});
