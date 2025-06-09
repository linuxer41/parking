import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;
import 'dart:math' as math;

import 'world_elements.dart';
import 'enums.dart';

/// Clase para representar un lugar de estacionamiento
class ParkingSpot extends RenderableElement {
  SpotType type;
  SpotCategory category;
  bool isOccupied;
  String? vehiclePlate;

  ParkingSpot({
    required super.id,
    required super.position,
    required this.type,
    required this.category,
    this.isOccupied = false,
    this.vehiclePlate,
    super.label,
    super.rotation = 0.0,
    Size3D? size,
    super.isResizable = true,
    super.isRotatable = true,
  }) : super(
          size: size ?? Size3D(width: 40.0, height: 80.0, depth: 10.0),
          color: Colors.blue,
        ) {
    // Aplicar propiedades visuales según el tipo
    final typeVisuals = ElementProperties.getSpotVisuals(type);
    applyVisuals(typeVisuals);
  }

  /// Obtener el color asociado a la categoría del espacio
  Color get categoryColor => ElementProperties.getSpotCategoryVisuals(category).color;
  
  /// Obtener el icono asociado al tipo de espacio
  IconData get typeIcon => ElementProperties.getSpotVisuals(type).icon;
  
  /// Obtener el nombre de la categoría
  String get categoryName => ElementProperties.getSpotCategoryVisuals(category).label;

  /// Cambiar el tipo de espacio
  void setType(SpotType newType) {
    type = newType;
    final typeVisuals = ElementProperties.getSpotVisuals(type);
    applyVisuals(typeVisuals);
  }

  /// Cambiar la categoría
  void setCategory(SpotCategory newCategory) {
    category = newCategory;
  }

  /// Cambiar el estado de ocupación
  void setOccupied(bool occupied, {String? plate}) {
    isOccupied = occupied;
    vehiclePlate = plate;
  }

  @override
  void renderContent(Canvas canvas, Offset center, double zoom) {
    // Dibujar con estilo ultraminimalista
    final rect = Rect.fromCenter(
      center: center,
      width: size.width * zoom,
      height: size.height * zoom,
    );

    // Determinar el color según el estado
    Color spotColor = color;
    if (isSelected) {
      spotColor = ElementProperties.selectedColor;
    } else if (isOccupied) {
      spotColor = ElementProperties.occupiedColor;
    }

    // Dibujar un sutil relleno de color
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = spotColor.withOpacity(0.05);
    canvas.drawRect(rect, fillPaint);

    // Dibujar borde con un poco más de estilo
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8 * zoom
      ..color = spotColor.withOpacity(0.9);

    canvas.drawRect(rect, borderPaint);

    // Dibujar icono SOLO si el espacio está ocupado
    if (isOccupied && icon != null) {
      drawIcon(canvas, center, zoom);
    }

    // Si está ocupado, mostrar indicador minimalista
    if (isOccupied) {
      final occupiedPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2 * zoom
        ..color = Colors.red.withOpacity(0.8);
        
      // Dibujar una X minimalista
      final margin = math.min(size.width, size.height) * 0.15 * zoom;
      canvas.drawLine(
        Offset(rect.left + margin, rect.top + margin),
        Offset(rect.right - margin, rect.bottom - margin),
        occupiedPaint
      );
      canvas.drawLine(
        Offset(rect.right - margin, rect.top + margin),
        Offset(rect.left + margin, rect.bottom - margin),
        occupiedPaint
      );
    }

    // Dibujar un punto de color en la esquina superior izquierda para indicar la categoría
    final categoryVisuals = ElementProperties.getSpotCategoryVisuals(category);
    drawColorDot(
        canvas,
        Offset(rect.left + 4 * zoom, rect.top + 4 * zoom),
        zoom,
        dotColor: categoryVisuals.color);
  }

  @override
  void renderLabel(Canvas canvas, Offset center, double zoom) {
    if (label != null && label!.isNotEmpty) {
      // Determinar el color según el estado
      Color spotColor = color;
      if (isSelected) {
        spotColor = ElementProperties.selectedColor;
      } else if (isOccupied) {
        spotColor = ElementProperties.occupiedColor;
      }
      
      drawLabelWithAlign(
        canvas,
        label!,
        Offset(center.dx, center.dy + size.height * zoom / 4),
        zoom,
        textColor: spotColor,
        textAlign: TextAlign.center,
        withBackground: true,
      );
    }
  }

  @override
  bool containsPoint(vector_math.Vector2 point) {
    // Usar el método de la clase base que ya maneja la rotación
    return super.containsPoint(point);
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
      'vehicleId': vehiclePlate,
      'spotType': type.index,
      'spotCategory': category.index,
      'isVisible': isVisible,
    };
  }

  /// Crear desde JSON
  static ParkingSpot fromJson(Map<String, dynamic> json) {
    final spot = ParkingSpot(
      id: json['id'] ?? '',
      position: vector_math.Vector2(
        (json['posX'] ?? 0.0).toDouble(),
        (json['posY'] ?? 0.0).toDouble(),
      ),
      type: SpotType.values[(json['spotType'] ?? 0).toInt()],
      category: SpotCategory.values[(json['spotCategory'] ?? 0).toInt()],
      isOccupied:
          json['vehicleId'] != null && json['vehicleId'].toString().isNotEmpty,
      vehiclePlate: json['vehicleId'],
      label: json['name'],
      rotation: (json['rotation'] ?? 0.0).toDouble(),
      size: Size3D(
        width: (json['width'] ?? 250.0).toDouble(),
        height: (json['height'] ?? 500.0).toDouble(),
        depth: (json['depth'] ?? 10.0).toDouble(),
      ),
    );

    spot.isVisible = json['isVisible'] ?? true;
    return spot;
  }
  
  @override
  WorldElement copy() {
    return ParkingSpot(
      id: '${id}_copy',
      position: vector_math.Vector2(position.x, position.y),
      type: type,
      category: category,
      isOccupied: isOccupied,
      vehiclePlate: vehiclePlate,
      label: label,
      rotation: rotation,
      size: Size3D.copy(size),
    );
  }
}
