// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParkingModel _$ParkingModelFromJson(Map<String, dynamic> json) => ParkingModel(
      id: json['id'] as String,
      name: json['name'] as String,
      companyId: json['companyId'] as String,
      company: json['company'] == null
          ? null
          : CompanyModel.fromJson(json['company'] as Map<String, dynamic>),
      vehicleTypes: (json['vehicleTypes'] as List<dynamic>)
          .map((e) => VehicleTypeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      params:
          ParkingParamsModel.fromJson(json['params'] as Map<String, dynamic>),
      prices: (json['prices'] as List<dynamic>)
          .map((e) => PriceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      subscriptionPlans: (json['subscriptionPlans'] as List<dynamic>)
          .map((e) => SubscriptionPlanModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ParkingModelToJson(ParkingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'companyId': instance.companyId,
      'company': instance.company,
      'vehicleTypes': instance.vehicleTypes,
      'params': instance.params,
      'prices': instance.prices,
      'subscriptionPlans': instance.subscriptionPlans,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

ParkingCreateModel _$ParkingCreateModelFromJson(Map<String, dynamic> json) =>
    ParkingCreateModel(
      name: json['name'] as String,
      companyId: json['companyId'] as String,
    );

Map<String, dynamic> _$ParkingCreateModelToJson(ParkingCreateModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'companyId': instance.companyId,
    };

ParkingUpdateModel _$ParkingUpdateModelFromJson(Map<String, dynamic> json) =>
    ParkingUpdateModel(
      name: json['name'] as String,
    );

Map<String, dynamic> _$ParkingUpdateModelToJson(ParkingUpdateModel instance) =>
    <String, dynamic>{
      'name': instance.name,
    };

VehicleTypeModel _$VehicleTypeModelFromJson(Map<String, dynamic> json) =>
    VehicleTypeModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$VehicleTypeModelToJson(VehicleTypeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
    };

ParkingParamsModel _$ParkingParamsModelFromJson(Map<String, dynamic> json) =>
    ParkingParamsModel(
      currency: json['currency'] as String,
      timeZone: json['timeZone'] as String,
      decimalPlaces: (json['decimalPlaces'] as num).toInt(),
      theme: json['theme'] as String,
    );

Map<String, dynamic> _$ParkingParamsModelToJson(ParkingParamsModel instance) =>
    <String, dynamic>{
      'currency': instance.currency,
      'timeZone': instance.timeZone,
      'decimalPlaces': instance.decimalPlaces,
      'theme': instance.theme,
    };

PriceModel _$PriceModelFromJson(Map<String, dynamic> json) => PriceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      baseTime: (json['baseTime'] as num).toInt(),
      tolerance: (json['tolerance'] as num).toInt(),
      pasePrice: (json['pasePrice'] as num).toDouble(),
    );

Map<String, dynamic> _$PriceModelToJson(PriceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'baseTime': instance.baseTime,
      'tolerance': instance.tolerance,
      'pasePrice': instance.pasePrice,
    };

SubscriptionPlanModel _$SubscriptionPlanModelFromJson(
        Map<String, dynamic> json) =>
    SubscriptionPlanModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      duration: (json['duration'] as num).toInt(),
    );

Map<String, dynamic> _$SubscriptionPlanModelToJson(
        SubscriptionPlanModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'duration': instance.duration,
    };
