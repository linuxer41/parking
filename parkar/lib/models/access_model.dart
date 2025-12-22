import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'parking_model.dart';
import 'employee_model.dart';
import 'vehicle_model.dart';

part 'access_model.g.dart';

// Enum para estados de acceso
enum AccessStatus {
  @JsonValue('valid')
  valid,
  @JsonValue('cancelled')
  cancelled,
}

@JsonSerializable()
class AccessModel extends JsonConvertible<AccessModel> {
  final String id;
  final int number;
  final ParkingPreviewModel parking;
  final EmployeePreviewModel employee;
  final VehiclePreviewModel vehicle;
  final DateTime entryTime;
  final DateTime? exitTime;
  final EmployeePreviewModel? exitEmployee;
  final SpotPreviewModel? spot;
  final double amount;
  final AccessStatus status;
  final String? notes;

  AccessModel({
    required this.id,
    required this.number,
    required this.parking,
    required this.employee,
    required this.vehicle,
    required this.entryTime,
    this.spot,
    this.exitTime,
    this.exitEmployee,
    required this.amount,
    required this.status,
    this.notes,
  });

  @override
  Map<String, dynamic> toJson() => _$AccessModelToJson(this);

  factory AccessModel.fromJson(Map<String, dynamic> json) =>
      _$AccessModelFromJson(json);
}

@JsonSerializable()
class AccessCreateModel extends JsonConvertible<AccessCreateModel> {
  final String vehiclePlate;
  final String? vehicleType;
  final String? vehicleColor;
  final String? ownerName;
  final String? ownerDocument;
  final String? ownerPhone;
  final String? spotId;
  final String? notes;

  AccessCreateModel({
    required this.vehiclePlate,
    this.vehicleType,
    this.vehicleColor,
    this.ownerName,
    this.ownerDocument,
    this.ownerPhone,
    this.spotId,
    this.notes,
  });

  factory AccessCreateModel.fromJson(Map<String, dynamic> json) =>
      _$AccessCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AccessCreateModelToJson(this);
}

@JsonSerializable()
class AccessUpdateModel extends JsonConvertible<AccessUpdateModel> {
  final String? spotId;
  final DateTime? exitTime;
  final String? exitEmployeeId;
  final double? amount;
  final AccessStatus? status;
  final String? notes;

  AccessUpdateModel({
    this.spotId,
    this.exitTime,
    this.exitEmployeeId,
    this.amount,
    this.status,
    this.notes,
  });

  factory AccessUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$AccessUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AccessUpdateModelToJson(this);
}

@JsonSerializable()
class AccessPreviewModel extends JsonConvertible<AccessPreviewModel> {
  final String id;
  final int number;
  final String parkingId;
  final String employeeId;
  final String vehicleId;
  final String? spotId;
  final DateTime entryTime;
  final DateTime? exitTime;
  final double amount;
  final AccessStatus status;
  final String? notes;

  AccessPreviewModel({
    required this.id,
    required this.number,
    required this.parkingId,
    required this.employeeId,
    required this.vehicleId,
    this.spotId,
    required this.entryTime,
    this.exitTime,
    required this.amount,
    required this.status,
    this.notes,
  });

  factory AccessPreviewModel.fromJson(Map<String, dynamic> json) =>
      _$AccessPreviewModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AccessPreviewModelToJson(this);
}

@JsonSerializable()
class AccessForElementModel extends JsonConvertible<AccessForElementModel> {
  final String id;
  final int number;
  final EmployeePreviewModel employee;
  final VehiclePreviewModel vehicle;
  final DateTime entryTime;
  final DateTime? exitTime;
  final double amount;
  final AccessStatus status;
  final String? notes;

  AccessForElementModel({
    required this.id,
    required this.number,
    required this.employee,
    required this.vehicle,
    required this.entryTime,
    this.exitTime,
    required this.amount,
    required this.status,
    this.notes,
  });

  factory AccessForElementModel.fromJson(Map<String, dynamic> json) =>
      _$AccessForElementModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AccessForElementModelToJson(this);
}

@JsonSerializable()
class ExitRequestModel extends JsonConvertible<ExitRequestModel> {
  final String exitEmployeeId;
  final double? amount;
  final String? notes;

  ExitRequestModel({
    required this.exitEmployeeId,
    this.amount,
    this.notes,
  });

  factory ExitRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ExitRequestModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ExitRequestModelToJson(this);
}