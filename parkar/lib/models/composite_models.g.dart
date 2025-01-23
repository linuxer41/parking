// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'composite_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompanyCompositeModel _$CompanyCompositeModelFromJson(
        Map<String, dynamic> json) =>
    CompanyCompositeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      logoUrl: json['logoUrl'] as String?,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      params: json['params'] == null
          ? null
          : CompanyParamsModel.fromJson(json['params'] as Map<String, dynamic>),
      parkings: (json['parkings'] as List<dynamic>)
          .map((e) => ParkingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CompanyCompositeModelToJson(
        CompanyCompositeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'logoUrl': instance.logoUrl,
      'userId': instance.userId,
      'params': instance.params,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'parkings': instance.parkings,
    };

ParkingCompositeModel _$ParkingCompositeModelFromJson(
        Map<String, dynamic> json) =>
    ParkingCompositeModel(
      levels: (json['levels'] as List<dynamic>)
          .map((e) => LevelModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      id: json['id'] as String,
      name: json['name'] as String,
      companyId: json['companyId'] as String,
      vehicleTypes: (json['vehicleTypes'] as List<dynamic>)
          .map((e) => VehicleTypeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      params:
          ParkingParamsModel.fromJson(json['params'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      prices: (json['prices'] as List<dynamic>)
          .map((e) => PriceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      subscriptionPlans: (json['subscriptionPlans'] as List<dynamic>)
          .map((e) => SubscriptionPlanModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ParkingCompositeModelToJson(
        ParkingCompositeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'companyId': instance.companyId,
      'vehicleTypes': instance.vehicleTypes,
      'params': instance.params,
      'prices': instance.prices,
      'subscriptionPlans': instance.subscriptionPlans,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'levels': instance.levels,
    };
