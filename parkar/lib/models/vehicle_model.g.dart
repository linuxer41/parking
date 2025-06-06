// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleModel _$VehicleModelFromJson(Map<String, dynamic> json) => VehicleModel(
      id: json['id'] as String,
      parkingId: json['parkingId'] as String,
      parking: json['parking'] == null
          ? null
          : ParkingModel.fromJson(json['parking'] as Map<String, dynamic>),
      typeId: json['typeId'] as String?,
      plate: json['plate'] as String,
      isSubscriber: json['isSubscriber'] as bool?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      type: json['type'] as String?,
      entryTime: json['entryTime'] == null
          ? null
          : DateTime.parse(json['entryTime'] as String),
      exitTime: json['exitTime'] == null
          ? null
          : DateTime.parse(json['exitTime'] as String),
      spotNumber: json['spotNumber'] as String?,
      fee: (json['fee'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$VehicleModelToJson(VehicleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parkingId': instance.parkingId,
      'parking': instance.parking,
      'typeId': instance.typeId,
      'plate': instance.plate,
      'isSubscriber': instance.isSubscriber,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'type': instance.type,
      'entryTime': instance.entryTime?.toIso8601String(),
      'exitTime': instance.exitTime?.toIso8601String(),
      'spotNumber': instance.spotNumber,
      'fee': instance.fee,
    };

VehicleCreateModel _$VehicleCreateModelFromJson(Map<String, dynamic> json) =>
    VehicleCreateModel(
      parkingId: json['parkingId'] as String,
      typeId: json['typeId'] as String,
      plate: json['plate'] as String,
      isSubscriber: json['isSubscriber'] as bool,
      spotNumber: json['spotNumber'] as String?,
      fee: (json['fee'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$VehicleCreateModelToJson(VehicleCreateModel instance) =>
    <String, dynamic>{
      'parkingId': instance.parkingId,
      'typeId': instance.typeId,
      'plate': instance.plate,
      'isSubscriber': instance.isSubscriber,
      'spotNumber': instance.spotNumber,
      'fee': instance.fee,
    };

VehicleUpdateModel _$VehicleUpdateModelFromJson(Map<String, dynamic> json) =>
    VehicleUpdateModel(
      typeId: json['typeId'] as String?,
      plate: json['plate'] as String?,
      isSubscriber: json['isSubscriber'] as bool?,
      exitTime: json['exitTime'] == null
          ? null
          : DateTime.parse(json['exitTime'] as String),
      fee: (json['fee'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$VehicleUpdateModelToJson(VehicleUpdateModel instance) =>
    <String, dynamic>{
      'typeId': instance.typeId,
      'plate': instance.plate,
      'isSubscriber': instance.isSubscriber,
      'exitTime': instance.exitTime?.toIso8601String(),
      'fee': instance.fee,
    };
