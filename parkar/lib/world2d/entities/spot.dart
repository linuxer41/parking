import '../components/transform.dart';
import '../components/renderable.dart';
import '../components/collider.dart';
import '../components/draggable.dart';
import '../core/entity_system.dart';
import 'package:flutter/material.dart';

enum SpotType {
  car,     // 4x6 size
  bike,    // 2x4 size
  truck,   // 6x8 size
  compact  // 3x5 size
}

class ParkingSpot extends Entity {
  final SpotType type;
  
  ParkingSpot({
    required String id,
    required TransformComponent transform,
    required this.type,
    bool isOccupied = false,
  }) : super(
    id: id,
    transform: transform,
    renderable: RenderableComponent(
      imagePath: isOccupied ? 'assets/car.png' : '',
      isOccupied: isOccupied
    ),
    collider: ColliderComponent(
      rect: Rect.fromLTWH(
        transform.x,
        transform.y,
        _getSpotWidth(type),
        _getSpotHeight(type)
      )
    ),
    draggable: DraggableComponent()
  );

  static double _getSpotWidth(SpotType type) {
    switch (type) {
      case SpotType.car: return 40.0;
      case SpotType.bike: return 20.0;
      case SpotType.truck: return 60.0;
      case SpotType.compact: return 30.0;
    }
  }

  static double _getSpotHeight(SpotType type) {
    switch (type) {
      case SpotType.car: return 60.0;
      case SpotType.bike: return 40.0;
      case SpotType.truck: return 80.0;
      case SpotType.compact: return 50.0;
    }
  }

  Color get spotColor {
    switch (type) {
      case SpotType.car: return Colors.green;
      case SpotType.bike: return Colors.blue;
      case SpotType.truck: return Colors.orange;
      case SpotType.compact: return Colors.purple;
    }
  }
}