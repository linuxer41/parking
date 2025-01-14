// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionPlanModel _$SubscriptionPlanModelFromJson(
        Map<String, dynamic> json) =>
    SubscriptionPlanModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      duration: (json['duration'] as num).toInt(),
      parkingId: json['parkingId'] as String,
      parking: ParkingModel.fromJson(json['parking'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SubscriptionPlanModelToJson(
        SubscriptionPlanModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'duration': instance.duration,
      'parkingId': instance.parkingId,
      'parking': instance.parking,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

SubscriptionPlanCreateModel _$SubscriptionPlanCreateModelFromJson(
        Map<String, dynamic> json) =>
    SubscriptionPlanCreateModel(
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      duration: (json['duration'] as num).toInt(),
      parkingId: json['parkingId'] as String,
    );

Map<String, dynamic> _$SubscriptionPlanCreateModelToJson(
        SubscriptionPlanCreateModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'duration': instance.duration,
      'parkingId': instance.parkingId,
    };

SubscriptionPlanUpdateModel _$SubscriptionPlanUpdateModelFromJson(
        Map<String, dynamic> json) =>
    SubscriptionPlanUpdateModel(
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      duration: (json['duration'] as num).toInt(),
    );

Map<String, dynamic> _$SubscriptionPlanUpdateModelToJson(
        SubscriptionPlanUpdateModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'duration': instance.duration,
    };
