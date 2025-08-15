import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'parking_model.dart';

part 'vehicle_model.g.dart';

@JsonSerializable()
class SpotCheckModel extends JsonConvertible<SpotCheckModel> {
  final String id;
  final String spotId;
  final String spotName;
  final String startDate;
  final String? endDate;
  final double amount;

  SpotCheckModel({
    required this.id,
    required this.spotId,
    required this.spotName,
    required this.startDate,
    this.endDate,
    required this.amount,
  });

  factory SpotCheckModel.fromJson(Map<String, dynamic> json) =>
      _$SpotCheckModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SpotCheckModelToJson(this);
}

@JsonSerializable()
class VehicleModel extends JsonConvertible<VehicleModel> {
  final String id;
  final String parkingId;
  final ParkingModel? parking;
  final String? type;
  final String plate;
  final String? color;
  final bool? isSubscriber;
  final String? ownerName;
  final String? ownerDocument;
  final String? ownerPhone;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? entryTime;
  final DateTime? exitTime;
  final String? spotNumber;
  final double? fee;
  final SpotCheckModel? subscription;
  final SpotCheckModel? reservation;
  final SpotCheckModel? access;

  // Getters adicionales
  String get licensePlate => plate;
  String get vehicleType => type ?? '';

  VehicleModel({
    required this.id,
    required this.parkingId,
    this.parking,
    this.type,
    this.color,
    required this.plate,
    this.isSubscriber,
    this.ownerName,
    this.ownerDocument,
    this.ownerPhone,
    required this.createdAt,
    this.updatedAt,
    this.entryTime,
    this.exitTime,
    this.spotNumber,
    this.fee,
    this.subscription,
    this.reservation,
    this.access,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VehicleModelToJson(this);
}

@JsonSerializable()
class VehicleCreateModel extends JsonConvertible<VehicleCreateModel> {
  final String parkingId;
  final String? type;
  final String? color;
  final String plate;
  final String? ownerName;
  final String? ownerDocument;
  final String? ownerPhone; 
  final String? spotNumber;
  final double? fee;

  VehicleCreateModel({
    required this.parkingId,
    this.type,
    this.color,
    required this.plate,
    this.ownerName,
    this.ownerDocument,
    this.ownerPhone,
    this.spotNumber,
    this.fee,
  });

  factory VehicleCreateModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VehicleCreateModelToJson(this);
}

@JsonSerializable()
class VehicleUpdateModel extends JsonConvertible<VehicleUpdateModel> {
  final String? type;
  final String? color;
  final String? plate;
  final String? ownerName;
  final String? ownerDocument;
  final String? ownerPhone;
  final DateTime? exitTime;
  final double? fee;

  VehicleUpdateModel({
    this.type,
    this.color,
    this.plate,
    this.ownerName,
    this.ownerDocument,
    this.ownerPhone,
    this.exitTime,
    this.fee,
  });

  factory VehicleUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VehicleUpdateModelToJson(this);
}

@JsonSerializable()
class VehiclePreviewModel extends JsonConvertible<VehiclePreviewModel> {
  final String id;
  final String plate;
  final String type;
  final String? color;
  final String? ownerName;
  final String? ownerDocument;
  final String? ownerPhone;

  VehiclePreviewModel({
    required this.id,
    required this.plate,
    required this.type,
    this.color,
    this.ownerName,
    this.ownerDocument,
    this.ownerPhone,
  });

  factory VehiclePreviewModel.fromJson(Map<String, dynamic> json) =>
      _$VehiclePreviewModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VehiclePreviewModelToJson(this);
}

@JsonSerializable()
class VehicleDetailsRequestModel extends JsonConvertible<VehicleDetailsRequestModel> {
  final String vehiclePlate;
  final String? vehicleType;
  final String? vehicleColor;
  final String? ownerDocument;
  final String? ownerName;
  final String? ownerPhone;

  VehicleDetailsRequestModel({
    required this.vehiclePlate,
    this.vehicleType,
    this.vehicleColor,
    this.ownerDocument,
    this.ownerName,
    this.ownerPhone,
  });

  factory VehicleDetailsRequestModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleDetailsRequestModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VehicleDetailsRequestModelToJson(this);
}
