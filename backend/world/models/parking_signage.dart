import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:vector_math/vector_math.dart' as vector_math;

import 'world_elements.dart';
import 'enums.dart';

/// Clase para representar señalización
class ParkingSignage extends WorldElement {
  SignageType type;
  int direction;

  ParkingSignage({
    required super.id,
    required super.position,
    required this.type,
    this.direction = 0,
    super.label,
    super.rotation = 0.0,
    Size3D? size,
    super.isRotatable = true,
  }) : super(
          size: size ?? Size3D(
            width: ElementProperties.signageVisuals[type]!.width, 
            height: ElementProperties.signageVisuals[type]!.height, 
            depth: 5.0
          ),
          color: Colors.blue,
        ) {
    // Aplicar propiedades visuales según el tipo
    final typeVisuals = ElementProperties.getSignageVisuals(type);
    applyVisuals(typeVisuals);

    // Aplicar rotación según dirección
    if (direction != 0) {
      rotation = (direction * 45) * (3.14159 / 180); // Convertir a radianes
    }
  }

  /// Cambiar el tipo de señalización
  void setType(SignageType newType) {
    type = newType;
    final typeVisuals = ElementProperties.getSignageVisuals(type);
    applyVisuals(typeVisuals);
  }

  /// Cambiar la dirección (en incrementos de 45 grados)
  void setDirection(int newDirection) {
    direction = newDirection % 8; // 8 direcciones posibles (0-7)
    rotation = (direction * 45) * (3.14159 / 180); // Convertir a radianes
  }

  @override
  void render(
      Canvas canvas, Size canvasSize, double zoom, vector_math.Vector2 cameraOffset) {
    if (!isVisible) return;

    // Calcular posición en pantalla
    final screenPos = getScreenPosition(zoom, cameraOffset);

    // Guardar el estado actual del canvas
    canvas.save();
    
    // En este caso, hacemos la traslación y rotación manualmente
    // porque necesitamos dibujar con origen en el centro
    canvas.translate(screenPos.x, screenPos.y);
    if (rotation != 0) {
      canvas.rotate(rotation);
    }

    // Dibujar con estilo ultraminimalista
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: size.width * zoom,
      height: size.height * zoom,
    );

    // Dibujar un sutil relleno de color
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity(0.08);
    
    // Dibujar un rectángulo con esquinas redondeadas para las señales
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

    // Dibujar indicador de selección si está seleccionado (línea discontinua)
    if (isSelected) {
      final selectionPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2 * zoom
        ..color = ElementProperties.selectedColor.withOpacity(0.8);
      
      // Crear un rectángulo ligeramente más grande
      final selectionRect = Rect.fromCenter(
        center: Offset.zero,
        width: size.width * zoom + 4 * zoom,
        height: size.height * zoom + 4 * zoom,
      );
      
      // Dibujar línea discontinua usando el método de la clase base
      drawDashedRect(canvas, selectionRect, selectionPaint, 
          dashLength: 3 * zoom, dashSpace: 2 * zoom);
    }

    // Dibujar icono minimalista
    if (icon != null) {
      // Usamos el método de la clase base, pero con centro en el origen
      drawIcon(canvas, Offset.zero, zoom);
    }

    // Dibujar etiqueta centrada dentro del elemento
    if (label != null && label!.isNotEmpty) {
      drawLabelWithAlign(
        canvas,
        label!,
        Offset(0, size.height * zoom / 4),
        zoom,
        textAlign: TextAlign.center,
        withBackground: true);
    }

    // Finalizar renderizado (restaurar estado del canvas)
    canvas.restore();
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
      'signageType': type.index,
      'direction': direction,
      'isVisible': isVisible,
    };
  }

  /// Crear desde JSON
  static ParkingSignage fromJson(Map<String, dynamic> json) {
    final signage = ParkingSignage(
      id: json['id'] ?? '',
      position: vector_math.Vector2(
        (json['posX'] ?? 0.0).toDouble(),
        (json['posY'] ?? 0.0).toDouble(),
      ),
      type: SignageType.values[(json['signageType'] ?? 0).toInt()],
      direction: (json['direction'] ?? 0).toInt(),
      label: json['name'],
      rotation: (json['rotation'] ?? 0.0).toDouble(),
      size: Size3D(
        width: (json['width'] ?? 60.0).toDouble(),
        height: (json['height'] ?? 30.0).toDouble(),
        depth: (json['depth'] ?? 5.0).toDouble(),
      ),
    );

    signage.isVisible = json['isVisible'] ?? true;
    return signage;
  }
  
  @override
  WorldElement copy() {
    return ParkingSignage(
      id: '${id}_copy',
      position: vector_math.Vector2(position.x, position.y),
      type: type,
      direction: direction,
      label: label,
      rotation: rotation,
      size: Size3D.copy(size),
    );
  }
}
