/// Modelo para representar un área de estacionamiento
class ParkingArea {
  /// Identificador único del área
  final int id;

  /// Identificador del estacionamiento al que pertenece
  final int parkingId;

  /// Nombre del área
  final String name;

  /// Descripción del área
  final String? description;

  /// Capacidad total de espacios
  final int capacity;

  /// Número de espacios ocupados
  final int occupiedSpots;

  /// Tipo de área (cubierta, descubierta, etc.)
  final String? areaType;

  /// Constructor
  ParkingArea({
    required this.id,
    required this.parkingId,
    required this.name,
    this.description,
    required this.capacity,
    required this.occupiedSpots,
    this.areaType,
  });

  /// Crear un área de estacionamiento a partir de un mapa
  factory ParkingArea.fromJson(Map<String, dynamic> json) {
    return ParkingArea(
      id: json['id'] as int,
      parkingId: json['parking_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      capacity: json['capacity'] as int,
      occupiedSpots: json['occupied_spots'] as int,
      areaType: json['area_type'] as String?,
    );
  }

  /// Convertir el área de estacionamiento a un mapa
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parking_id': parkingId,
      'name': name,
      'description': description,
      'capacity': capacity,
      'occupied_spots': occupiedSpots,
      'area_type': areaType,
    };
  }

  /// Calcular espacios disponibles
  int get availableSpots => capacity - occupiedSpots;

  /// Calcular porcentaje de ocupación
  double get occupancyRate => capacity > 0 ? occupiedSpots / capacity : 0;
}
