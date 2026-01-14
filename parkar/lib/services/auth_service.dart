import '../config/app_config.dart';
import '../models/auth_model.dart';
import 'base_service.dart';
import 'api_exception.dart';

class AuthService extends BaseService {
  AuthService() : super(path: AppConfig.apiEndpoints['auth'] ?? '/auth');

  Future<AuthResponseModel> login(String email, String password) async {
    try {
      final response = await post<AuthResponseModel>(
        endpoint: '/sign-in',
        body: {'email': email, 'password': password},
        parser: (json) => parseModel(json, AuthResponseModel.fromJson),
      );

      return response;
    } on ApiException catch (e) {
      if (e.isValidationError) {
        throw ApiException(
          statusCode: e.statusCode,
          message: 'Error de validación: ${e.message}',
          errors: e.errors,
          isValidationError: true,
        );
      }
      rethrow;
    } catch (e) {
      throw ApiException(
        statusCode: 500,
        message: 'Error inesperado durante el login: ${e.toString()}',
      );
    }
  }

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

  Future<AuthResponseModel> registerComplete(
    RegisterCompleteModel registerData,
  ) async {
    try {
      final response = await post<AuthResponseModel>(
        endpoint: '/sign-up',
        body: registerData,
        parser: (json) => parseModel(json, AuthResponseModel.fromJson),
      );
      return response;
    } on ApiException catch (e) {
      if (e.isValidationError) {
        throw ApiException(
          statusCode: e.statusCode,
          message: 'Error de validación en el registro: ${e.message}',
          errors: e.errors,
          isValidationError: true,
        );
      }
      rethrow;
    } catch (e) {
      throw ApiException(
        statusCode: 500,
        message: 'Error inesperado durante el registro: ${e.toString()}',
      );
    }
  }

  Future<void> logout() async {
    try {
      await post<void>(endpoint: '/sign-out', body: {}, parser: (_) => null);
    } catch (e) {
      // Even if API call fails, clear local auth data
      print('Warning: Logout API call failed, clearing local data: $e');
    } finally {
      // Always clear local authentication data
      
    }
  }

  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    try {
      return await post<AuthResponseModel>(
        endpoint: '/refresh',
        body: {'refreshToken': refreshToken},
        parser: (json) => parseModel(json, AuthResponseModel.fromJson),
      );
    } catch (e) {
      throw ApiException(
        statusCode: 500,
        message: 'Error al renovar el token: ${e.toString()}',
      );
    }
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      await post<void>(
        endpoint: '/request-password-reset',
        body: {'email': email},
        parser: (_) => null,
      );
    } catch (e) {
      throw ApiException(
        statusCode: 500,
        message: 'Error al enviar código de recuperación: ${e.toString()}',
      );
    }
  }

  Future<void> resetPassword(String email, String token, String newPassword) async {
    try {
      await post<void>(
        endpoint: '/reset-password',
        body: {'email': email, 'token': token, 'newPassword': newPassword},
        parser: (_) => null,
      );
    } catch (e) {
      throw ApiException(
        statusCode: 500,
        message: 'Error al restablecer contraseña: ${e.toString()}',
      );
    }
  }
}
