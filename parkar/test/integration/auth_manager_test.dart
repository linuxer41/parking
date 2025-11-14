import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parkar/services/auth_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AuthManager Tests', () {
    late AuthManager authManager;

    setUp(() {
      authManager = AuthManager();
      authManager.enableTestMode();
    });

    tearDown(() async {
      // Clear all stored data after each test
      await authManager.clearAuth();
    });

    group('Token Management', () {
      test('should store and retrieve token correctly', () async {
        // Arrange
        const testToken = 'test_token_123';
        
        // Act
        await authManager.setAuthData(token: testToken);
        
        // Assert
        expect(authManager.token, equals(testToken));
        expect(authManager.isAuthenticated, isTrue);
        expect(authManager.authorizationHeader, equals('Bearer $testToken'));
      });

      test('should update token correctly', () async {
        // Arrange
        const initialToken = 'initial_token';
        const newToken = 'new_token_456';
        
        // Act
        await authManager.setAuthData(token: initialToken);
        await authManager.updateToken(newToken);
        
        // Assert
        expect(authManager.token, equals(newToken));
        expect(authManager.authorizationHeader, equals('Bearer $newToken'));
      });

      test('should clear token on logout', () async {
        // Arrange
        const testToken = 'test_token';
        await authManager.setAuthData(token: testToken);
        
        // Act
        await authManager.clearAuth();
        
        // Assert
        expect(authManager.token, isNull);
        expect(authManager.isAuthenticated, isFalse);
        expect(authManager.authorizationHeader, isNull);
      });
    });

    group('User Data Management', () {
      test('should store and retrieve user data correctly', () async {
        // Arrange
        const testToken = 'test_token';
        final testUserData = {
          'id': 'user_123',
          'name': 'John Doe',
          'email': 'john@example.com',
        };
        
        // Act
        await authManager.setAuthData(
          token: testToken,
          userData: testUserData,
        );
        
        // Assert
        expect(authManager.userData, equals(testUserData));
        expect(authManager.userData!['name'], equals('John Doe'));
      });

      test('should store and retrieve parking ID correctly', () async {
        // Arrange
        const testToken = 'test_token';
        const testParkingId = 'parking_456';
        
        // Act
        await authManager.setAuthData(
          token: testToken,
          parkingId: testParkingId,
        );
        
        // Assert
        expect(authManager.parkingId, equals(testParkingId));
      });
    });

    group('Headers Generation', () {
      test('should generate correct headers with token', () async {
        // Arrange
        const testToken = 'test_token_789';
        const testParkingId = 'parking_123';
        
        // Act
        await authManager.setAuthData(
          token: testToken,
          parkingId: testParkingId,
        );
        
        final headers = authManager.getHeaders();
        
        // Assert
        expect(headers['Authorization'], equals('Bearer $testToken'));
        expect(headers['parking-id'], equals(testParkingId));
        expect(headers['Content-Type'], equals('application/json'));
        expect(headers['Accept'], equals('application/json'));
      });

      test('should generate headers without token when not authenticated', () async {
        // Act
        final headers = authManager.getHeaders();
        
        // Assert
        expect(headers.containsKey('Authorization'), isFalse);
        expect(headers['Content-Type'], equals('application/json'));
        expect(headers['Accept'], equals('application/json'));
      });

      test('should include additional headers', () async {
        // Arrange
        const testToken = 'test_token';
        await authManager.setAuthData(token: testToken);
        
        final additionalHeaders = {
          'Custom-Header': 'custom_value',
          'X-Request-ID': 'req_123',
        };
        
        // Act
        final headers = authManager.getHeaders(additionalHeaders);
        
        // Assert
        expect(headers['Authorization'], equals('Bearer $testToken'));
        expect(headers['Custom-Header'], equals('custom_value'));
        expect(headers['X-Request-ID'], equals('req_123'));
      });
    });

    group('Callback System', () {
      test('should notify token change callbacks', () async {
        // Arrange
        String? receivedToken;
        authManager.onTokenChange((token) {
          receivedToken = token;
        });
        
        // Act
        const testToken = 'callback_test_token';
        await authManager.setAuthData(token: testToken);
        
        // Assert
        expect(receivedToken, equals(testToken));
      });

      test('should notify user change callbacks', () async {
        // Arrange
        Map<String, dynamic>? receivedUserData;
        authManager.onUserChange((userData) {
          receivedUserData = userData;
        });
        
        // Act
        final testUserData = {'name': 'Test User'};
        await authManager.setAuthData(
          token: 'test_token',
          userData: testUserData,
        );
        
        // Assert
        expect(receivedUserData, equals(testUserData));
      });

      test('should notify callbacks on logout', () async {
        // Arrange
        String? receivedToken;
        Map<String, dynamic>? receivedUserData;
        
        authManager.onTokenChange((token) {
          receivedToken = token;
        });
        authManager.onUserChange((userData) {
          receivedUserData = userData;
        });
        
        // Set initial data
        await authManager.setAuthData(
          token: 'test_token',
          userData: {'name': 'Test'},
        );
        
        // Act
        await authManager.clearAuth();
        
        // Assert
        expect(receivedToken, isNull);
        expect(receivedUserData, isNull);
      });
    });

    group('Persistence', () {
      test('should persist data across instances', () async {
        // Arrange
        const testToken = 'persistent_token';
        const testParkingId = 'persistent_parking';
        final testUserData = {'name': 'Persistent User'};
        
        // Act
        await authManager.setAuthData(
          token: testToken,
          parkingId: testParkingId,
          userData: testUserData,
        );
        
        // Create new instance
        final newAuthManager = AuthManager();
        newAuthManager.enableTestMode();
        await newAuthManager.initialize();
        
        // Assert
        expect(newAuthManager.token, equals(testToken));
        expect(newAuthManager.parkingId, equals(testParkingId));
        expect(newAuthManager.userData, equals(testUserData));
      });
    });
  });
}
