import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'parking_model.dart';
import 'employee_model.dart';
import 'vehicle_model.dart';

part 'booking_model.g.dart';

// Enum para estados de reserva
enum ReservationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('active')
  active,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('expired')
  expired,
}

@JsonSerializable()
class BookingModel extends JsonConvertible<BookingModel> {
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
  final ReservationStatus status;
  final String? notes;

  BookingModel({
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
    this.notes,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) =>
      _$BookingModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BookingModelToJson(this);

  // Métodos de conveniencia
  bool get isPending => status == ReservationStatus.pending;
  bool get isActive => status == ReservationStatus.active;
  bool get isCompleted => status == ReservationStatus.completed;
  bool get isCancelled => status == ReservationStatus.cancelled;
  bool get isExpired => status == ReservationStatus.expired;

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
class BookingCreateModel extends JsonConvertible<BookingCreateModel> {
  final String employeeId;
  final String vehicleId;
  final String? spotId;
  final DateTime startDate;
  final DateTime? endDate;
  final ReservationStatus status;
  final double amount;
  final String? notes;

  BookingCreateModel({
    required this.employeeId,
    required this.vehicleId,
    this.spotId,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.amount,
    this.notes,
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
  final ReservationStatus? status;
  final double? amount;
  final String? notes;

  BookingUpdateModel({
    this.number,
    this.employeeId,
    this.vehicleId,
    this.spotId,
    this.startDate,
    this.endDate,
    this.status,
    this.amount,
    this.notes,
  });

  factory BookingUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$BookingUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BookingUpdateModelToJson(this);
}

@JsonSerializable()
class BookingPreviewModel extends JsonConvertible<BookingPreviewModel> {
  final String id;
  final int number;
  final String employeeId;
  final String vehicleId;
  final String? spotId;
  final DateTime startDate;
  final DateTime? endDate;
  final ReservationStatus status;
  final double amount;
  final String? notes;

  BookingPreviewModel({
    required this.id,
    required this.number,
    required this.employeeId,
    required this.vehicleId,
    this.spotId,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.amount,
    this.notes,
  });

  factory BookingPreviewModel.fromJson(Map<String, dynamic> json) =>
      _$BookingPreviewModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BookingPreviewModelToJson(this);
}

@JsonSerializable()
class BookingForElementModel extends JsonConvertible<BookingForElementModel> {
  final String id;
  final int number;
  final EmployeePreviewModel employee;
  final VehiclePreviewModel vehicle;
  final DateTime startDate;
  final DateTime? endDate;
  final double amount;
  final ReservationStatus status;
  final String? notes;

  BookingForElementModel({
    required this.id,
    required this.number,
    required this.employee,
    required this.vehicle,
    required this.startDate,
    this.endDate,
    required this.amount,
    required this.status,
    this.notes,
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
  final int duration;
  final String? notes;

  BookingCreateFromFormModel({
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
    required this.duration,
    this.notes,
  });

  factory BookingCreateFromFormModel.fromJson(Map<String, dynamic> json) =>
      _$BookingCreateFromFormModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BookingCreateFromFormModelToJson(this);
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
