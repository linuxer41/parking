import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart' as vector_math;

import 'world_elements.dart';
import 'enums.dart';

/// Clase para representar instalaciones del estacionamiento
class ParkingFacility extends RenderableElement {
  FacilityType type;

  ParkingFacility({
    required super.id,
    required super.position,
    required this.type,
    super.label,
    super.rotation = 0.0,
    Size3D? size,
    super.isResizable = true,
    super.isRotatable = true,
  }) : super(
          size: size ?? Size3D(width: 40.0, height: 40.0, depth: 20.0),
          color: Colors.blue,
        ) {
    // Aplicar propiedades visuales según el tipo
    final typeVisuals = ElementProperties.getFacilityVisuals(type);
    applyVisuals(typeVisuals);
  }

  /// Cambiar el tipo de instalación
  void setType(FacilityType newType) {
    type = newType;
    final typeVisuals = ElementProperties.getFacilityVisuals(type);
    applyVisuals(typeVisuals);
  }

  @override
  void renderContent(Canvas canvas, Offset center, double zoom) {
    // Dibujar con estilo ultraminimalista
    final rect = Rect.fromCenter(
      center: center,
      width: size.width * zoom,
      height: size.height * zoom,
    );

    // Dibujar un sutil relleno de color
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity(0.08);
    
    // Dibujar un rectángulo con esquinas redondeadas para las instalaciones
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(2.0 * zoom),
    );
    canvas.drawRRect(rrect, fillPaint);

    // Dibujar borde con un poco más de estilo
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8 * zoom
      ..color = color.withOpacity(0.9);

    canvas.drawRRect(rrect, borderPaint);

    // Dibujar icono según tipo
    if (icon != null) {
      drawIcon(canvas, center, zoom);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': label ?? '',
      'posX': position.x,
      'posY': position.y,
      'posZ': 0.0,
      'rotation': rotation,
      'scale': 1.0,
      'width': size.width,
      'height': size.height,
      'depth': size.depth,
      'color': color.value,
      'opacity': opacity,
      'facilityType': type.index,
      'isVisible': isVisible,
    };
  }

  /// Crear desde JSON
  static ParkingFacility fromJson(Map<String, dynamic> json) {
    final facility = ParkingFacility(
      id: json['id'] ?? '',
      position: vector_math.Vector2(
        (json['posX'] ?? 0.0).toDouble(),
        (json['posY'] ?? 0.0).toDouble(),
      ),
      type: FacilityType.values[(json['facilityType'] ?? 0).toInt()],
      label: json['name'],
      rotation: (json['rotation'] ?? 0.0).toDouble(),
      size: Size3D(
        width: (json['width'] ?? 80.0).toDouble(),
        height: (json['height'] ?? 80.0).toDouble(),
        depth: (json['depth'] ?? 20.0).toDouble(),
      ),
    );

    facility.isVisible = json['isVisible'] ?? true;
    return facility;
  }
  
  @override
  WorldElement copy() {
    return ParkingFacility(
      id: '${id}_copy',
      position: vector_math.Vector2(position.x, position.y),
      type: type,
      label: label,
      rotation: rotation,
      size: Size3D.copy(size),
    );
  }
}
