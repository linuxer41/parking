
import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'element_model.dart';
import 'parking_model.dart';
import 'employee_model.dart';
import 'vehicle_model.dart';

part 'subscription_model.g.dart';

// Enum for subscription periods
enum SubscriptionPeriod {
  @JsonValue('weekly')
  weekly,
  @JsonValue('monthly')
  monthly,
  @JsonValue('yearly')
  yearly,
}

@JsonSerializable()
class SubscriptionModel extends JsonConvertible<SubscriptionModel> {
  final String id;
  final String parkingId;
  final ParkingPreviewModel parking;
  final String employeeId;
  final EmployeePreviewModel employee;
  final String vehicleId;
  final VehiclePreviewModel vehicle;
  final String spotId;
  final ElementPreviewModel spot;
  final DateTime startDate;
  final DateTime endDate;
  final double amount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionModel({
    required this.id,
    required this.parkingId,
    required this.parking,
    required this.employeeId,
    required this.employee,
    required this.vehicleId,
    required this.vehicle,
    required this.spotId,
    required this.spot,
    required this.startDate,
    required this.endDate,
    required this.amount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubscriptionModelToJson(this);
}

@JsonSerializable()
class SubscriptionCreateModel extends JsonConvertible<SubscriptionCreateModel> {
  final String? ownerName;
  final String? ownerPhone;
  final String? vehicleType;
  final String? vehicleColor;
  final String parkingId;
  final String? ownerDocument;
  final String areaId;
  final String spotId;
  final String startDate; // Puede ser String o DateTime
  final double amount;
  final String vehiclePlate;
  final SubscriptionPeriod period; // Enum instead of String

  SubscriptionCreateModel({
    this.ownerName,
    this.ownerPhone,
    this.vehicleType,
    this.vehicleColor,
    required this.parkingId,
    this.ownerDocument,
    required this.areaId,
    required this.spotId,
    required this.startDate,
    required this.amount,
    required this.vehiclePlate,
    required this.period,
  });

  factory SubscriptionCreateModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubscriptionCreateModelToJson(this);
}

@JsonSerializable()
class SubscriptionUpdateModel extends JsonConvertible<SubscriptionUpdateModel> {
  final DateTime? startDate;
  final DateTime? endDate;
  final double? amount;

  SubscriptionUpdateModel({
    this.startDate,
    this.endDate,
    this.amount,
  });

  factory SubscriptionUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubscriptionUpdateModelToJson(this);
}

@JsonSerializable()
class SubscriptionPreviewModel extends JsonConvertible<SubscriptionPreviewModel> {
  final String id;
  final ParkingPreviewModel parking;
  final EmployeePreviewModel employee;
  final VehiclePreviewModel vehicle;
  final DateTime startDate;
  final DateTime endDate;
  final double amount;

  SubscriptionPreviewModel({
    required this.id,
    required this.parking,
    required this.employee,
    required this.vehicle,
    required this.startDate,
    required this.endDate,
    required this.amount,
  });

  factory SubscriptionPreviewModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPreviewModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubscriptionPreviewModelToJson(this);
}

@JsonSerializable()
class SubscriptionForElementModel extends JsonConvertible<SubscriptionForElementModel> {
  final String id;
  final EmployeePreviewModel employee;
  final VehiclePreviewModel vehicle;
  final DateTime startDate;
  final DateTime endDate;
  final double amount;

  SubscriptionForElementModel({
    required this.id,
    required this.employee,
    required this.vehicle,
    required this.startDate,
    required this.endDate,
    required this.amount,
  });

  factory SubscriptionForElementModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionForElementModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubscriptionForElementModelToJson(this);
}


