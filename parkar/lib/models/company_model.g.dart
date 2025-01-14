// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompanyModel _$CompanyModelFromJson(Map<String, dynamic> json) => CompanyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      logoUrl: json['logoUrl'] as String?,
      userId: json['userId'] as String,
      owner: json['owner'] == null
          ? null
          : UserModel.fromJson(json['owner'] as Map<String, dynamic>),
      params: json['params'] == null
          ? null
          : CompanyParamsModel.fromJson(json['params'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CompanyModelToJson(CompanyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'logoUrl': instance.logoUrl,
      'userId': instance.userId,
      'owner': instance.owner,
      'params': instance.params,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

CompanyCreateModel _$CompanyCreateModelFromJson(Map<String, dynamic> json) =>
    CompanyCreateModel(
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      logoUrl: json['logoUrl'] as String?,
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$CompanyCreateModelToJson(CompanyCreateModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'logoUrl': instance.logoUrl,
      'userId': instance.userId,
    };

CompanyUpdateModel _$CompanyUpdateModelFromJson(Map<String, dynamic> json) =>
    CompanyUpdateModel(
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      logoUrl: json['logoUrl'] as String?,
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$CompanyUpdateModelToJson(CompanyUpdateModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'logoUrl': instance.logoUrl,
      'userId': instance.userId,
    };

CompanyParamsModel _$CompanyParamsModelFromJson(Map<String, dynamic> json) =>
    CompanyParamsModel(
      slogan: json['slogan'] as String,
    );

Map<String, dynamic> _$CompanyParamsModelToJson(CompanyParamsModel instance) =>
    <String, dynamic>{
      'slogan': instance.slogan,
    };
