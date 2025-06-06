import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'http://192.168.100.8:3001';
  final String authPath = '/auth'; // Ruta base para autenticación

  AuthService();

  // Método para realizar el login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.parse('$baseUrl$authPath/sign-in');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return _handleResponse(response);
  }

  // Método para registrar un nuevo usuario
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String name,
  ) async {
    final uri = Uri.parse('$baseUrl$authPath/sign-up');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );

    return _handleResponse(response);
  }

  // Método para solicitar un restablecimiento de contraseña (forgot password)
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final uri = Uri.parse('$baseUrl$authPath/forgot-password');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
      }),
    );

    return _handleResponse(response);
  }

  // Método para restablecer la contraseña (reset password)
  Future<Map<String, dynamic>> resetPassword(
    String token,
    String newPassword,
  ) async {
    final uri = Uri.parse('$baseUrl$authPath/reset-password');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'newPassword': newPassword,
      }),
    );

    return _handleResponse(response);
  }

  // Método para manejar la respuesta de la API
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to complete the request: ${response.statusCode} - ${response.body}');
    }
  }
}
