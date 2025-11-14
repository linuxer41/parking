import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'parking_model.dart';
import 'user_model.dart';

part 'auth_model.g.dart';

/// Modelo para errores de validación (422)
@JsonSerializable()
class ValidationErrorModel extends JsonConvertible<ValidationErrorModel> {
  final String type;
  final String on;
  final String summary;
  final String property;
  final String message;
  final Map<String, dynamic>? expected;
  final Map<String, dynamic>? found;
  final List<Map<String, dynamic>> errors;

  ValidationErrorModel({
    required this.type,
    required this.on,
    required this.summary,
    required this.property,
    required this.message,
    this.expected,
    this.found,
    required this.errors,
  });

  factory ValidationErrorModel.fromJson(Map<String, dynamic> json) =>
      _$ValidationErrorModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ValidationErrorModelToJson(this);
}

/// Modelo para la respuesta de autenticación
@JsonSerializable()
class AuthResponseModel extends JsonConvertible<AuthResponseModel> {
  final AuthDataModel auth;
  final UserModel user;
  final List<ParkingSimpleModel> parkings;

  AuthResponseModel({
    required this.auth,
    required this.user,
    required this.parkings,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}

/// Modelo para los datos de autenticación
@JsonSerializable()
class AuthDataModel extends JsonConvertible<AuthDataModel> {
  final String token;
  final String refreshToken;

  AuthDataModel({required this.token, required this.refreshToken});

  factory AuthDataModel.fromJson(Map<String, dynamic> json) =>
      _$AuthDataModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AuthDataModelToJson(this);
}

/// Modelo para el registro completo (usuario + estacionamiento)
@JsonSerializable()
class RegisterCompleteModel extends JsonConvertible<RegisterCompleteModel> {
  final RegisterUserModel user;
  final RegisterParkingModel parking;

  RegisterCompleteModel({required this.user, required this.parking});

  factory RegisterCompleteModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterCompleteModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RegisterCompleteModelToJson(this);
}

/// Modelo para los datos del usuario en el registro
@JsonSerializable()
class RegisterUserModel extends JsonConvertible<RegisterUserModel> {
  final String name;
  final String email;
  final String password;
  final String phone;

  RegisterUserModel({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
  });

  factory RegisterUserModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterUserModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RegisterUserModelToJson(this);
}

/// Modelo para los datos del estacionamiento en el registro
@JsonSerializable()
class RegisterParkingModel extends JsonConvertible<RegisterParkingModel> {
  final String name;
  final int? capacity;
  final String operationMode;
  final ParkingLocationModel? location;

  RegisterParkingModel({
    required this.name,
    this.capacity,
    required this.operationMode,
    this.location,
  });

  factory RegisterParkingModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterParkingModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RegisterParkingModelToJson(this);
}

/// Modelo para almacenar temporalmente los datos del usuario durante el registro
class TempUserData {
  final String name;
  final String email;
  final String password;
  final String phone;

  TempUserData({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
  });

  /// Convertir a RegisterUserModel
  RegisterUserModel toRegisterUserModel() {
    return RegisterUserModel(
      name: name,
      email: email,
      password: password,
      phone: phone,
    );
  }
}
