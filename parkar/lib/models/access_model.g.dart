// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'access_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccessModel _$AccessModelFromJson(Map<String, dynamic> json) => AccessModel(
  id: json['id'] as String,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  number: (json['number'] as num).toInt(),
  parkingId: json['parkingId'] as String,
  parking: ParkingPreviewModel.fromJson(
    json['parking'] as Map<String, dynamic>,
  ),
  employeeId: json['employeeId'] as String,
  employee: EmployeePreviewModel.fromJson(
    json['employee'] as Map<String, dynamic>,
  ),
  vehicleId: json['vehicleId'] as String,
  vehicle: VehiclePreviewModel.fromJson(
    json['vehicle'] as Map<String, dynamic>,
  ),
  spotId: json['spotId'] as String?,
  entryTime: DateTime.parse(json['entryTime'] as String),
  exitTime: json['exitTime'] == null
      ? null
      : DateTime.parse(json['exitTime'] as String),
  exitEmployeeId: json['exitEmployeeId'] as String?,
  exitEmployee: json['exitEmployee'] == null
      ? null
      : EmployeePreviewModel.fromJson(
          json['exitEmployee'] as Map<String, dynamic>,
        ),
  amount: (json['amount'] as num).toDouble(),
  status: $enumDecode(_$AccessStatusEnumMap, json['status']),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$AccessModelToJson(AccessModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'number': instance.number,
      'parkingId': instance.parkingId,
      'parking': instance.parking,
      'employeeId': instance.employeeId,
      'employee': instance.employee,
      'vehicleId': instance.vehicleId,
      'vehicle': instance.vehicle,
      'spotId': instance.spotId,
      'entryTime': instance.entryTime.toIso8601String(),
      'exitTime': instance.exitTime?.toIso8601String(),
      'exitEmployeeId': instance.exitEmployeeId,
      'exitEmployee': instance.exitEmployee,
      'amount': instance.amount,
      'status': _$AccessStatusEnumMap[instance.status]!,
      'notes': instance.notes,
    };

const _$AccessStatusEnumMap = {
  AccessStatus.entered: 'entered',
  AccessStatus.exited: 'exited',
  AccessStatus.cancelled: 'cancelled',
};

AccessCreateModel _$AccessCreateModelFromJson(Map<String, dynamic> json) =>
    AccessCreateModel(
      vehiclePlate: json['vehiclePlate'] as String,
      vehicleType: json['vehicleType'] as String?,
      vehicleColor: json['vehicleColor'] as String?,
      ownerName: json['ownerName'] as String?,
      ownerDocument: json['ownerDocument'] as String?,
      ownerPhone: json['ownerPhone'] as String?,
      spotId: json['spotId'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$AccessCreateModelToJson(AccessCreateModel instance) =>
    <String, dynamic>{
      'vehiclePlate': instance.vehiclePlate,
      'vehicleType': instance.vehicleType,
      'vehicleColor': instance.vehicleColor,
      'ownerName': instance.ownerName,
      'ownerDocument': instance.ownerDocument,
      'ownerPhone': instance.ownerPhone,
      'spotId': instance.spotId,
      'notes': instance.notes,
    };

AccessUpdateModel _$AccessUpdateModelFromJson(Map<String, dynamic> json) =>
    AccessUpdateModel(
      spotId: json['spotId'] as String?,
      exitTime: json['exitTime'] == null
          ? null
          : DateTime.parse(json['exitTime'] as String),
      exitEmployeeId: json['exitEmployeeId'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      status: $enumDecodeNullable(_$AccessStatusEnumMap, json['status']),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$AccessUpdateModelToJson(AccessUpdateModel instance) =>
    <String, dynamic>{
      'spotId': instance.spotId,
      'exitTime': instance.exitTime?.toIso8601String(),
      'exitEmployeeId': instance.exitEmployeeId,
      'amount': instance.amount,
      'status': _$AccessStatusEnumMap[instance.status],
      'notes': instance.notes,
    };

AccessPreviewModel _$AccessPreviewModelFromJson(Map<String, dynamic> json) =>
    AccessPreviewModel(
      id: json['id'] as String,
      number: (json['number'] as num).toInt(),
      parkingId: json['parkingId'] as String,
      employeeId: json['employeeId'] as String,
      vehicleId: json['vehicleId'] as String,
      spotId: json['spotId'] as String?,
      entryTime: DateTime.parse(json['entryTime'] as String),
      exitTime: json['exitTime'] == null
          ? null
          : DateTime.parse(json['exitTime'] as String),
      amount: (json['amount'] as num).toDouble(),
      status: $enumDecode(_$AccessStatusEnumMap, json['status']),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$AccessPreviewModelToJson(AccessPreviewModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'parkingId': instance.parkingId,
      'employeeId': instance.employeeId,
      'vehicleId': instance.vehicleId,
      'spotId': instance.spotId,
      'entryTime': instance.entryTime.toIso8601String(),
      'exitTime': instance.exitTime?.toIso8601String(),
      'amount': instance.amount,
      'status': _$AccessStatusEnumMap[instance.status]!,
      'notes': instance.notes,
    };

AccessForElementModel _$AccessForElementModelFromJson(
  Map<String, dynamic> json,
) => AccessForElementModel(
  id: json['id'] as String,
  number: (json['number'] as num).toInt(),
  employee: EmployeePreviewModel.fromJson(
    json['employee'] as Map<String, dynamic>,
  ),
  vehicle: VehiclePreviewModel.fromJson(
    json['vehicle'] as Map<String, dynamic>,
  ),
  entryTime: DateTime.parse(json['entryTime'] as String),
  exitTime: json['exitTime'] == null
      ? null
      : DateTime.parse(json['exitTime'] as String),
  amount: (json['amount'] as num).toDouble(),
  status: $enumDecode(_$AccessStatusEnumMap, json['status']),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$AccessForElementModelToJson(
  AccessForElementModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'number': instance.number,
  'employee': instance.employee,
  'vehicle': instance.vehicle,
  'entryTime': instance.entryTime.toIso8601String(),
  'exitTime': instance.exitTime?.toIso8601String(),
  'amount': instance.amount,
  'status': _$AccessStatusEnumMap[instance.status]!,
  'notes': instance.notes,
};

ExitRequestModel _$ExitRequestModelFromJson(Map<String, dynamic> json) =>
    ExitRequestModel(
      exitEmployeeId: json['exitEmployeeId'] as String,
      amount: (json['amount'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$ExitRequestModelToJson(ExitRequestModel instance) =>
    <String, dynamic>{
      'exitEmployeeId': instance.exitEmployeeId,
      'amount': instance.amount,
      'notes': instance.notes,
    };
