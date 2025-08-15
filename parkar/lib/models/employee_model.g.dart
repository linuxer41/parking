// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployeeModel _$EmployeeModelFromJson(Map<String, dynamic> json) =>
    EmployeeModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      parkingId: json['parkingId'] as String,
      role: json['role'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$EmployeeModelToJson(EmployeeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'parkingId': instance.parkingId,
      'role': instance.role,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

EmployeeCreateModel _$EmployeeCreateModelFromJson(Map<String, dynamic> json) =>
    EmployeeCreateModel(
      userId: json['userId'] as String,
      parkingId: json['parkingId'] as String,
      role: json['role'] as String,
    );

Map<String, dynamic> _$EmployeeCreateModelToJson(
  EmployeeCreateModel instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'parkingId': instance.parkingId,
  'role': instance.role,
};

EmployeeUpdateModel _$EmployeeUpdateModelFromJson(Map<String, dynamic> json) =>
    EmployeeUpdateModel(role: json['role'] as String?);

Map<String, dynamic> _$EmployeeUpdateModelToJson(
  EmployeeUpdateModel instance,
) => <String, dynamic>{'role': instance.role};

EmployeePreviewModel _$EmployeePreviewModelFromJson(
  Map<String, dynamic> json,
) => EmployeePreviewModel(
  id: json['id'] as String,
  name: json['name'] as String,
  role: json['role'] as String,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
);

Map<String, dynamic> _$EmployeePreviewModelToJson(
  EmployeePreviewModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'role': instance.role,
  'email': instance.email,
  'phone': instance.phone,
};
