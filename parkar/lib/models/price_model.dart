
import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'parking_model.dart';

part 'price_model.g.dart';

@JsonSerializable()
class PriceModel extends JsonConvertible<PriceModel> {
  final String id;
  final String parkingId;
  final ParkingModel parking;
  final String vehicleTypeId;
  final String timeRangeId;
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;

  PriceModel({
    required this.id,
    required this.parkingId,
    required this.parking,
    required this.vehicleTypeId,
    required this.timeRangeId,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PriceModel.fromJson(Map<String, dynamic> json) =>
      _$PriceModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PriceModelToJson(this);
}

@JsonSerializable()
class PriceCreateModel extends JsonConvertible<PriceCreateModel> {
  final String parkingId;
  final String vehicleTypeId;
  final String timeRangeId;
  final double amount;

  PriceCreateModel({
    required this.parkingId,
    required this.vehicleTypeId,
    required this.timeRangeId,
    required this.amount,
  });

  factory PriceCreateModel.fromJson(Map<String, dynamic> json) =>
      _$PriceCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PriceCreateModelToJson(this);
}

@JsonSerializable()
class PriceUpdateModel extends JsonConvertible<PriceUpdateModel> {
  final String vehicleTypeId;
  final String timeRangeId;
  final double amount;

  PriceUpdateModel({
    required this.vehicleTypeId,
    required this.timeRangeId,
    required this.amount,
  });

  factory PriceUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$PriceUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PriceUpdateModelToJson(this);
}


