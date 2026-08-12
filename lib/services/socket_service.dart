import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  SocketService();

  IO.Socket? _socket;
  String? _url;
  bool _connected = false;
  final StreamController<Map<String, dynamic>> _energyController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _inverterController =
      StreamController<Map<String, dynamic>>.broadcast();

  IO.Socket? get socket => _socket;
  String get url => _url ?? '';
  bool get isConnected => _connected;
  Stream<Map<String, dynamic>> get liveEnergyStream => _energyController.stream;
  Stream<Map<String, dynamic>> get inverterStatusStream => _inverterController.stream;

  void connect({required String url, required String token}) {
    _url = url;
    _connected = false;

    if (_socket != null) {
      disconnect();
    }

    _socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableForceNew()
          .disableAutoConnect()
          .setQuery({'token': token})
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .build(),
    );

    _socket
      ?..onConnect((_) {
        _connected = true;
      })
      ..onDisconnect((_) {
        _connected = false;
      })
      ..onConnectError((error) {
        _connected = false;
      })
      ..on('energy:connected', (data) {
        if (data is Map) {
          _connected = true;
        }
      })
      ..on('energy:live', (data) {
        if (data is Map) {
          _energyController.add(Map<String, dynamic>.from(data));
        }
      })
      ..on('inverter:live-status', (data) {
        if (data is Map) {
          _inverterController.add(Map<String, dynamic>.from(data));
        }
      })
      ..on('heartbeat:ping', (_) {
        handleHeartbeatPing();
      })
      ..on('error', (data) {
        _connected = false;
      });

    _socket?.connect();
    subscribeToEnergy();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _connected = false;
  }

  void subscribeToEnergy() {
    if (_socket?.connected == true) {
      _socket?.emit('subscribe:energy', {});
    }
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

  void handleHeartbeatPing() {
    emit('heartbeat:pong', {});
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

