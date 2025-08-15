/// Vehicle model class
class Vehicle {
  /// Vehicle ID
  final String id;

  /// License plate
  final String licensePlate;

  /// Vehicle type
  final String type;

  /// Owner name
  final String? ownerName;

  /// Entry time
  final DateTime entryTime;

  /// Exit time
  final DateTime? exitTime;

  /// Spot ID
  final String spotId;

  /// Constructor
  Vehicle({
    required this.id,
    required this.licensePlate,
    required this.type,
    this.ownerName,
    required this.entryTime,
    this.exitTime,
    required this.spotId,
  });

  /// Create from JSON
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      licensePlate: json['licensePlate'] as String,
      type: json['type'] as String,
      ownerName: json['ownerName'] as String?,
      entryTime: DateTime.parse(json['entryTime'] as String),
      exitTime: json['exitTime'] != null
          ? DateTime.parse(json['exitTime'] as String)
          : null,
      spotId: json['spotId'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'licensePlate': licensePlate,
      'type': type,
      'ownerName': ownerName,
      'entryTime': entryTime.toIso8601String(),
      'exitTime': exitTime?.toIso8601String(),
      'spotId': spotId,
    };
  }
}
