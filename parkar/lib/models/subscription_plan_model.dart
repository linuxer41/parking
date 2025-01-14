
import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'parking_model.dart';

part 'subscription_plan_model.g.dart';

@JsonSerializable()
class SubscriptionPlanModel extends JsonConvertible<SubscriptionPlanModel> {
  final String id;
  final String name;
  final String? description;
  final double price;
  final int duration;
  final String parkingId;
  final ParkingModel parking;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionPlanModel({
    required this.id,
    required this.name,
     this.description,
    required this.price,
    required this.duration,
    required this.parkingId,
    required this.parking,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPlanModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubscriptionPlanModelToJson(this);
}

@JsonSerializable()
class SubscriptionPlanCreateModel extends JsonConvertible<SubscriptionPlanCreateModel> {
  final String name;
  final String? description;
  final double price;
  final int duration;
  final String parkingId;

  SubscriptionPlanCreateModel({
    required this.name,
     this.description,
    required this.price,
    required this.duration,
    required this.parkingId,
  });

  factory SubscriptionPlanCreateModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPlanCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubscriptionPlanCreateModelToJson(this);
}

@JsonSerializable()
class SubscriptionPlanUpdateModel extends JsonConvertible<SubscriptionPlanUpdateModel> {
  final String name;
  final String? description;
  final double price;
  final int duration;

  SubscriptionPlanUpdateModel({
    required this.name,
     this.description,
    required this.price,
    required this.duration,
  });

  factory SubscriptionPlanUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPlanUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubscriptionPlanUpdateModelToJson(this);
}


