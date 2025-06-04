import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truenas_native/screens/login_screen.dart'; // For key constants

class TrueNASWebSocketService {
  IOWebSocketChannel? _channel;
  final StreamController<dynamic> _messagesController = StreamController.broadcast();
  Stream<dynamic> get messages => _messagesController.stream;

  String? _truenasUrl;
  String? _username;
  String? _password;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Completer<bool>? _authCompleter;
  String? _authRequestId; // To track the ID of the auth request

  Future<void> _loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    _truenasUrl = prefs.getString(truenasUrlKey);
    _username = prefs.getString(truenasUsername);
    _password = prefs.getString(truenasPassword);
  }

  void _startListeningToChannel() {
    if (_channel == null) {
      // print("Cannot listen, channel is null.");
      if (_authCompleter != null && !_authCompleter!.isCompleted) {
        _authCompleter!.complete(false);
      }
      return;
    }

    _channel!.stream.listen(
      (message) {
        // print('WS Received: $message');
        dynamic decodedMessage;
        try {
          decodedMessage = jsonDecode(message.toString());
        } catch (e) {
          // print('Error decoding JSON message: $e');
          _messagesController.add(message);
          return;
        }

        // Check if it's an authentication response
        if (_authRequestId != null &&
            decodedMessage is Map &&
            decodedMessage['id'] == _authRequestId) {
          if (decodedMessage.containsKey('result') && decodedMessage['result'] == true) {
            _isConnected = true;
            // print('WebSocket Authenticated successfully.');
            if (_authCompleter != null && !_authCompleter!.isCompleted) {
              _authCompleter!.complete(true);
            }
          } else {
            _isConnected = false;
            String authError = decodedMessage['error']?.toString() ?? 'Authentication failed.';
            // print('WebSocket Authentication failed: $authError');
            if (_authCompleter != null && !_authCompleter!.isCompleted) {
              _authCompleter!.complete(false);
            }
            // Optionally, push the specific auth error to the stream for UI to pick up.
            _messagesController.addError('Authentication failed: $authError');
          }
          _authRequestId = null; // Clear the ID once processed
        } else {
          // Not an auth response, or auth already handled
          _messagesController.add(message);
        }
      },
      onDone: () {
        _isConnected = false;
        // print('WebSocket disconnected.');
        if (_authCompleter != null && !_authCompleter!.isCompleted) {
          _authCompleter!.complete(false);
        }
        _messagesController.addError('WebSocket connection closed.');
      },
      onError: (error) {
        _isConnected = false;
        // print('WebSocket error: $error');
        if (_authCompleter != null && !_authCompleter!.isCompleted) {
          _authCompleter!.complete(false);
        }
        _messagesController.addError('WebSocket error: $error');
      },
    );
  }

  Future<bool> connect() async {
    if (_isConnected && _channel != null) {
      // print('WebSocket already connected and authenticated.');
      return true;
    }

    // If a connection/authentication attempt is already in progress, return its future
    if (_authCompleter != null && !_authCompleter!.isCompleted) {
      // print('Connection/Authentication already in progress.');
      return _authCompleter!.future;
    }

    _authCompleter = Completer<bool>();
    _isConnected = false; // Reset connection state

    await _loadCredentials();

    if (_truenasUrl == null || _username == null || _password == null) {
      // print('Error: TrueNAS URL, Username or Password not found in SharedPreferences.');
      _messagesController.addError('Credentials not configured.');
      if (!_authCompleter!.isCompleted) _authCompleter!.complete(false);
      return _authCompleter!.future;
    }

    _authRequestId = DateTime.now().millisecondsSinceEpoch.toString();
    String wsScheme = _truenasUrl!.startsWith('https://') ? 'wss' : 'ws';
    Uri uri = Uri.parse(_truenasUrl!);
    final wsUrl = Uri.parse('$wsScheme://${uri.host}:${uri.port}/api/current');

    // print('Connecting to WebSocket: $wsUrl');

    try {
      // Close any existing channel before creating a new one
      if (_channel != null) {
        await _channel!.sink.close();
        _channel = null;
      }
      _channel = IOWebSocketChannel.connect(
        wsUrl,
        pingInterval: const Duration(seconds: 15),
      );
      _startListeningToChannel();

      _channel!.sink.add(jsonEncode({
        "jsonrpc": "2.0",
        "id": _authRequestId,
        "msg": "method",
        "method": "auth.login",
        "params": [_username, _password]
      }));
      // print('Sent auth.login request with id: $_authRequestId');
    } catch (e) {
      _isConnected = false;
      // print('WebSocket connection error: $e');
      _messagesController.addError('WebSocket connection error: $e');
      if (!_authCompleter!.isCompleted) {
         _authCompleter!.complete(false);
      }
    }
    return _authCompleter!.future;
  }

  void sendMessage(String message) {
    if (!_isConnected || _channel == null) {
      // print('Cannot send message: WebSocket not connected or not authenticated.');
      return;
    }
    // print('WS Sending: $message');
    _channel!.sink.add(message);
  }

  void sendCommand(String method, [List<dynamic>? params]) {
    if (!_isConnected || _channel == null) {
      // print("Cannot send command: WebSocket not connected or not authenticated.");
      return;
    }
    String commandId = DateTime.now().millisecondsSinceEpoch.toString();
    Map<String, dynamic> message = {
      "jsonrpc": "2.0",
      "id": commandId,
      "msg": "method",
      "method": method,
    };
    if (params != null) {
      message["params"] = params;
    }
    _channel!.sink.add(jsonEncode(message));
    // print('Sent command: $method with id: $commandId');
  }

  void dispose() {
    // print('Closing WebSocket channel.');
    _channel?.sink.close();
    _messagesController.close();
    _isConnected = false;
    _authRequestId = null;
    if (_authCompleter != null && !_authCompleter!.isCompleted) {
      _authCompleter!.complete(false);
    }
  }
}