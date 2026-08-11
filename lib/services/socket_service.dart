import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? _socket;

  IO.Socket? get socket => _socket;

  void connect({required String url, required String token}) {
    _socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableForceNew()
          .disableAutoConnect()
          .setQuery({'token': token})
          .build(),
    );

    _socket?.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void joinRoom(String room) {
    if (_socket?.connected == true) {
      _socket?.emit('subscribe:inverter', {'inverterId': room});
    }
  }

  void leaveRoom(String room) {
    if (_socket?.connected == true) {
      _socket?.emit('unsubscribe:inverter', {'inverterId': room});
    }
  }

  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, (data) => callback(data));
  }

  void off(String event) {
    _socket?.off(event);
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }
}
