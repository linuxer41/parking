// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardStats _$DashboardStatsFromJson(Map<String, dynamic> json) =>
    DashboardStats(
      vehiclesAttended: (json['vehiclesAttended'] as num).toInt(),
      collection: (json['collection'] as num).toDouble(),
    );

Map<String, dynamic> _$DashboardStatsToJson(DashboardStats instance) =>
    <String, dynamic>{
      'vehiclesAttended': instance.vehiclesAttended,
      'collection': instance.collection,
    };

TodayStats _$TodayStatsFromJson(Map<String, dynamic> json) => TodayStats(
  vehiclesAttended: (json['vehiclesAttended'] as num).toInt(),
  collection: (json['collection'] as num).toDouble(),
  currentVehiclesInParking: (json['currentVehiclesInParking'] as num).toInt(),
);

Map<String, dynamic> _$TodayStatsToJson(TodayStats instance) =>
    <String, dynamic>{
      'vehiclesAttended': instance.vehiclesAttended,
      'collection': instance.collection,
      'currentVehiclesInParking': instance.currentVehiclesInParking,
    };

DashboardModel _$DashboardModelFromJson(Map<String, dynamic> json) =>
    DashboardModel(
      today: TodayStats.fromJson(json['today'] as Map<String, dynamic>),
      weekly: DashboardStats.fromJson(json['weekly'] as Map<String, dynamic>),
      monthly: DashboardStats.fromJson(json['monthly'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DashboardModelToJson(DashboardModel instance) =>
    <String, dynamic>{
      'today': instance.today,
      'weekly': instance.weekly,
      'monthly': instance.monthly,
    };
