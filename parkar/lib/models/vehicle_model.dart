import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'parking_model.dart';

part 'vehicle_model.g.dart';

@JsonSerializable()
class VehicleModel extends JsonConvertible<VehicleModel> {
  final String id;
  final String parkingId;
  final ParkingModel? parking;
  final String? typeId;
  final String plate;
  final bool? isSubscriber;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? type;
  final DateTime? entryTime;
  final DateTime? exitTime;
  final String? spotNumber;
  final double? fee;

  // Getters adicionales
  String get licensePlate => plate;
  String get vehicleType => type ?? '';

  VehicleModel({
    required this.id,
    required this.parkingId,
    this.parking,
    this.typeId,
    required this.plate,
    this.isSubscriber,
    required this.createdAt,
    this.updatedAt,
    this.type,
    this.entryTime,
    this.exitTime,
    this.spotNumber,
    this.fee,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VehicleModelToJson(this);
}

@JsonSerializable()
class VehicleCreateModel extends JsonConvertible<VehicleCreateModel> {
  final String parkingId;
  final String typeId;
  final String plate;
  final bool isSubscriber;
  final String? spotNumber;
  final double? fee;

  VehicleCreateModel({
    required this.parkingId,
    required this.typeId,
    required this.plate,
    required this.isSubscriber,
    this.spotNumber,
    this.fee,
  });

  factory VehicleCreateModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VehicleCreateModelToJson(this);
}

@JsonSerializable()
class VehicleUpdateModel extends JsonConvertible<VehicleUpdateModel> {
  final String? typeId;
  final String? plate;
  final bool? isSubscriber;
  final DateTime? exitTime;
  final double? fee;

  VehicleUpdateModel({
    this.typeId,
    this.plate,
    this.isSubscriber,
    this.exitTime,
    this.fee,
  });

  factory VehicleUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VehicleUpdateModelToJson(this);
}

class Vehicle {
  final String id;
  final String licensePlate;
  final DateTime entryTime;
  final DateTime? exitTime;
  final String spotId;
  final String type;
  final String? ownerName;
  final double? cost;

  Vehicle({
    required this.id,
    required this.licensePlate,
    required this.entryTime,
    this.exitTime,
    required this.spotId,
    required this.type,
    this.ownerName,
    this.cost,
  });

  // Constructor para crear un vehículo desde JSON
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      licensePlate: json['licensePlate'],
      entryTime: DateTime.parse(json['entryTime']),
      exitTime:
          json['exitTime'] != null ? DateTime.parse(json['exitTime']) : null,
      spotId: json['spotId'],
      type: json['type'],
      ownerName: json['ownerName'],
      cost: json['cost']?.toDouble(),
    );
  }

  // Método para convertir el vehículo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'licensePlate': licensePlate,
      'entryTime': entryTime.toIso8601String(),
      'exitTime': exitTime?.toIso8601String(),
      'spotId': spotId,
      'type': type,
      'ownerName': ownerName,
      'cost': cost,
    };
  }

  // Método para crear una copia del vehículo con algunos campos modificados
  Vehicle copyWith({
    String? id,
    String? licensePlate,
    DateTime? entryTime,
    DateTime? exitTime,
    String? spotId,
    String? type,
    String? ownerName,
    double? cost,
  }) {
    return Vehicle(
      id: id ?? this.id,
      licensePlate: licensePlate ?? this.licensePlate,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
      spotId: spotId ?? this.spotId,
      type: type ?? this.type,
      ownerName: ownerName ?? this.ownerName,
      cost: cost ?? this.cost,
    );
  }
}
