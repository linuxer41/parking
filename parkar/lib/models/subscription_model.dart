import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'parking_model.dart';
import 'employee_model.dart';
import 'vehicle_model.dart';

part 'subscription_model.g.dart';

// Enum para estados de suscripción
enum SubscriptionStatus {
  @JsonValue('active')
  active,
  @JsonValue('suspended')
  suspended,
  @JsonValue('expired')
  expired,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('renewed')
  renewed,
}

// Enum para periodos de suscripción
enum SubscriptionPeriod {
  @JsonValue('weekly')
  weekly,
  @JsonValue('monthly')
  monthly,
  @JsonValue('yearly')
  yearly,
}

@JsonSerializable()
class SubscriptionModel extends JsonConvertible<SubscriptionModel> {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int number;
  final String parkingId;
  final ParkingPreviewModel parking;
  final String employeeId;
  final EmployeePreviewModel employee;
  final String vehicleId;
  final VehiclePreviewModel vehicle;
  final String? spotId;
  final DateTime startDate;
  final DateTime? endDate;
  final double amount;
  final SubscriptionStatus status;
  final SubscriptionPeriod period;
  final bool isActive;
  final String? parentId;
  final String? notes;

  SubscriptionModel({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.number,
    required this.parkingId,
    required this.parking,
    required this.employeeId,
    required this.employee,
    required this.vehicleId,
    required this.vehicle,
    this.spotId,
    required this.startDate,
    this.endDate,
    required this.amount,
    required this.status,
    required this.period,
    required this.isActive,
    this.parentId,
    this.notes,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubscriptionModelToJson(this);

  // Métodos de conveniencia
  bool get isActiveStatus => status == SubscriptionStatus.active;
  bool get isSuspended => status == SubscriptionStatus.suspended;
  bool get isExpired => status == SubscriptionStatus.expired;
  bool get isCancelled => status == SubscriptionStatus.cancelled;
  bool get isRenewed => status == SubscriptionStatus.renewed;

  // Calcular duración
  Duration? get duration {
    if (endDate == null) return null;
    return endDate!.difference(startDate);
  }

  // Verificar si está expirada
  bool get isExpiredNow {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  // Días restantes
  int? get daysRemaining {
    if (endDate == null) return null;
    return endDate!.difference(DateTime.now()).inDays;
  }
}

@JsonSerializable()
class SubscriptionCreateModel extends JsonConvertible<SubscriptionCreateModel> {
  final String vehiclePlate;
  final String? vehicleType;
  final String? vehicleColor;
  final String? ownerName;
  final String? ownerDocument;
  final String? ownerPhone;
  final String? spotId;
  final String startDate;
  final SubscriptionPeriod period;
  final double? amount;
  final String? notes;

  SubscriptionCreateModel({
    required this.vehiclePlate,
    this.vehicleType,
    this.vehicleColor,
    this.ownerName,
    this.ownerDocument,
    this.ownerPhone,
    this.spotId,
    required this.startDate,
    required this.period,
    this.amount,
    this.notes,
  });

  factory SubscriptionCreateModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubscriptionCreateModelToJson(this);
}

@JsonSerializable()
class SubscriptionUpdateModel extends JsonConvertible<SubscriptionUpdateModel> {
  final String? spotId;
  final DateTime? endDate;
  final double? amount;
  final SubscriptionStatus? status;
  final bool? isActive;
  final String? notes;

  SubscriptionUpdateModel({
    this.spotId,
    this.endDate,
    this.amount,
    this.status,
    this.isActive,
    this.notes,
  });

  factory SubscriptionUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubscriptionUpdateModelToJson(this);
}

@JsonSerializable()
class SubscriptionRenewalModel extends JsonConvertible<SubscriptionRenewalModel> {
  final SubscriptionPeriod period;
  final double? amount;
  final String? notes;

  SubscriptionRenewalModel({
    required this.period,
    this.amount,
    this.notes,
  });

  factory SubscriptionRenewalModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionRenewalModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubscriptionRenewalModelToJson(this);
}

@JsonSerializable()
class SubscriptionPreviewModel extends JsonConvertible<SubscriptionPreviewModel> {
  final String id;
  final int number;
  final String parkingId;
  final String employeeId;
  final String vehicleId;
  final String? spotId;
  final DateTime startDate;
  final DateTime? endDate;
  final double amount;
  final SubscriptionStatus status;
  final SubscriptionPeriod period;
  final bool isActive;
  final String? parentId;
  final String? notes;

  SubscriptionPreviewModel({
    required this.id,
    required this.number,
    required this.parkingId,
    required this.employeeId,
    required this.vehicleId,
    this.spotId,
    required this.startDate,
    this.endDate,
    required this.amount,
    required this.status,
    required this.period,
    required this.isActive,
    this.parentId,
    this.notes,
  });

  factory SubscriptionPreviewModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPreviewModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubscriptionPreviewModelToJson(this);
}

@JsonSerializable()
class SubscriptionForElementModel extends JsonConvertible<SubscriptionForElementModel> {
  final String id;
  final int number;
  final EmployeePreviewModel employee;
  final VehiclePreviewModel vehicle;
  final DateTime startDate;
  final DateTime? endDate;
  final double amount;
  final SubscriptionStatus status;
  final SubscriptionPeriod period;
  final bool isActive;
  final String? notes;

  SubscriptionForElementModel({
    required this.id,
    required this.number,
    required this.employee,
    required this.vehicle,
    required this.startDate,
    this.endDate,
    required this.amount,
    required this.status,
    required this.period,
    required this.isActive,
    this.notes,
  });

  factory SubscriptionForElementModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionForElementModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubscriptionForElementModelToJson(this);
}