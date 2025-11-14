import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'parking_model.dart';
import 'employee_model.dart';
import 'vehicle_model.dart';

part 'booking_model.g.dart';

// Enum para tipos de booking
enum BookingType {
  @JsonValue('reservation')
  reservation,
  @JsonValue('subscription')
  subscription,
  @JsonValue('access')
  access,
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
class BookingModel extends JsonConvertible<BookingModel> {
  final String id;
  final BookingType type;
  final int number;
  final String employeeId;
  final ParkingPreviewModel parking;
  final EmployeePreviewModel employee;
  final String vehicleId;
  final VehiclePreviewModel vehicle;
  final SpotPreviewModel? spot;
  final DateTime startDate;
  final DateTime? endDate;
  final String status;
  final double amount;
  final String? parentId;
  final String? exitEmployeeId;
  final EmployeePreviewModel? exitEmployee;
  final bool isActive;
  final SubscriptionPeriod? period;

  BookingModel({
    required this.id,
    required this.type,
    required this.number,
    required this.employeeId,
    required this.parking,
    required this.employee,
    required this.vehicleId,
    required this.vehicle,
    this.spot,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.amount,
    this.parentId,
    this.exitEmployeeId,
    this.exitEmployee,
    required this.isActive,
    this.period,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) =>
      _$BookingModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BookingModelToJson(this);

  // Métodos de conveniencia
  bool get isReservation => type == BookingType.reservation;
  bool get isSubscription => type == BookingType.subscription;
  bool get isAccess => type == BookingType.access;

  // Para compatibilidad con modelos anteriores
  DateTime get startTime => startDate;
  DateTime? get dateTime => startDate;
  String get entryEmployeeId => employeeId;
  EmployeePreviewModel get entryEmployee => employee;

  // Calcular duración para accesos
  Duration? get duration {
    if (endDate == null) return null;
    return endDate!.difference(startDate);
  }

  // Formatear duración
  String get formattedDuration {
    final endTime = endDate ?? DateTime.now();
    final duration = endTime.difference(startTime);
    return _formatDuration(duration);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
    } else {
      return '${seconds}s';
    }
  }
}

@JsonSerializable()
class BookingCreateModel extends JsonConvertible<BookingCreateModel> {
  final BookingType type;
  final String employeeId;
  final String vehicleId;
  final String? spotId;
  final DateTime startDate;
  final DateTime? endDate;
  final String status;
  final double amount;
  final String? parentId;
  final String? exitEmployeeId;
  final bool? isActive;
  final SubscriptionPeriod? period;

  BookingCreateModel({
    required this.type,
    required this.employeeId,
    required this.vehicleId,
    this.spotId,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.amount,
    this.parentId,
    this.exitEmployeeId,
    this.isActive,
    this.period,
  });

  factory BookingCreateModel.fromJson(Map<String, dynamic> json) =>
      _$BookingCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BookingCreateModelToJson(this);
}

@JsonSerializable()
class BookingUpdateModel extends JsonConvertible<BookingUpdateModel> {
  final int? number;
  final String? employeeId;
  final String? vehicleId;
  final String? spotId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;
  final double? amount;
  final String? parentId;
  final String? exitEmployeeId;
  final bool? isActive;
  final SubscriptionPeriod? period;

  BookingUpdateModel({
    this.number,
    this.employeeId,
    this.vehicleId,
    this.spotId,
    this.startDate,
    this.endDate,
    this.status,
    this.amount,
    this.parentId,
    this.exitEmployeeId,
    this.isActive,
    this.period,
  });

  factory BookingUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$BookingUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BookingUpdateModelToJson(this);
}

@JsonSerializable()
class BookingPreviewModel extends JsonConvertible<BookingPreviewModel> {
  final String id;
  final BookingType type;
  final int number;
  final String employeeId;
  final String vehicleId;
  final String? spotId;
  final DateTime startDate;
  final DateTime? endDate;
  final String status;
  final double amount;
  final bool? isActive;
  final SubscriptionPeriod? period;

  BookingPreviewModel({
    required this.id,
    required this.type,
    required this.number,
    required this.employeeId,
    required this.vehicleId,
    this.spotId,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.amount,
    this.isActive,
    this.period,
  });

  factory BookingPreviewModel.fromJson(Map<String, dynamic> json) =>
      _$BookingPreviewModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BookingPreviewModelToJson(this);
}

@JsonSerializable()
class BookingForElementModel extends JsonConvertible<BookingForElementModel> {
  final String id;
  final BookingType type;
  final int number;
  final EmployeePreviewModel employee;
  final VehiclePreviewModel vehicle;
  final DateTime startDate;
  final DateTime? endDate;
  final double amount;
  final bool? isActive;
  final SubscriptionPeriod? period;

  BookingForElementModel({
    required this.id,
    required this.type,
    required this.number,
    required this.employee,
    required this.vehicle,
    required this.startDate,
    this.endDate,
    required this.amount,
    this.isActive,
    this.period,
  });

  factory BookingForElementModel.fromJson(Map<String, dynamic> json) =>
      _$BookingForElementModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BookingForElementModelToJson(this);
}

// Modelos específicos para compatibilidad con formularios existentes
@JsonSerializable()
class BookingCreateFromFormModel
    extends JsonConvertible<BookingCreateFromFormModel> {
  final BookingType type;
  final String? ownerName;
  final String? ownerPhone;
  final String? vehicleType;
  final String? vehicleColor;
  final String? ownerDocument;
  final String? spotId;
  final String? areaId;
  final String startDate; // Puede ser String o DateTime
  final double amount;
  final String vehiclePlate;
  final int? durationHours;
  final SubscriptionPeriod? period;

  BookingCreateFromFormModel({
    required this.type,
    this.ownerName,
    this.ownerPhone,
    this.vehicleType,
    this.vehicleColor,
    this.ownerDocument,
    this.spotId,
    this.areaId,
    required this.startDate,
    required this.amount,
    required this.vehiclePlate,
    this.durationHours,
    this.period,
  });

  factory BookingCreateFromFormModel.fromJson(Map<String, dynamic> json) =>
      _$BookingCreateFromFormModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BookingCreateFromFormModelToJson(this);
}

// Modelos específicos para cada tipo de booking
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
class ReservationCreateModel extends JsonConvertible<ReservationCreateModel> {
  final String vehiclePlate;
  final String? vehicleType;
  final String? vehicleColor;
  final String? ownerName;
  final String? ownerDocument;
  final String? ownerPhone;
  final String? spotId;
  final String startDate;
  final int duration;
  final String? notes;

  ReservationCreateModel({
    required this.vehiclePlate,
    this.vehicleType,
    this.vehicleColor,
    this.ownerName,
    this.ownerDocument,
    this.ownerPhone,
    this.spotId,
    required this.startDate,
    required this.duration,
    this.notes,
  });

  factory ReservationCreateModel.fromJson(Map<String, dynamic> json) =>
      _$ReservationCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ReservationCreateModelToJson(this);
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
  final String period;
  final double amount;
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
    required this.amount,
    this.notes,
  });

  factory SubscriptionCreateModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubscriptionCreateModelToJson(this);
}
