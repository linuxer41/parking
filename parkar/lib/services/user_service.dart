import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../models/parking_model.dart';
import 'base_service.dart';
import '../models/user_model.dart';

class UserService extends BaseService {
  UserService() : super(path: AppConfig.apiEndpoints['user']!);

  /// Clave para almacenar los datos del usuario en SharedPreferences
  static const String _userKey = 'user_data';

  /// Obtener un usuario por ID
  Future<UserModel> getUser(String id) async {
    return get<UserModel>(
      endpoint: '/$id',
      parser: (json) => UserModel.fromJson(json),
    );
  }

  /// Actualizar un usuario
  Future<UserModel> updateUser(String id, UserUpdateModel model) async {
    return patch<UserModel>(
      endpoint: '/$id',
      body: model,
      parser: (json) => UserModel.fromJson(json),
    );
  }

  Future<List<ParkingSimpleModel>> getParkings(String userId) async {
    return get<List<ParkingSimpleModel>>(
      endpoint: '/$userId/parkings',
      parser: (data) =>
          (data as List<dynamic>).map((e) => ParkingSimpleModel.fromJson(e)).toList(),
    );
  }

  /// Actualiza el perfil del usuario
  Future<void> updateUserProfile({
    required String name,
    required String email,
    String? photoUrl,
  }) async {
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
  }

  /// Obtiene los datos del usuario
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);

    if (userData != null) {
      return json.decode(userData) as Map<String, dynamic>;
    }

    return null;
  }

  /// Actualiza la contraseña del usuario
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // Aquí se implementaría la lógica real para cambiar la contraseña
    // Por ahora, simulamos un retraso para simular una operación de red
    await Future.delayed(const Duration(seconds: 1));

    // Verificar la contraseña actual (simulado)
    if (currentPassword != '123456') {
      throw Exception('La contraseña actual es incorrecta');
    }

    // Aquí se guardaría la nueva contraseña en un sistema real
  }
}
