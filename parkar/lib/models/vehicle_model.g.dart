// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleModel _$VehicleModelFromJson(Map<String, dynamic> json) => VehicleModel(
      id: json['id'] as String,
      parkingId: json['parkingId'] as String,
      parking: ParkingModel.fromJson(json['parking'] as Map<String, dynamic>),
      typeId: json['typeId'] as String,
      plate: json['plate'] as String,
      isSubscriber: json['isSubscriber'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
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
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

VehicleCreateModel _$VehicleCreateModelFromJson(Map<String, dynamic> json) =>
    VehicleCreateModel(
      parkingId: json['parkingId'] as String,
      typeId: json['typeId'] as String,
      plate: json['plate'] as String,
      isSubscriber: json['isSubscriber'] as bool,
    );

Map<String, dynamic> _$VehicleCreateModelToJson(VehicleCreateModel instance) =>
    <String, dynamic>{
      'parkingId': instance.parkingId,
      'typeId': instance.typeId,
      'plate': instance.plate,
      'isSubscriber': instance.isSubscriber,
    };

VehicleUpdateModel _$VehicleUpdateModelFromJson(Map<String, dynamic> json) =>
    VehicleUpdateModel(
      typeId: json['typeId'] as String,
      plate: json['plate'] as String,
      isSubscriber: json['isSubscriber'] as bool,
    );

Map<String, dynamic> _$VehicleUpdateModelToJson(VehicleUpdateModel instance) =>
    <String, dynamic>{
      'typeId': instance.typeId,
      'plate': instance.plate,
      'isSubscriber': instance.isSubscriber,
    };
