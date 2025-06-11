/// Modelo para representar un estacionamiento
class Parking {
  /// Identificador único del estacionamiento
  final int id;

  /// Nombre del estacionamiento
  final String name;

  /// Dirección del estacionamiento
  final String address;

  /// Cantidad de espacios disponibles
  final int availableSpots;

  /// Cantidad de espacios ocupados
  final int occupiedSpots;

  /// Indica si el estacionamiento está abierto
  final bool isOpen;

  /// URL de la imagen del estacionamiento
  final String? imageUrl;

  /// Constructor
  Parking({
    required this.id,
    required this.name,
    required this.address,
    required this.availableSpots,
    required this.occupiedSpots,
    required this.isOpen,
    this.imageUrl,
  });

  /// Crear un estacionamiento a partir de un mapa
  factory Parking.fromJson(Map<String, dynamic> json) {
    return Parking(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      availableSpots: json['available_spots'] as int,
      occupiedSpots: json['occupied_spots'] as int,
      isOpen: json['is_open'] as bool,
      imageUrl: json['image_url'] as String?,
    );
  }

  /// Convertir el estacionamiento a un mapa
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'available_spots': availableSpots,
      'occupied_spots': occupiedSpots,
      'is_open': isOpen,
      'image_url': imageUrl,
    };
  }
}
