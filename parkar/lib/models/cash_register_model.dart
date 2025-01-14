
import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'parking_model.dart';
import 'employee_model.dart';

part 'cash_register_model.g.dart';

@JsonSerializable()
class CashRegisterModel extends JsonConvertible<CashRegisterModel> {
  final String id;
  final int number;
  final String parkingId;
  final ParkingModel parking;
  final String employeeId;
  final EmployeeModel employee;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  CashRegisterModel({
    required this.id,
    required this.number,
    required this.parkingId,
    required this.parking,
    required this.employeeId,
    required this.employee,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CashRegisterModel.fromJson(Map<String, dynamic> json) =>
      _$CashRegisterModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CashRegisterModelToJson(this);
}

@JsonSerializable()
class CashRegisterCreateModel extends JsonConvertible<CashRegisterCreateModel> {
  final int number;
  final String parkingId;
  final String employeeId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  CashRegisterCreateModel({
    required this.number,
    required this.parkingId,
    required this.employeeId,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory CashRegisterCreateModel.fromJson(Map<String, dynamic> json) =>
      _$CashRegisterCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CashRegisterCreateModelToJson(this);
}

@JsonSerializable()
class CashRegisterUpdateModel extends JsonConvertible<CashRegisterUpdateModel> {
  final int number;
  final String employeeId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  CashRegisterUpdateModel({
    required this.number,
    required this.employeeId,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory CashRegisterUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$CashRegisterUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CashRegisterUpdateModelToJson(this);
}


