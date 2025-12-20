import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'parking_model.dart';
import 'employee_model.dart';
import 'vehicle_model.dart';

part 'access_model.g.dart';

// Enum para estados de acceso
enum AccessStatus {
  @JsonValue('entered')
  entered,
  @JsonValue('exited')
  exited,
  @JsonValue('cancelled')
  cancelled,
}

@JsonSerializable()
class AccessModel extends JsonConvertible<AccessModel> {
  final String id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int number;
  final String parkingId;
  final ParkingPreviewModel parking;
  final String employeeId;
  final EmployeePreviewModel employee;
  final String vehicleId;
  final VehiclePreviewModel vehicle;
  final String? spotId;
  final DateTime entryTime;
  final DateTime? exitTime;
  final String? exitEmployeeId;
  final EmployeePreviewModel? exitEmployee;
  final double amount;
  final AccessStatus status;
  final String? notes;

  AccessModel({
    required this.id,
    this.createdAt,
    this.updatedAt,
    required this.number,
    required this.parkingId,
    required this.parking,
    required this.employeeId,
    required this.employee,
    required this.vehicleId,
    required this.vehicle,
    this.spotId,
    required this.entryTime,
    this.exitTime,
    this.exitEmployeeId,
    this.exitEmployee,
    required this.amount,
    required this.status,
    this.notes,
  });

  @override
  Map<String, dynamic> toJson() => _$AccessModelToJson(this);

  // Custom fromJson to handle API response structure
  factory AccessModel.fromJson(Map<String, dynamic> json) {
    return AccessModel(
      id: json['id'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      number: (json['number'] as num).toInt(),
      parkingId: (json['parking'] as Map<String, dynamic>)['id'] as String,
      parking: ParkingPreviewModel.fromJson(
        json['parking'] as Map<String, dynamic>,
      ),
      employeeId: (json['employee'] as Map<String, dynamic>)['id'] as String,
      employee: EmployeePreviewModel.fromJson(
        json['employee'] as Map<String, dynamic>,
      ),
      vehicleId: (json['vehicle'] as Map<String, dynamic>)['id'] as String,
      vehicle: VehiclePreviewModel.fromJson(
        json['vehicle'] as Map<String, dynamic>,
      ),
      spotId: json['spotId'] as String?,
      entryTime: DateTime.parse(json['entryTime'] as String),
      exitTime: json['exitTime'] != null
          ? DateTime.parse(json['exitTime'] as String)
          : null,
      exitEmployeeId: json['exitEmployeeId'] as String?,
      exitEmployee: json['exitEmployee'] != null
          ? EmployeePreviewModel.fromJson(
              json['exitEmployee'] as Map<String, dynamic>,
            )
          : null,
      amount: (json['amount'] as num).toDouble(),
      status: $enumDecode(_$AccessStatusEnumMap, json['status']),
      notes: json['notes'] as String?,
    );
  }

  // Métodos de conveniencia
  bool get isEntered => status == AccessStatus.entered;
  bool get isExited => status == AccessStatus.exited;
  bool get isCancelled => status == AccessStatus.cancelled;

  // Calcular duración
  Duration? get duration {
    if (exitTime == null) return null;
    return exitTime!.difference(entryTime);
  }

  // Formatear duración
  String get formattedDuration {
    final endTime = exitTime ?? DateTime.now();
    final duration = endTime.difference(entryTime);
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
class AccessUpdateModel extends JsonConvertible<AccessUpdateModel> {
  final String? spotId;
  final DateTime? exitTime;
  final String? exitEmployeeId;
  final double? amount;
  final AccessStatus? status;
  final String? notes;

  AccessUpdateModel({
    this.spotId,
    this.exitTime,
    this.exitEmployeeId,
    this.amount,
    this.status,
    this.notes,
  });

  factory AccessUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$AccessUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AccessUpdateModelToJson(this);
}

@JsonSerializable()
class AccessPreviewModel extends JsonConvertible<AccessPreviewModel> {
  final String id;
  final int number;
  final String parkingId;
  final String employeeId;
  final String vehicleId;
  final String? spotId;
  final DateTime entryTime;
  final DateTime? exitTime;
  final double amount;
  final AccessStatus status;
  final String? notes;

  AccessPreviewModel({
    required this.id,
    required this.number,
    required this.parkingId,
    required this.employeeId,
    required this.vehicleId,
    this.spotId,
    required this.entryTime,
    this.exitTime,
    required this.amount,
    required this.status,
    this.notes,
  });

  factory AccessPreviewModel.fromJson(Map<String, dynamic> json) =>
      _$AccessPreviewModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AccessPreviewModelToJson(this);
}

@JsonSerializable()
class AccessForElementModel extends JsonConvertible<AccessForElementModel> {
  final String id;
  final int number;
  final EmployeePreviewModel employee;
  final VehiclePreviewModel vehicle;
  final DateTime entryTime;
  final DateTime? exitTime;
  final double amount;
  final AccessStatus status;
  final String? notes;

  AccessForElementModel({
    required this.id,
    required this.number,
    required this.employee,
    required this.vehicle,
    required this.entryTime,
    this.exitTime,
    required this.amount,
    required this.status,
    this.notes,
  });

  factory AccessForElementModel.fromJson(Map<String, dynamic> json) =>
      _$AccessForElementModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AccessForElementModelToJson(this);
}

@JsonSerializable()
class ExitRequestModel extends JsonConvertible<ExitRequestModel> {
  final String exitEmployeeId;
  final double? amount;
  final String? notes;

  ExitRequestModel({
    required this.exitEmployeeId,
    this.amount,
    this.notes,
  });

  factory ExitRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ExitRequestModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ExitRequestModelToJson(this);
}