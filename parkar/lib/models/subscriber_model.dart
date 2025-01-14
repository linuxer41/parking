
import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'parking_model.dart';
import 'employee_model.dart';
import 'vehicle_model.dart';
import 'subscription_plan_model.dart';

part 'subscriber_model.g.dart';

@JsonSerializable()
class SubscriberModel extends JsonConvertible<SubscriberModel> {
  final String id;
  final String parkingId;
  final ParkingModel parking;
  final String employeeId;
  final EmployeeModel employee;
  final String vehicleId;
  final VehicleModel vehicle;
  final String planId;
  final SubscriptionPlanModel plan;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriberModel({
    required this.id,
    required this.parkingId,
    required this.parking,
    required this.employeeId,
    required this.employee,
    required this.vehicleId,
    required this.vehicle,
    required this.planId,
    required this.plan,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriberModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriberModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubscriberModelToJson(this);
}

@JsonSerializable()
class SubscriberCreateModel extends JsonConvertible<SubscriberCreateModel> {
  final String parkingId;
  final String employeeId;
  final String vehicleId;
  final String planId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  SubscriberCreateModel({
    required this.parkingId,
    required this.employeeId,
    required this.vehicleId,
    required this.planId,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory SubscriberCreateModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriberCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubscriberCreateModelToJson(this);
}

@JsonSerializable()
class SubscriberUpdateModel extends JsonConvertible<SubscriberUpdateModel> {
  final String planId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  SubscriberUpdateModel({
    required this.planId,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory SubscriberUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriberUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubscriberUpdateModelToJson(this);
}


