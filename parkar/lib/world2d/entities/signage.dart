import '../components/transform.dart';
import '../components/renderable.dart';
import '../components/collider.dart';
import '../components/draggable.dart';
import '../core/entity_system.dart';
import 'package:flutter/material.dart';

enum SignageType {
  exit,
  entrance,
  via,
  parking,
  noParking,
  disabled
}

class Signage extends Entity {
  final SignageType type;
  
  Signage({
    required String id,
    required TransformComponent transform,
    required this.type,
  }) : super(
    id: id,
    transform: transform,
    renderable: RenderableComponent(imagePath: ''),
    collider: ColliderComponent(
      rect: Rect.fromLTWH(transform.x, transform.y, 20, 20)
    ),
    draggable: DraggableComponent()
  );

  Color get signageColor {
    switch (type) {
      case SignageType.exit: return Colors.red;
      case SignageType.entrance: return Colors.green;
      case SignageType.via: return Colors.orange;
      case SignageType.parking: return Colors.blue;
      case SignageType.noParking: return Colors.red.shade300;
      case SignageType.disabled: return Colors.indigo;
    }
  }
}