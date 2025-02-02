// core/screen_controller.dart
import 'dart:ui';

import '../entities/facility.dart';
import '../entities/signage.dart';
import '../entities/spot.dart';
import '../core/entity_system.dart';
import '../components/transform.dart';

class ScreenController {
  final EntitySystem entitySystem;

  ScreenController({required this.entitySystem});

  void addParkingSpot(Offset position, SpotType type, {bool isOccupied = false}) {
    entitySystem.addEntity(ParkingSpot(
      id: 'spot_${DateTime.now().millisecondsSinceEpoch}',
      transform: TransformComponent(x: position.dx, y: position.dy),
      type: type,
      isOccupied: isOccupied,
    ));
  }

  void addFacility(Offset position, FacilityType type) {
    entitySystem.addEntity(Facility(
      id: 'facility_${DateTime.now().millisecondsSinceEpoch}',
      transform: TransformComponent(x: position.dx, y: position.dy),
      type: type,
    ));
  }

  void addSignage(Offset position, SignageType type) {
    entitySystem.addEntity(Signage(
      id: 'signage_${DateTime.now().millisecondsSinceEpoch}',
      transform: TransformComponent(x: position.dx, y: position.dy),
      type: type,
    ));
  }

  void removeEntity(String id) {
    entitySystem.entities.removeWhere((entity) => entity.id == id);
  }

  void selectEntity(Entity? entity) {
    // Aquí puedes agregar lógica adicional para manejar la selección
    print("Entidad seleccionada: ${entity?.id}");
  }
}