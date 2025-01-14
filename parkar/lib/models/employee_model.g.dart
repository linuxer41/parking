// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployeeModel _$EmployeeModelFromJson(Map<String, dynamic> json) =>
    EmployeeModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      user: json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
      companyId: json['companyId'] as String,
      company: json['company'] == null
          ? null
          : CompanyModel.fromJson(json['company'] as Map<String, dynamic>),
      role: json['role'] as String,
      assignedParkings: (json['assignedParkings'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$EmployeeModelToJson(EmployeeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'user': instance.user,
      'companyId': instance.companyId,
      'company': instance.company,
      'role': instance.role,
      'assignedParkings': instance.assignedParkings,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

EmployeeCreateModel _$EmployeeCreateModelFromJson(Map<String, dynamic> json) =>
    EmployeeCreateModel(
      userId: json['userId'] as String,
      companyId: json['companyId'] as String,
      role: json['role'] as String,
      assignedParkings: (json['assignedParkings'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$EmployeeCreateModelToJson(
        EmployeeCreateModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'companyId': instance.companyId,
      'role': instance.role,
      'assignedParkings': instance.assignedParkings,
    };

EmployeeUpdateModel _$EmployeeUpdateModelFromJson(Map<String, dynamic> json) =>
    EmployeeUpdateModel(
      role: json['role'] as String,
      assignedParkings: (json['assignedParkings'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$EmployeeUpdateModelToJson(
        EmployeeUpdateModel instance) =>
    <String, dynamic>{
      'role': instance.role,
      'assignedParkings': instance.assignedParkings,
    };
