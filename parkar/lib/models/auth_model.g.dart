// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ValidationErrorModel _$ValidationErrorModelFromJson(
  Map<String, dynamic> json,
) => ValidationErrorModel(
  type: json['type'] as String,
  on: json['on'] as String,
  summary: json['summary'] as String,
  property: json['property'] as String,
  message: json['message'] as String,
  expected: json['expected'] as Map<String, dynamic>?,
  found: json['found'] as Map<String, dynamic>?,
  errors: (json['errors'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
);

Map<String, dynamic> _$ValidationErrorModelToJson(
  ValidationErrorModel instance,
) => <String, dynamic>{
  'type': instance.type,
  'on': instance.on,
  'summary': instance.summary,
  'property': instance.property,
  'message': instance.message,
  'expected': instance.expected,
  'found': instance.found,
  'errors': instance.errors,
};

AuthResponseModel _$AuthResponseModelFromJson(Map<String, dynamic> json) =>
    AuthResponseModel(
      auth: AuthDataModel.fromJson(json['auth'] as Map<String, dynamic>),
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      parkings: (json['parkings'] as List<dynamic>)
          .map((e) => ParkingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AuthResponseModelToJson(AuthResponseModel instance) =>
    <String, dynamic>{
      'auth': instance.auth,
      'user': instance.user,
      'parkings': instance.parkings,
    };

AuthDataModel _$AuthDataModelFromJson(Map<String, dynamic> json) =>
    AuthDataModel(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
    );

Map<String, dynamic> _$AuthDataModelToJson(AuthDataModel instance) =>
    <String, dynamic>{
      'token': instance.token,
      'refreshToken': instance.refreshToken,
    };

RegisterCompleteModel _$RegisterCompleteModelFromJson(
  Map<String, dynamic> json,
) => RegisterCompleteModel(
  user: RegisterUserModel.fromJson(json['user'] as Map<String, dynamic>),
  parking: RegisterParkingModel.fromJson(
    json['parking'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$RegisterCompleteModelToJson(
  RegisterCompleteModel instance,
) => <String, dynamic>{'user': instance.user, 'parking': instance.parking};

RegisterUserModel _$RegisterUserModelFromJson(Map<String, dynamic> json) =>
    RegisterUserModel(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      phone: json['phone'] as String,
    );

Map<String, dynamic> _$RegisterUserModelToJson(RegisterUserModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'phone': instance.phone,
    };

RegisterParkingModel _$RegisterParkingModelFromJson(
  Map<String, dynamic> json,
) => RegisterParkingModel(
  name: json['name'] as String,
  capacity: (json['capacity'] as num?)?.toInt(),
  operationMode: json['operationMode'] as String,
  location: json['location'] == null
      ? null
      : ParkingLocationModel.fromJson(json['location'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RegisterParkingModelToJson(
  RegisterParkingModel instance,
) => <String, dynamic>{
  'name': instance.name,
  'capacity': instance.capacity,
  'operationMode': instance.operationMode,
  'location': instance.location,
};
