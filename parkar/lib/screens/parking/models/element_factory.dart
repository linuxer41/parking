import 'package:vector_math/vector_math.dart' as vector_math;

import '../../../models/parking_model.dart';
import 'enums.dart';
import 'parking_elements.dart';
import 'parking_spot.dart';
import 'parking_signage.dart';
import 'parking_facility.dart';

/// Factory para crear elementos del sistema de parkeo
class ElementFactory {
  static ParkingElement? createFromModel(ElementModel model) {
    switch (model.type) {
      case ElementType.spot:
        return createSpot(model);
      case ElementType.signage:
        return createSignage(model);
      case ElementType.facility:
        return createFacility(model);
      default:
        return null;
    }
  }

  static ParkingSpot createSpot(ElementModel model) {
    SpotType spotType;
    switch (model.subType) {
      case 1:
        spotType = SpotType.bicycle;
        break;
      case 2:
        spotType = SpotType.motorcycle;
        break;
      case 3:
        spotType = SpotType.vehicle;
        break;
      case 4:
        spotType = SpotType.truck;
        break;
      default:
        spotType = SpotType.vehicle;
    }

    return ParkingSpot(
      id: model.id,
      position: vector_math.Vector2(model.posX, model.posY),
      type: spotType,
      label: model.name,
      isOccupied: model.status == 'occupied',
      rotation: model.rotation,
      scale: model.scale,
      entry: model.entry,
      booking: model.booking,
      subscription: model.subscription,
      status: model.status,
      isActive: model.isActive,
    );
  }

  static ParkingSignage createSignage(ElementModel model) {
    SignageType signageType;
    switch (model.subType) {
      case 1:
        signageType = SignageType.entrance;
        break;
      case 2:
        signageType = SignageType.exit;
        break;
      case 3:
        signageType = SignageType.direction;
        break;
      case 4:
        signageType = SignageType.bidirectional;
        break;
      case 5:
        signageType = SignageType.stop;
        break;
      default:
        signageType = SignageType.direction;
    }

    return ParkingSignage(
      id: model.id,
      position: vector_math.Vector2(model.posX, model.posY),
      type: signageType,
      text: model.name,
      rotation: model.rotation,
      scale: model.scale,
    );
  }

  static ParkingFacility createFacility(ElementModel model) {
    FacilityType facilityType;
    switch (model.subType) {
      case 1:
        facilityType = FacilityType.office;
        break;
      case 2:
        facilityType = FacilityType.bathroom;
        break;
      case 3:
        facilityType = FacilityType.cafeteria;
        break;
      case 4:
        facilityType = FacilityType.elevator;
        break;
      case 5:
        facilityType = FacilityType.stairs;
        break;
      case 6:
        facilityType = FacilityType.information;
        break;
      default:
        facilityType = FacilityType.elevator;
    }

    return ParkingFacility(
      id: model.id,
      position: vector_math.Vector2(model.posX, model.posY),
      type: facilityType,
      name: model.name,
      isAvailable: model.status == 'available',
      rotation: model.rotation,
      scale: model.scale,
    );
  }

  static ParkingElement? fromJson(Map<String, dynamic> json) {
    final String type = json['type'] as String;

    switch (type) {
      case 'spot':
        return ParkingSpot.fromJson(json);
      case 'signage':
        return ParkingSignage.fromJson(json);
      case 'facility':
        return ParkingFacility.fromJson(json);
      default:
        return null;
    }
  }
}
