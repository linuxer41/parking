// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscriber_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriberModel _$SubscriberModelFromJson(Map<String, dynamic> json) =>
    SubscriberModel(
      id: json['id'] as String,
      parkingId: json['parkingId'] as String,
      parking: ParkingModel.fromJson(json['parking'] as Map<String, dynamic>),
      employeeId: json['employeeId'] as String,
      employee:
          EmployeeModel.fromJson(json['employee'] as Map<String, dynamic>),
      vehicleId: json['vehicleId'] as String,
      vehicle: VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>),
      planId: json['planId'] as String,
      plan:
          SubscriptionPlanModel.fromJson(json['plan'] as Map<String, dynamic>),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SubscriberModelToJson(SubscriberModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parkingId': instance.parkingId,
      'parking': instance.parking,
      'employeeId': instance.employeeId,
      'employee': instance.employee,
      'vehicleId': instance.vehicleId,
      'vehicle': instance.vehicle,
      'planId': instance.planId,
      'plan': instance.plan,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

SubscriberCreateModel _$SubscriberCreateModelFromJson(
        Map<String, dynamic> json) =>
    SubscriberCreateModel(
      parkingId: json['parkingId'] as String,
      employeeId: json['employeeId'] as String,
      vehicleId: json['vehicleId'] as String,
      planId: json['planId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$SubscriberCreateModelToJson(
        SubscriberCreateModel instance) =>
    <String, dynamic>{
      'parkingId': instance.parkingId,
      'employeeId': instance.employeeId,
      'vehicleId': instance.vehicleId,
      'planId': instance.planId,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'isActive': instance.isActive,
    };

SubscriberUpdateModel _$SubscriberUpdateModelFromJson(
        Map<String, dynamic> json) =>
    SubscriberUpdateModel(
      planId: json['planId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$SubscriberUpdateModelToJson(
        SubscriberUpdateModel instance) =>
    <String, dynamic>{
      'planId': instance.planId,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'isActive': instance.isActive,
    };
