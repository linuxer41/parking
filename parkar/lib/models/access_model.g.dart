// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'access_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccessModel _$AccessModelFromJson(Map<String, dynamic> json) => AccessModel(
  id: json['id'] as String,
  number: (json['number'] as num).toInt(),
  parkingId: json['parkingId'] as String,
  areaId: json['areaId'] as String?,
  parking: ParkingPreviewModel.fromJson(
    json['parking'] as Map<String, dynamic>,
  ),
  entryEmployeeId: json['entryEmployeeId'] as String,
  entryEmployee: EmployeePreviewModel.fromJson(
    json['entryEmployee'] as Map<String, dynamic>,
  ),
  exitEmployeeId: json['exitEmployeeId'] as String?,
  exitEmployee: json['exitEmployee'] == null
      ? null
      : EmployeePreviewModel.fromJson(
          json['exitEmployee'] as Map<String, dynamic>,
        ),
  vehicleId: json['vehicleId'] as String,
  vehicle: VehiclePreviewModel.fromJson(
    json['vehicle'] as Map<String, dynamic>,
  ),
  spotId: json['spotId'] as String,
  spot: ElementPreviewModel.fromJson(json['spot'] as Map<String, dynamic>),
  entryTime: DateTime.parse(json['entryTime'] as String),
  exitTime: json['exitTime'] == null
      ? null
      : DateTime.parse(json['exitTime'] as String),
  amount: (json['amount'] as num?)?.toDouble(),
  status: json['status'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
);

Map<String, dynamic> _$AccessModelToJson(AccessModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'parkingId': instance.parkingId,
      'areaId': instance.areaId,
      'parking': instance.parking,
      'entryEmployeeId': instance.entryEmployeeId,
      'entryEmployee': instance.entryEmployee,
      'exitEmployeeId': instance.exitEmployeeId,
      'exitEmployee': instance.exitEmployee,
      'vehicleId': instance.vehicleId,
      'vehicle': instance.vehicle,
      'spotId': instance.spotId,
      'spot': instance.spot,
      'entryTime': instance.entryTime.toIso8601String(),
      'exitTime': instance.exitTime?.toIso8601String(),
      'amount': instance.amount,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

AccessCreateModel _$AccessCreateModelFromJson(Map<String, dynamic> json) =>
    AccessCreateModel(
      parkingId: json['parkingId'] as String,
      spotId: json['spotId'] as String,
      ownerName: json['ownerName'] as String?,
      ownerDocument: json['ownerDocument'] as String?,
      ownerPhone: json['ownerPhone'] as String?,
      vehiclePlate: json['vehiclePlate'] as String,
      vehicleType: json['vehicleType'] as String?,
      vehicleColor: json['vehicleColor'] as String?,
      areaId: json['areaId'] as String,
    );

Map<String, dynamic> _$AccessCreateModelToJson(AccessCreateModel instance) =>
    <String, dynamic>{
      'parkingId': instance.parkingId,
      'spotId': instance.spotId,
      'ownerName': instance.ownerName,
      'ownerDocument': instance.ownerDocument,
      'ownerPhone': instance.ownerPhone,
      'vehiclePlate': instance.vehiclePlate,
      'vehicleType': instance.vehicleType,
      'vehicleColor': instance.vehicleColor,
      'areaId': instance.areaId,
    };

AccessUpdateModel _$AccessUpdateModelFromJson(Map<String, dynamic> json) =>
    AccessUpdateModel(
      number: (json['number'] as num?)?.toInt(),
      vehicleId: json['vehicleId'] as String?,
      spotId: json['spotId'] as String?,
      exitTime: json['exitTime'] == null
          ? null
          : DateTime.parse(json['exitTime'] as String),
      exitEmployeeId: json['exitEmployeeId'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$AccessUpdateModelToJson(AccessUpdateModel instance) =>
    <String, dynamic>{
      'number': instance.number,
      'vehicleId': instance.vehicleId,
      'spotId': instance.spotId,
      'exitTime': instance.exitTime?.toIso8601String(),
      'exitEmployeeId': instance.exitEmployeeId,
      'amount': instance.amount,
      'status': instance.status,
    };

AccessPreviewModel _$AccessPreviewModelFromJson(Map<String, dynamic> json) =>
    AccessPreviewModel(
      id: json['id'] as String,
      number: json['number'] as String,
      entryTime: json['entryTime'] as String,
      exitTime: json['exitTime'] as String?,
      vehicleId: json['vehicleId'] as String,
      status: json['status'] as String,
      vehicle: VehiclePreviewModel.fromJson(
        json['vehicle'] as Map<String, dynamic>,
      ),
      parkingId: json['parkingId'] as String,
      areaId: json['areaId'] as String,
      spotId: json['spotId'] as String,
    );

Map<String, dynamic> _$AccessPreviewModelToJson(AccessPreviewModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'entryTime': instance.entryTime,
      'exitTime': instance.exitTime,
      'vehicleId': instance.vehicleId,
      'status': instance.status,
      'vehicle': instance.vehicle,
      'parkingId': instance.parkingId,
      'areaId': instance.areaId,
      'spotId': instance.spotId,
    };
