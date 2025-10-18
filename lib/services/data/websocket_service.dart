import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final String _wsUrl = 'wss://api.ams.hexalyte.com/chat'; // Your WebSocket URL

  // Callbacks for UI updates
  Function(Map<String, dynamic>)? onMessageReceived;
  Function(String)? onUserOnline;
  Function(String)? onUserOffline;
  Function(String)? onTypingStarted;
  Function(String)? onTypingStopped;

  Future<void> connect() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        print('No auth token available for WebSocket');
        return;
      }

      // Connect to WebSocket with auth token
      _channel = WebSocketChannel.connect(
        Uri.parse('$_wsUrl?token=$token'),
      );

      // Listen for incoming messages
      _channel!.stream.listen(
        (message) {
          _handleIncomingMessage(message);
        },
        onError: (error) {
          print('WebSocket error: $error');
          _reconnect();
        },
        onDone: () {
          print('WebSocket disconnected');
          _reconnect();
        },
      );

      print('WebSocket connected successfully');
    } catch (e) {
      print('WebSocket connection failed: $e');
      _reconnect();
    }
  }

  void _handleIncomingMessage(dynamic message) {
    try {
      final data = Map<String, dynamic>.from(message);
      final type = data['type'];

      switch (type) {
        case 'new_message':
          onMessageReceived?.call(data);
          break;
        case 'user_online':
          onUserOnline?.call(data['userId']);
          break;
        case 'user_offline':
          onUserOffline?.call(data['userId']);
          break;
        case 'typing_start':
          onTypingStarted?.call(data['userId']);
          break;
        case 'typing_stop':
          onTypingStopped?.call(data['userId']);
          break;
      }
    } catch (e) {
      print('Error handling WebSocket message: $e');
    }
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(message);
    }
  }

  void sendTyping(String roomId, bool isTyping) {
    sendMessage({
      'type': isTyping ? 'typing_start' : 'typing_stop',
      'roomId': roomId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _reconnect() {
    Future.delayed(Duration(seconds: 3), () {
      connect();
    });
  }

  void disconnect() {
    _channel?.sink.close();
  }
}
