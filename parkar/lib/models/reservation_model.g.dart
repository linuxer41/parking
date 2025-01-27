// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReservationModel _$ReservationModelFromJson(Map<String, dynamic> json) =>
    ReservationModel(
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
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ReservationModelToJson(ReservationModel instance) =>
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
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'status': instance.status,
      'amount': instance.amount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

ReservationCreateModel _$ReservationCreateModelFromJson(
        Map<String, dynamic> json) =>
    ReservationCreateModel(
      number: (json['number'] as num).toInt(),
      parkingId: json['parkingId'] as String,
      employeeId: json['employeeId'] as String,
      vehicleId: json['vehicleId'] as String,
      spotId: json['spotId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$ReservationCreateModelToJson(
        ReservationCreateModel instance) =>
    <String, dynamic>{
      'number': instance.number,
      'parkingId': instance.parkingId,
      'employeeId': instance.employeeId,
      'vehicleId': instance.vehicleId,
      'spotId': instance.spotId,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'status': instance.status,
      'amount': instance.amount,
    };

ReservationUpdateModel _$ReservationUpdateModelFromJson(
        Map<String, dynamic> json) =>
    ReservationUpdateModel(
      number: (json['number'] as num?)?.toInt(),
      employeeId: json['employeeId'] as String?,
      vehicleId: json['vehicleId'] as String?,
      spotId: json['spotId'] as String?,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      status: json['status'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ReservationUpdateModelToJson(
        ReservationUpdateModel instance) =>
    <String, dynamic>{
      'number': instance.number,
      'employeeId': instance.employeeId,
      'vehicleId': instance.vehicleId,
      'spotId': instance.spotId,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'status': instance.status,
      'amount': instance.amount,
    };
