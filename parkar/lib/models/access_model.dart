import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'parking_model.dart';
import 'employee_model.dart';
import 'vehicle_model.dart';
import 'element_model.dart';

part 'access_model.g.dart';

@JsonSerializable()
class AccessModel extends JsonConvertible<AccessModel> {
  final String id;
  final int number;
  final String parkingId;
  final String? areaId;
  final ParkingPreviewModel parking;
  final String entryEmployeeId;
  final EmployeePreviewModel entryEmployee;
  final String? exitEmployeeId;
  final EmployeePreviewModel? exitEmployee;
  final String vehicleId;
  final VehiclePreviewModel vehicle;
  final String spotId;
  final ElementPreviewModel spot;
  final DateTime entryTime;
  final DateTime? exitTime;
  final double? amount;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  // Getters para compatibilidad
  DateTime get dateTime => entryTime;
  String get employeeId => entryEmployeeId;
  EmployeePreviewModel get employee => entryEmployee;

  AccessModel({
    required this.id,
    required this.number,
    required this.parkingId,
    required this.areaId,
    required this.parking,
    required this.entryEmployeeId,
    required this.entryEmployee,
    this.exitEmployeeId,
    this.exitEmployee,
    required this.vehicleId,
    required this.vehicle,
    required this.spotId,
    required this.spot,
    required this.entryTime,
    this.exitTime,
    this.amount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory AccessModel.fromJson(Map<String, dynamic> json) =>
      _$AccessModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AccessModelToJson(this);

  // Métodos de conveniencia
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  // Calcular duración si hay salida
  Duration? get duration {
    if (exitTime == null) return null;
    return exitTime!.difference(entryTime);
  }

  // Formatear duración
  String get formattedDuration {
    if (exitTime == null) {
      final now = DateTime.now();
      final duration = now.difference(entryTime);
      return _formatDuration(duration);
    }
    return _formatDuration(exitTime!.difference(entryTime));
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
class AccessCreateModel extends JsonConvertible<AccessCreateModel> {
  final String parkingId;
  final String spotId;
  final String? ownerName;
  final String? ownerDocument;
  final String? ownerPhone;
  final String vehiclePlate;
  final String? vehicleType;
  final String? vehicleColor;
  final String areaId;

  AccessCreateModel({
    required this.parkingId,
    required this.spotId,
    this.ownerName,
    this.ownerDocument,
    this.ownerPhone,
    required this.vehiclePlate,
    this.vehicleType,
    this.vehicleColor,
    required this.areaId,
  });

  factory AccessCreateModel.fromJson(Map<String, dynamic> json) =>
      _$AccessCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AccessCreateModelToJson(this);
}

@JsonSerializable()
class AccessUpdateModel extends JsonConvertible<AccessUpdateModel> {
  final int? number;
  final String? vehicleId;
  final String? spotId;
  final DateTime? exitTime;
  final String? exitEmployeeId;
  final double? amount;
  final String? status;

  AccessUpdateModel({
    this.number,
    this.vehicleId,
    this.spotId,
    this.exitTime,
    this.exitEmployeeId,
    this.amount,
    this.status,
  });

  factory AccessUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$AccessUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AccessUpdateModelToJson(this);
}


@JsonSerializable()
class AccessPreviewModel extends JsonConvertible<AccessPreviewModel> {
  final String id;
  final String number;
  final String entryTime;
  final String? exitTime;
  final String vehicleId;
  final String status;
  final VehiclePreviewModel vehicle;
  final String parkingId;
  final String areaId;
  final String spotId;

  AccessPreviewModel({
    required this.id,
    required this.number,
    required this.entryTime,
    required this.exitTime,
    required this.vehicleId,
    required this.status,
    required this.vehicle,
    required this.parkingId,
    required this.areaId,
    required this.spotId,
  });

  factory AccessPreviewModel.fromJson(Map<String, dynamic> json) =>
      _$AccessPreviewModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AccessPreviewModelToJson(this);
}
