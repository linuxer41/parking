import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parkar/models/composite_models.dart';

import '_base_service.dart';
import '../models/user_model.dart';

class UserService
    extends BaseService<UserModel, UserCreateModel, UserUpdateModel> {
  UserService() : super(path: '/user', fromJsonFactory: UserModel.fromJson);

  /// Clave para almacenar los datos del usuario en SharedPreferences
  static const String _userKey = 'user_data';

  Future<List<CompanyCompositeModel>> getCompanies(String userId) async {
    final uri = Uri.parse('$baseUrl$path/$userId/companies');
    final response = await httpClient.get(
      uri,
      headers: buildHeaders(),
    );
    handleResponse(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => CompanyCompositeModel.fromJson(e)).toList();
  }

  /// Actualiza el perfil del usuario
  Future<void> updateUserProfile({
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    try {
      // Obtener los datos actuales del usuario
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);

      // Crear un mapa con los datos actuales o uno nuevo si no existe
      final Map<String, dynamic> userMap =
          userData != null ? json.decode(userData) as Map<String, dynamic> : {};

      // Actualizar los datos
      userMap['name'] = name;
      userMap['email'] = email;
      if (photoUrl != null) {
        userMap['photoUrl'] = photoUrl;
      }

      // Guardar los datos actualizados
      await prefs.setString(_userKey, json.encode(userMap));
    } catch (e) {
      // Propagar el error para que se maneje en la UI
      rethrow;
    }
  }

  /// Obtiene los datos del usuario
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);

      if (userData != null) {
        return json.decode(userData) as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      // Propagar el error para que se maneje en la UI
      rethrow;
    }
  }

  /// Actualiza la contraseña del usuario
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Aquí se implementaría la lógica real para cambiar la contraseña
      // Por ahora, simulamos un retraso para simular una operación de red
      await Future.delayed(const Duration(seconds: 1));

      // Verificar la contraseña actual (simulado)
      if (currentPassword != '123456') {
        throw Exception('La contraseña actual es incorrecta');
      }

      // Aquí se guardaría la nueva contraseña en un sistema real
    } catch (e) {
      // Propagar el error para que se maneje en la UI
      rethrow;
    }
  }
}
