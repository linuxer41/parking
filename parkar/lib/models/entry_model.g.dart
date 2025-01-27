// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntryModel _$EntryModelFromJson(Map<String, dynamic> json) => EntryModel(
      id: json['id'] as String,
      number: (json['number'] as num).toInt(),
      parkingId: json['parkingId'] as String,
      parking: ParkingModel.fromJson(json['parking'] as Map<String, dynamic>),
      employeeId: json['employeeId'] as String,
      employee:
          EmployeeModel.fromJson(json['employee'] as Map<String, dynamic>),
      vehicleId: json['vehicleId'] as String,
      vehicle: VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>),
      spotId: json['spotId'] as String,
      spot: SpotModel.fromJson(json['spot'] as Map<String, dynamic>),
      dateTime: DateTime.parse(json['dateTime'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$EntryModelToJson(EntryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'parkingId': instance.parkingId,
      'parking': instance.parking,
      'employeeId': instance.employeeId,
      'employee': instance.employee,
      'vehicleId': instance.vehicleId,
      'vehicle': instance.vehicle,
      'spotId': instance.spotId,
      'spot': instance.spot,
      'dateTime': instance.dateTime.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

EntryCreateModel _$EntryCreateModelFromJson(Map<String, dynamic> json) =>
    EntryCreateModel(
      number: (json['number'] as num).toInt(),
      parkingId: json['parkingId'] as String,
      employeeId: json['employeeId'] as String,
      vehicleId: json['vehicleId'] as String,
      spotId: json['spotId'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
    );

Map<String, dynamic> _$EntryCreateModelToJson(EntryCreateModel instance) =>
    <String, dynamic>{
      'number': instance.number,
      'parkingId': instance.parkingId,
      'employeeId': instance.employeeId,
      'vehicleId': instance.vehicleId,
      'spotId': instance.spotId,
      'dateTime': instance.dateTime.toIso8601String(),
    };

EntryUpdateModel _$EntryUpdateModelFromJson(Map<String, dynamic> json) =>
    EntryUpdateModel(
      number: (json['number'] as num?)?.toInt(),
      employeeId: json['employeeId'] as String?,
      vehicleId: json['vehicleId'] as String?,
      spotId: json['spotId'] as String?,
      dateTime: json['dateTime'] == null
          ? null
          : DateTime.parse(json['dateTime'] as String),
    );

Map<String, dynamic> _$EntryUpdateModelToJson(EntryUpdateModel instance) =>
    <String, dynamic>{
      'number': instance.number,
      'employeeId': instance.employeeId,
      'vehicleId': instance.vehicleId,
      'spotId': instance.spotId,
      'dateTime': instance.dateTime?.toIso8601String(),
    };
