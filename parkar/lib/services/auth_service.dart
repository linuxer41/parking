// import 'dart:convert';
// import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/auth_model.dart';
import 'base_service.dart';

/// Service for managing authentication
class AuthService extends BaseService {
  /// Constructor
  AuthService() : super(path: AppConfig.apiEndpoints['auth'] ?? '/auth');

  /// Login with email and password
  Future<AuthResponseModel> login(String email, String password) async {
    return post<AuthResponseModel>(
      endpoint: '/sign-in',
      body: {'email': email, 'password': password},
      parser: (json) => AuthResponseModel.fromJson(json),
    );
  }

  /// Register a new user (legacy method - kept for compatibility)
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    return post<Map<String, dynamic>>(
      endpoint: '/sign-up',
      body: {
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
      },
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  /// Register complete (user + parking)
  Future<AuthResponseModel> registerComplete(RegisterCompleteModel data) async {
    return post<AuthResponseModel>(
      endpoint: '/register-complete',
      body: data.toJson(),
      parser: (json) => AuthResponseModel.fromJson(json),
    );
  }

  /// Request password reset
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return post<Map<String, dynamic>>(
      endpoint: '/forgot-password',
      body: {'email': email},
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  /// Reset password with token
  Future<Map<String, dynamic>> resetPassword(
    String email,
    String token,
    String password,
  ) async {
    return post<Map<String, dynamic>>(
      endpoint: '/reset-password',
      body: {'email': email, 'token': token, 'password': password},
      parser: (json) => json as Map<String, dynamic>,
    );
  }
}
