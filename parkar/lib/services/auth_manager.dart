import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Modern Authentication Manager using best practices
///
/// This class handles authentication state management using:
/// - SharedPreferences for token persistence
/// - Singleton pattern for global access
/// - Callback system for state changes
/// - Type-safe token management
class AuthManager {
  static final AuthManager _instance = AuthManager._internal();
  factory AuthManager() => _instance;
  AuthManager._internal();

  // Token storage keys
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _parkingIdKey = 'parking_id';
  static const String _employeeIdKey = 'employee_id';

  // State management
  String? _currentToken;
  String? _currentRefreshToken;
  Map<String, dynamic>? _currentUserData;
  String? _currentParkingId;
  String? _currentEmployeeId;

  // Test mode flag
  bool _isTestMode = false;

  // Callbacks for state changes
  final List<Function(String?)> _tokenChangeCallbacks = [];
  final List<Function(Map<String, dynamic>?)> _userChangeCallbacks = [];

  /// Enable test mode (disables SharedPreferences)
  void enableTestMode() {
    _isTestMode = true;
  }

  /// Disable test mode (enables SharedPreferences)
  void disableTestMode() {
    _isTestMode = false;
  }

  /// Get current authentication token
  String? get token => _currentToken;

  /// Get current refresh token
  String? get refreshToken => _currentRefreshToken;

  /// Get current user data
  Map<String, dynamic>? get userData => _currentUserData;

  /// Get current parking ID
  String? get parkingId => _currentParkingId;

  /// Get current employee ID
  String? get employeeId => _currentEmployeeId;

  /// Check if user is authenticated
  bool get isAuthenticated =>
      _currentToken != null && _currentToken!.isNotEmpty;

  /// Decode JWT token payload
  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode the payload (second part)
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));

      return json.decode(decoded) as Map<String, dynamic>;
    } catch (e) {
      print('Error decoding JWT token: $e');
      return null;
    }
  }

  /// Initialize auth manager and load stored data
  Future<void> initialize() async {
    if (!_isTestMode) {
      await _loadStoredData();
    }
  }

  /// Load stored authentication data from SharedPreferences
  Future<void> _loadStoredData() async {
    if (_isTestMode) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      _currentToken = prefs.getString(_tokenKey);
      _currentRefreshToken = prefs.getString(_refreshTokenKey);
      _currentParkingId = prefs.getString(_parkingIdKey);
      _currentEmployeeId = prefs.getString(_employeeIdKey);

      final userDataString = prefs.getString(_userDataKey);
      if (userDataString != null) {
        final decoded = json.decode(userDataString);
        if (decoded is Map) {
          _currentUserData = Map<String, dynamic>.from(decoded);
        }
      }
    } catch (e) {
      print('Error loading auth data: $e');
      await clearAuth();
    }
  }

  /// Save authentication data to SharedPreferences
  Future<void> _saveAuthData() async {
    if (_isTestMode) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      if (_currentToken != null) {
        await prefs.setString(_tokenKey, _currentToken!);
      }

      if (_currentRefreshToken != null) {
        await prefs.setString(_refreshTokenKey, _currentRefreshToken!);
      }

      if (_currentParkingId != null) {
        await prefs.setString(_parkingIdKey, _currentParkingId!);
      }

      if (_currentEmployeeId != null) {
        await prefs.setString(_employeeIdKey, _currentEmployeeId!);
      }

      if (_currentUserData != null) {
        await prefs.setString(_userDataKey, json.encode(_currentUserData));
      }
    } catch (e) {
      print('Error saving auth data: $e');
    }
  }

  /// Set authentication data after successful login/registration
  Future<void> setAuthData({
    required String token,
    String? refreshToken,
    Map<String, dynamic>? userData,
    String? parkingId,
  }) async {
    _currentToken = token;
    _currentRefreshToken = refreshToken;
    _currentUserData = userData;

    // Decode JWT token to extract tenant and employee information
    final jwtPayload = _decodeJwtPayload(token);
    if (jwtPayload != null) {
      _currentParkingId = jwtPayload['tenant']?.toString() ?? parkingId;
      _currentEmployeeId = jwtPayload['employee']?.toString();
    } else {
      _currentParkingId = parkingId;
    }

    await _saveAuthData();
    _notifyTokenChange(token);
    _notifyUserChange(userData);
  }

  /// Update only the token (for token refresh)
  Future<void> updateToken(String newToken) async {
    _currentToken = newToken;
    await _saveAuthData();
    _notifyTokenChange(newToken);
  }

  /// Update parking ID
  Future<void> setParkingId(String parkingId) async {
    _currentParkingId = parkingId;
    await _saveAuthData();
  }

  /// Clear all authentication data (logout)
  Future<void> clearAuth() async {
    _currentToken = null;
    _currentRefreshToken = null;
    _currentUserData = null;
    _currentParkingId = null;
    _currentEmployeeId = null;

    if (!_isTestMode) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_tokenKey);
        await prefs.remove(_refreshTokenKey);
        await prefs.remove(_userDataKey);
        await prefs.remove(_parkingIdKey);
        await prefs.remove(_employeeIdKey);
      } catch (e) {
        print('Error clearing auth data: $e');
      }
    }

    _notifyTokenChange(null);
    _notifyUserChange(null);
  }

  /// Register callback for token changes
  void onTokenChange(Function(String?) callback) {
    _tokenChangeCallbacks.add(callback);
  }

  /// Register callback for user data changes
  void onUserChange(Function(Map<String, dynamic>?) callback) {
    _userChangeCallbacks.add(callback);
  }

  /// Remove callback for token changes
  void removeTokenChangeCallback(Function(String?) callback) {
    _tokenChangeCallbacks.remove(callback);
  }

  /// Remove callback for user data changes
  void removeUserChangeCallback(Function(Map<String, dynamic>?) callback) {
    _userChangeCallbacks.remove(callback);
  }

  /// Notify all token change callbacks
  void _notifyTokenChange(String? token) {
    for (final callback in _tokenChangeCallbacks) {
      try {
        callback(token);
      } catch (e) {
        print('Error in token change callback: $e');
      }
    }
  }

  /// Notify all user change callbacks
  void _notifyUserChange(Map<String, dynamic>? userData) {
    for (final callback in _userChangeCallbacks) {
      try {
        callback(userData);
      } catch (e) {
        print('Error in user change callback: $e');
      }
    }
  }

  /// Get authorization header
  String? get authorizationHeader {
    if (_currentToken != null && _currentToken!.isNotEmpty) {
      return 'Bearer $_currentToken';
    }
    return null;
  }

  /// Get all headers for API requests
  Map<String, String> getHeaders([Map<String, String>? additionalHeaders]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add authorization header if available
    final authHeader = authorizationHeader;
    if (authHeader != null) {
      headers['Authorization'] = authHeader;
    }

    // Add parking ID if available
    if (_currentParkingId != null) {
      headers['parking-id'] = _currentParkingId!;
    }

    // Add additional headers
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }
}
