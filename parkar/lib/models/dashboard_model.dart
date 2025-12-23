import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';

part 'dashboard_model.g.dart';

/// Base stats model for dashboard data
@JsonSerializable()
class DashboardStats extends JsonConvertible<DashboardStats> {
  final int vehiclesAttended;
  final double collection;

  DashboardStats({
    required this.vehiclesAttended,
    required this.collection,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DashboardStatsToJson(this);
}

/// Today's stats including current vehicles in parking
@JsonSerializable()
class TodayStats extends JsonConvertible<TodayStats> {
  final int vehiclesAttended;
  final double collection;
  final int currentVehiclesInParking;

  TodayStats({
    required this.vehiclesAttended,
    required this.collection,
    required this.currentVehiclesInParking,
  });

  factory TodayStats.fromJson(Map<String, dynamic> json) =>
      _$TodayStatsFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TodayStatsToJson(this);
}

/// Main dashboard model
@JsonSerializable()
class DashboardModel extends JsonConvertible<DashboardModel> {
  final TodayStats today;
  final DashboardStats weekly;
  final DashboardStats monthly;

  DashboardModel({
    required this.today,
    required this.weekly,
    required this.monthly,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DashboardModelToJson(this);
}