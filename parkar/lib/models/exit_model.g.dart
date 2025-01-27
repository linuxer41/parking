// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExitModel _$ExitModelFromJson(Map<String, dynamic> json) => ExitModel(
      id: json['id'] as String,
      number: (json['number'] as num).toInt(),
      parkingId: json['parkingId'] as String,
      parking: ParkingModel.fromJson(json['parking'] as Map<String, dynamic>),
      entryId: json['entryId'] as String,
      entry: EntryModel.fromJson(json['entry'] as Map<String, dynamic>),
      employeeId: json['employeeId'] as String,
      employee:
          EmployeeModel.fromJson(json['employee'] as Map<String, dynamic>),
      dateTime: DateTime.parse(json['dateTime'] as String),
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ExitModelToJson(ExitModel instance) => <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'parkingId': instance.parkingId,
      'parking': instance.parking,
      'entryId': instance.entryId,
      'entry': instance.entry,
      'employeeId': instance.employeeId,
      'employee': instance.employee,
      'dateTime': instance.dateTime.toIso8601String(),
      'amount': instance.amount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

ExitCreateModel _$ExitCreateModelFromJson(Map<String, dynamic> json) =>
    ExitCreateModel(
      number: (json['number'] as num).toInt(),
      parkingId: json['parkingId'] as String,
      entryId: json['entryId'] as String,
      employeeId: json['employeeId'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$ExitCreateModelToJson(ExitCreateModel instance) =>
    <String, dynamic>{
      'number': instance.number,
      'parkingId': instance.parkingId,
      'entryId': instance.entryId,
      'employeeId': instance.employeeId,
      'dateTime': instance.dateTime.toIso8601String(),
      'amount': instance.amount,
    };

ExitUpdateModel _$ExitUpdateModelFromJson(Map<String, dynamic> json) =>
    ExitUpdateModel(
      number: (json['number'] as num?)?.toInt(),
      employeeId: json['employeeId'] as String?,
      dateTime: json['dateTime'] == null
          ? null
          : DateTime.parse(json['dateTime'] as String),
      amount: (json['amount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ExitUpdateModelToJson(ExitUpdateModel instance) =>
    <String, dynamic>{
      'number': instance.number,
      'employeeId': instance.employeeId,
      'dateTime': instance.dateTime?.toIso8601String(),
      'amount': instance.amount,
    };
