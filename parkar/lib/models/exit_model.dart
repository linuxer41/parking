import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'parking_model.dart';
import 'entry_model.dart';
import 'employee_model.dart';

part 'exit_model.g.dart';

@JsonSerializable()
class ExitModel extends JsonConvertible<ExitModel> {
  final String id;
  final int number;
  final String parkingId;
  final ParkingModel parking;
  final String entryId;
  final EntryModel entry;
  final String employeeId;
  final EmployeeModel employee;
  final DateTime dateTime;
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Getters adicionales
  DateTime get exitTime => dateTime;
  int get duration => 0; // Placeholder
  String get paymentMethod => 'Efectivo'; // Placeholder

  ExitModel({
    required this.id,
    required this.number,
    required this.parkingId,
    required this.parking,
    required this.entryId,
    required this.entry,
    required this.employeeId,
    required this.employee,
    required this.dateTime,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExitModel.fromJson(Map<String, dynamic> json) =>
      _$ExitModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ExitModelToJson(this);
}

@JsonSerializable()
class ExitCreateModel extends JsonConvertible<ExitCreateModel> {
  final int number;
  final String parkingId;
  final String entryId;
  final String employeeId;
  final DateTime dateTime;
  final double amount;

  ExitCreateModel({
    required this.number,
    required this.parkingId,
    required this.entryId,
    required this.employeeId,
    required this.dateTime,
    required this.amount,
  });

  factory ExitCreateModel.fromJson(Map<String, dynamic> json) =>
      _$ExitCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ExitCreateModelToJson(this);
}

@JsonSerializable()
class ExitUpdateModel extends JsonConvertible<ExitUpdateModel> {
  final int? number;
  final String? employeeId;
  final DateTime? dateTime;
  final double? amount;

  ExitUpdateModel({
    this.number,
    this.employeeId,
    this.dateTime,
    this.amount,
  });

  factory ExitUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$ExitUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ExitUpdateModelToJson(this);
}
