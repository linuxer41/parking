// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_register_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CashRegisterModel _$CashRegisterModelFromJson(Map<String, dynamic> json) =>
    CashRegisterModel(
      id: json['id'] as String,
      number: (json['number'] as num).toInt(),
      parkingId: json['parkingId'] as String,
      parking: ParkingModel.fromJson(json['parking'] as Map<String, dynamic>),
      employeeId: json['employeeId'] as String,
      employee:
          EmployeeModel.fromJson(json['employee'] as Map<String, dynamic>),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CashRegisterModelToJson(CashRegisterModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'parkingId': instance.parkingId,
      'parking': instance.parking,
      'employeeId': instance.employeeId,
      'employee': instance.employee,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

CashRegisterCreateModel _$CashRegisterCreateModelFromJson(
        Map<String, dynamic> json) =>
    CashRegisterCreateModel(
      number: (json['number'] as num).toInt(),
      parkingId: json['parkingId'] as String,
      employeeId: json['employeeId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
    );

Map<String, dynamic> _$CashRegisterCreateModelToJson(
        CashRegisterCreateModel instance) =>
    <String, dynamic>{
      'number': instance.number,
      'parkingId': instance.parkingId,
      'employeeId': instance.employeeId,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'status': instance.status,
    };

CashRegisterUpdateModel _$CashRegisterUpdateModelFromJson(
        Map<String, dynamic> json) =>
    CashRegisterUpdateModel(
      number: (json['number'] as num).toInt(),
      employeeId: json['employeeId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
    );

Map<String, dynamic> _$CashRegisterUpdateModelToJson(
        CashRegisterUpdateModel instance) =>
    <String, dynamic>{
      'number': instance.number,
      'employeeId': instance.employeeId,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'status': instance.status,
    };
