import '../components/transform.dart';
import '../components/renderable.dart';
import '../components/collider.dart';
import '../components/draggable.dart';
import '../core/entity_system.dart';
import 'package:flutter/material.dart';

enum FacilityType {
  elevator,
  staircase,
  paymentKiosk,
  restroom
}

class Facility extends Entity {
  final FacilityType type;
  
  Facility({
    required String id,
    required TransformComponent transform,
    required this.type,
  }) : super(
    id: id,
    transform: transform,
    renderable: RenderableComponent(imagePath: ''),
    collider: ColliderComponent(
      rect: Rect.fromLTWH(transform.x, transform.y, 40, 40)
    ),
    draggable: DraggableComponent()
  );

  Color get facilityColor {
    switch (type) {
      case FacilityType.elevator: return Colors.grey;
      case FacilityType.staircase: return Colors.brown;
      case FacilityType.paymentKiosk: return Colors.yellow;
      case FacilityType.restroom: return Colors.lightBlue;
    }
  }
}