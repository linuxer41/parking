// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpotCheckModel _$SpotCheckModelFromJson(Map<String, dynamic> json) =>
    SpotCheckModel(
      id: json['id'] as String,
      spotId: json['spotId'] as String,
      spotName: json['spotName'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String?,
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$SpotCheckModelToJson(SpotCheckModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'spotId': instance.spotId,
      'spotName': instance.spotName,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'amount': instance.amount,
    };

VehicleModel _$VehicleModelFromJson(Map<String, dynamic> json) => VehicleModel(
  id: json['id'] as String,
  parkingId: json['parkingId'] as String,
  parking: json['parking'] == null
      ? null
      : ParkingModelDetailed.fromJson(json['parking'] as Map<String, dynamic>),
  type: json['type'] as String?,
  color: json['color'] as String?,
  plate: json['plate'] as String,
  isSubscriber: json['isSubscriber'] as bool?,
  ownerName: json['ownerName'] as String?,
  ownerDocument: json['ownerDocument'] as String?,
  ownerPhone: json['ownerPhone'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  entryTime: json['entryTime'] == null
      ? null
      : DateTime.parse(json['entryTime'] as String),
  exitTime: json['exitTime'] == null
      ? null
      : DateTime.parse(json['exitTime'] as String),
  spotNumber: json['spotNumber'] as String?,
  fee: (json['fee'] as num?)?.toDouble(),
  subscription: json['subscription'] == null
      ? null
      : SpotCheckModel.fromJson(json['subscription'] as Map<String, dynamic>),
  reservation: json['reservation'] == null
      ? null
      : SpotCheckModel.fromJson(json['reservation'] as Map<String, dynamic>),
  access: json['access'] == null
      ? null
      : SpotCheckModel.fromJson(json['access'] as Map<String, dynamic>),
);

Map<String, dynamic> _$VehicleModelToJson(VehicleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parkingId': instance.parkingId,
      'parking': instance.parking,
      'type': instance.type,
      'plate': instance.plate,
      'color': instance.color,
      'isSubscriber': instance.isSubscriber,
      'ownerName': instance.ownerName,
      'ownerDocument': instance.ownerDocument,
      'ownerPhone': instance.ownerPhone,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'entryTime': instance.entryTime?.toIso8601String(),
      'exitTime': instance.exitTime?.toIso8601String(),
      'spotNumber': instance.spotNumber,
      'fee': instance.fee,
      'subscription': instance.subscription,
      'reservation': instance.reservation,
      'access': instance.access,
    };

VehicleCreateModel _$VehicleCreateModelFromJson(Map<String, dynamic> json) =>
    VehicleCreateModel(
      parkingId: json['parkingId'] as String,
      type: json['type'] as String?,
      color: json['color'] as String?,
      plate: json['plate'] as String,
      ownerName: json['ownerName'] as String?,
      ownerDocument: json['ownerDocument'] as String?,
      ownerPhone: json['ownerPhone'] as String?,
      spotNumber: json['spotNumber'] as String?,
      fee: (json['fee'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$VehicleCreateModelToJson(VehicleCreateModel instance) =>
    <String, dynamic>{
      'parkingId': instance.parkingId,
      'type': instance.type,
      'color': instance.color,
      'plate': instance.plate,
      'ownerName': instance.ownerName,
      'ownerDocument': instance.ownerDocument,
      'ownerPhone': instance.ownerPhone,
      'spotNumber': instance.spotNumber,
      'fee': instance.fee,
    };

VehicleUpdateModel _$VehicleUpdateModelFromJson(Map<String, dynamic> json) =>
    VehicleUpdateModel(
      type: json['type'] as String?,
      color: json['color'] as String?,
      plate: json['plate'] as String?,
      ownerName: json['ownerName'] as String?,
      ownerDocument: json['ownerDocument'] as String?,
      ownerPhone: json['ownerPhone'] as String?,
      exitTime: json['exitTime'] == null
          ? null
          : DateTime.parse(json['exitTime'] as String),
      fee: (json['fee'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$VehicleUpdateModelToJson(VehicleUpdateModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'color': instance.color,
      'plate': instance.plate,
      'ownerName': instance.ownerName,
      'ownerDocument': instance.ownerDocument,
      'ownerPhone': instance.ownerPhone,
      'exitTime': instance.exitTime?.toIso8601String(),
      'fee': instance.fee,
    };

VehiclePreviewModel _$VehiclePreviewModelFromJson(Map<String, dynamic> json) =>
    VehiclePreviewModel(
      id: json['id'] as String,
      plate: json['plate'] as String,
      type: json['type'] as String,
      color: json['color'] as String?,
      ownerName: json['ownerName'] as String?,
      ownerDocument: json['ownerDocument'] as String?,
      ownerPhone: json['ownerPhone'] as String?,
    );

Map<String, dynamic> _$VehiclePreviewModelToJson(
  VehiclePreviewModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'plate': instance.plate,
  'type': instance.type,
  'color': instance.color,
  'ownerName': instance.ownerName,
  'ownerDocument': instance.ownerDocument,
  'ownerPhone': instance.ownerPhone,
};

VehicleDetailsRequestModel _$VehicleDetailsRequestModelFromJson(
  Map<String, dynamic> json,
) => VehicleDetailsRequestModel(
  vehiclePlate: json['vehiclePlate'] as String,
  vehicleType: json['vehicleType'] as String?,
  vehicleColor: json['vehicleColor'] as String?,
  ownerDocument: json['ownerDocument'] as String?,
  ownerName: json['ownerName'] as String?,
  ownerPhone: json['ownerPhone'] as String?,
);

Map<String, dynamic> _$VehicleDetailsRequestModelToJson(
  VehicleDetailsRequestModel instance,
) => <String, dynamic>{
  'vehiclePlate': instance.vehiclePlate,
  'vehicleType': instance.vehicleType,
  'vehicleColor': instance.vehicleColor,
  'ownerDocument': instance.ownerDocument,
  'ownerName': instance.ownerName,
  'ownerPhone': instance.ownerPhone,
};
