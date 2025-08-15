// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponseModel _$AuthResponseModelFromJson(Map<String, dynamic> json) =>
    AuthResponseModel(
      token: json['token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      parkings: (json['parkings'] as List<dynamic>)
          .map((e) => ParkingSimpleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AuthResponseModelToJson(AuthResponseModel instance) =>
    <String, dynamic>{
      'token': instance.token,
      'user': instance.user,
      'parkings': instance.parkings,
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
  capacity: (json['capacity'] as num).toInt(),
  operationMode: json['operationMode'] as String,
  location: (json['location'] as List<dynamic>)
      .map((e) => (e as num).toDouble())
      .toList(),
);

Map<String, dynamic> _$RegisterParkingModelToJson(
  RegisterParkingModel instance,
) => <String, dynamic>{
  'name': instance.name,
  'capacity': instance.capacity,
  'operationMode': instance.operationMode,
  'location': instance.location,
};
