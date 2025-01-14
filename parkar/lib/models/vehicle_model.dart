
import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'parking_model.dart';

part 'vehicle_model.g.dart';

@JsonSerializable()
class VehicleModel extends JsonConvertible<VehicleModel> {
  final String id;
  final String parkingId;
  final ParkingModel parking;
  final String typeId;
  final String plate;
  final bool isSubscriber;
  final DateTime createdAt;
  final DateTime updatedAt;

  VehicleModel({
    required this.id,
    required this.parkingId,
    required this.parking,
    required this.typeId,
    required this.plate,
    required this.isSubscriber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VehicleModelToJson(this);
}

@JsonSerializable()
class VehicleCreateModel extends JsonConvertible<VehicleCreateModel> {
  final String parkingId;
  final String typeId;
  final String plate;
  final bool isSubscriber;

  VehicleCreateModel({
    required this.parkingId,
    required this.typeId,
    required this.plate,
    required this.isSubscriber,
  });

  factory VehicleCreateModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VehicleCreateModelToJson(this);
}

@JsonSerializable()
class VehicleUpdateModel extends JsonConvertible<VehicleUpdateModel> {
  final String typeId;
  final String plate;
  final bool isSubscriber;

  VehicleUpdateModel({
    required this.typeId,
    required this.plate,
    required this.isSubscriber,
  });

  factory VehicleUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VehicleUpdateModelToJson(this);
}


