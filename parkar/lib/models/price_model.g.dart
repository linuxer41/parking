// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PriceModel _$PriceModelFromJson(Map<String, dynamic> json) => PriceModel(
      id: json['id'] as String,
      parkingId: json['parkingId'] as String,
      parking: ParkingModel.fromJson(json['parking'] as Map<String, dynamic>),
      vehicleTypeId: json['vehicleTypeId'] as String,
      timeRangeId: json['timeRangeId'] as String,
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PriceModelToJson(PriceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parkingId': instance.parkingId,
      'parking': instance.parking,
      'vehicleTypeId': instance.vehicleTypeId,
      'timeRangeId': instance.timeRangeId,
      'amount': instance.amount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

PriceCreateModel _$PriceCreateModelFromJson(Map<String, dynamic> json) =>
    PriceCreateModel(
      parkingId: json['parkingId'] as String,
      vehicleTypeId: json['vehicleTypeId'] as String,
      timeRangeId: json['timeRangeId'] as String,
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$PriceCreateModelToJson(PriceCreateModel instance) =>
    <String, dynamic>{
      'parkingId': instance.parkingId,
      'vehicleTypeId': instance.vehicleTypeId,
      'timeRangeId': instance.timeRangeId,
      'amount': instance.amount,
    };

PriceUpdateModel _$PriceUpdateModelFromJson(Map<String, dynamic> json) =>
    PriceUpdateModel(
      vehicleTypeId: json['vehicleTypeId'] as String,
      timeRangeId: json['timeRangeId'] as String,
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$PriceUpdateModelToJson(PriceUpdateModel instance) =>
    <String, dynamic>{
      'vehicleTypeId': instance.vehicleTypeId,
      'timeRangeId': instance.timeRangeId,
      'amount': instance.amount,
    };
