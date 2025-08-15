import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/app_config.dart';

/// Simple WebSocket service for real-time parking spot updates
class ParkingRealtimeService with ChangeNotifier {
  // WebSocket connection
  WebSocketChannel? _channel;

  // Ping timer to keep the connection alive
  Timer? _pingTimer;

  // Reconnection timer
  Timer? _reconnectTimer;

  // WebSocket connection status
  bool _isConnected = false;

  // Current parking ID being monitored
  String? _currentParkingId;

  // Callback for spot updates
  Function(String spotId, String? accessId)? onSpotUpdate;

  // Getters
  bool get isConnected => _isConnected;

  /// Constructor
  ParkingRealtimeService();

  /// Start monitoring a parking with real-time updates
  void startMonitoring(String parkingId) {
    // Stop any existing monitoring
    stopMonitoring();

    _currentParkingId = parkingId;

    // Connect to WebSocket
    _connectWebSocket(parkingId);
  }

  /// Connect to WebSocket for real-time updates
  void _connectWebSocket(String parkingId) {
    try {
      final wsUrl = Uri.parse('${AppConfig.wsEndpoint}/ws/$parkingId');
      _channel = WebSocketChannel.connect(wsUrl);

      // Set up listener for WebSocket messages
      _channel!.stream.listen(
        (message) {
          _handleWebSocketMessage(message);
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _isConnected = false;
          _scheduleReconnection();
          notifyListeners();
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          _isConnected = false;
          _scheduleReconnection();
          notifyListeners();
        },
      );

      // Setup ping to keep the connection alive
      _pingTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => _sendPing(),
      );

      _isConnected = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error connecting to WebSocket: $e');
      _isConnected = false;
      notifyListeners();
    }
  }

  /// Schedule WebSocket reconnection
  void _scheduleReconnection() {
    // Cancel any existing reconnection timer
    _reconnectTimer?.cancel();

    // Try to reconnect after a delay
    _reconnectTimer = Timer(
      const Duration(seconds: 5),
      () {
        if (_currentParkingId != null) {
          debugPrint('Attempting to reconnect WebSocket...');
          _connectWebSocket(_currentParkingId!);
        }
      },
    );
  }

  /// Send ping to keep WebSocket connection alive
  void _sendPing() {
    if (_channel != null && _isConnected) {
      try {
        _channel!.sink.add(jsonEncode({
          'type': 'ping',
          'timestamp': DateTime.now().toIso8601String(),
        }));
      } catch (e) {
        debugPrint('Error sending ping: $e');
      }
    }
  }

  /// Handle incoming WebSocket message
  void _handleWebSocketMessage(dynamic message) {
    try {
      final data = jsonDecode(message);

      switch (data['type']) {
        case 'pong':
          // Connection is alive, nothing to do
          break;

        case 'parking_update':
          _handleParkingUpdate(data['data']);
          break;

        case 'error':
          debugPrint('WebSocket error from server: ${data['message']}');
          break;

        default:
          // Ignore other message types
          break;
      }
    } catch (e) {
      debugPrint('Error processing WebSocket message: $e');
    }
  }

  /// Handle parking update notifications
  void _handleParkingUpdate(Map<String, dynamic> data) {
    if (data['type'] == 'spot_update') {
      final spotId = data['spotId'];
      final accessId = data['accessId'];

      // Notify listeners about the spot update
      if (onSpotUpdate != null) {
        onSpotUpdate!(spotId, accessId);
      }

      notifyListeners();
    }
  }

  /// Stop monitoring
  void stopMonitoring() {
    // Close WebSocket connection
    _channel?.sink.close();
    _channel = null;

    // Cancel timers
    _pingTimer?.cancel();
    _pingTimer = null;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _currentParkingId = null;
    _isConnected = false;
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}
