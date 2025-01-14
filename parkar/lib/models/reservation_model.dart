
import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'parking_model.dart';
import 'employee_model.dart';
import 'vehicle_model.dart';
import 'spot_model.dart';

part 'reservation_model.g.dart';

@JsonSerializable()
class ReservationModel extends JsonConvertible<ReservationModel> {
  final String id;
  final int number;
  final String parkingId;
  final ParkingModel parking;
  final String employeeId;
  final EmployeeModel employee;
  final String vehicleId;
  final VehicleModel vehicle;
  final String spotId;
  final SpotModel spot;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;

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
  final int number;
  final String parkingId;
  final String employeeId;
  final String vehicleId;
  final String spotId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final double amount;

  ReservationCreateModel({
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

  factory ReservationCreateModel.fromJson(Map<String, dynamic> json) =>
      _$ReservationCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ReservationCreateModelToJson(this);
}

@JsonSerializable()
class ReservationUpdateModel extends JsonConvertible<ReservationUpdateModel> {
  final int number;
  final String employeeId;
  final String vehicleId;
  final String spotId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final double amount;

  ReservationUpdateModel({
    required this.number,
    required this.employeeId,
    required this.vehicleId,
    required this.spotId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.amount,
  });

  factory ReservationUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$ReservationUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ReservationUpdateModelToJson(this);
}


