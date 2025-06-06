import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'parking_model.dart';
import 'employee_model.dart';
import 'vehicle_model.dart';
import 'level_model.dart';

part 'entry_model.g.dart';

@JsonSerializable()
class EntryModel extends JsonConvertible<EntryModel> {
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
  final DateTime dateTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Getter para entryTime
  DateTime get entryTime => dateTime;

  EntryModel({
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
    required this.dateTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EntryModel.fromJson(Map<String, dynamic> json) =>
      _$EntryModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EntryModelToJson(this);
}

@JsonSerializable()
class EntryCreateModel extends JsonConvertible<EntryCreateModel> {
  final int number;
  final String parkingId;
  final String employeeId;
  final String vehicleId;
  final String spotId;
  final DateTime dateTime;

  EntryCreateModel({
    required this.number,
    required this.parkingId,
    required this.employeeId,
    required this.vehicleId,
    required this.spotId,
    required this.dateTime,
  });

  factory EntryCreateModel.fromJson(Map<String, dynamic> json) =>
      _$EntryCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EntryCreateModelToJson(this);
}

@JsonSerializable()
class EntryUpdateModel extends JsonConvertible<EntryUpdateModel> {
  final int? number;
  final String? employeeId;
  final String? vehicleId;
  final String? spotId;
  final DateTime? dateTime;

  EntryUpdateModel({
    this.number,
    this.employeeId,
    this.vehicleId,
    this.spotId,
    this.dateTime,
  });

  factory EntryUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$EntryUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EntryUpdateModelToJson(this);
}
