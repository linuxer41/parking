import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'parking_model.dart';
import 'employee_model.dart';
import 'vehicle_model.dart';
import 'element_model.dart';

part 'reservation_model.g.dart';

// Esquemas JSON adicionales
// No hay esquemas adicionales

@JsonSerializable()
class ReservationModel extends JsonConvertible<ReservationModel> {
  final String id;
  final int number;
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
  final String status;
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Getter para startTime
  DateTime get startTime => startDate;

  ReservationModel({
    required this.id,
    required this.number,
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
    required this.status,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) =>
      _$ReservationModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ReservationModelToJson(this);
}

@JsonSerializable()
class ReservationCreateModel extends JsonConvertible<ReservationCreateModel> {
  final String? ownerName;
  final String? ownerPhone;
  final String? vehicleType;
  final String? vehicleColor;
  final String parkingId;
  final String? ownerDocument;
  final String spotId;
  final String areaId;
  final String startDate; // Puede ser String o Date
  final double amount;
  final String vehiclePlate;
  final int durationHours;

  ReservationCreateModel({
    this.ownerName,
    this.ownerPhone,
    this.vehicleType,
    this.vehicleColor,
    required this.parkingId,
    this.ownerDocument,
    required this.spotId,
    required this.areaId,
    required this.startDate,
    required this.amount,
    required this.vehiclePlate,
    required this.durationHours,
  });

  factory ReservationCreateModel.fromJson(Map<String, dynamic> json) =>
      _$ReservationCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ReservationCreateModelToJson(this);
}

@JsonSerializable()
class ReservationUpdateModel extends JsonConvertible<ReservationUpdateModel> {
  final int? number;
  final String? employeeId;
  final String? vehicleId;
  final String? spotId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;
  final double? amount;

  ReservationUpdateModel({
    this.number,
    this.employeeId,
    this.vehicleId,
    this.spotId,
    this.startDate,
    this.endDate,
    this.status,
    this.amount,
  });

  factory ReservationUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$ReservationUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ReservationUpdateModelToJson(this);
}

@JsonSerializable()
class ReservationPreviewModel extends JsonConvertible<ReservationPreviewModel> {
  final String id;
  final int number;
  final String parkingId;
  final String employeeId;
  final String vehicleId;
  final String spotId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final double amount;

  ReservationPreviewModel({
    required this.id,
    required this.number,
    required this.parkingId,
    required this.employeeId,
    required this.vehicleId,
    required this.spotId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.amount,
  });

  factory ReservationPreviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReservationPreviewModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ReservationPreviewModelToJson(this);
}

@JsonSerializable()
class ReservationForElementModel extends JsonConvertible<ReservationForElementModel> {
  final String id;
  final int number;
  final EmployeePreviewModel employee;
  final VehiclePreviewModel vehicle;
  final DateTime startDate;
  final DateTime endDate;
  final double amount;

  ReservationForElementModel({
    required this.id,
    required this.number,
    required this.employee,
    required this.vehicle,
    required this.startDate,
    required this.endDate,
    required this.amount,
  });

  factory ReservationForElementModel.fromJson(Map<String, dynamic> json) =>
      _$ReservationForElementModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ReservationForElementModelToJson(this);
}
