import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

import 'flame_element.dart';

/// Tipos de instalaciones
enum FlameFacilityType {
  payment,
  elevator,
  stairs,
  restroom,
  office,
  charging,
  security,
  camera,
  info,
  restaurant,
}

/// Clase que representa una instalación del estacionamiento
class FlameFacility extends FlameElement {
  final FlameFacilityType facilityType;

  FlameFacility({
    required String id,
    required vector_math.Vector2 position,
    required Vector2 size,
    this.facilityType = FlameFacilityType.payment,
    String label = '',
    double rotation = 0.0,
  }) : super(
          id: id,
          type: facilityType.toString(),
          position: position,
          size: size,
          label: label,
          rotation: rotation,
        ) {
    // Configurar color según el tipo
    switch (facilityType) {
      case FlameFacilityType.payment:
        color = Colors.green.shade700;
        break;
      case FlameFacilityType.elevator:
        color = Colors.blue.shade700;
        break;
      case FlameFacilityType.stairs:
        color = Colors.orange;
        break;
      case FlameFacilityType.restroom:
        color = Colors.indigo;
        break;
      case FlameFacilityType.office:
        color = Colors.brown;
        break;
      case FlameFacilityType.charging:
        color = Colors.teal;
        break;
      case FlameFacilityType.security:
        color = Colors.red.shade700;
        break;
      case FlameFacilityType.camera:
        color = Colors.purple;
        break;
      case FlameFacilityType.info:
        color = Colors.blue;
        break;
      case FlameFacilityType.restaurant:
        color = Colors.amber.shade700;
        break;
    }
  }

  @override
  FlameFacility clone() {
    return FlameFacility(
      id: id,
      position: vector_math.Vector2(position.x, position.y),
      size: size.clone(),
      facilityType: facilityType,
      label: label,
      rotation: angle,
    );
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    // Dibujar la forma base (un rectángulo con bordes redondeados)
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.x,
        height: size.y,
      ),
      Radius.circular(8.0),
    );

    canvas.drawRRect(rrect, paint);

    // Dibujar un icono simple según el tipo
    _drawFacilityIcon(canvas);

    // Si está seleccionado, dibujar indicadores de selección
    if (isSelected) {
      _drawSelectionIndicators(canvas);
    }

    // Dibujar la etiqueta
    if (label.isNotEmpty) {
      _drawLabel(canvas);
    }
  }

  void _drawFacilityIcon(Canvas canvas) {
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final iconSize = size.x * 0.4;

    // Dibujar un icono según el tipo de instalación
    switch (facilityType) {
      case FlameFacilityType.payment:
        _drawPaymentIcon(canvas, iconSize);
        break;
      case FlameFacilityType.elevator:
        _drawElevatorIcon(canvas, iconSize);
        break;
      case FlameFacilityType.stairs:
        _drawStairsIcon(canvas, iconSize);
        break;
      case FlameFacilityType.restroom:
        _drawRestroomIcon(canvas, iconSize);
        break;
      case FlameFacilityType.office:
        _drawOfficeIcon(canvas, iconSize);
        break;
      case FlameFacilityType.charging:
        _drawChargingIcon(canvas, iconSize);
        break;
      case FlameFacilityType.security:
        _drawSecurityIcon(canvas, iconSize);
        break;
      case FlameFacilityType.camera:
        _drawCameraIcon(canvas, iconSize);
        break;
      case FlameFacilityType.info:
        _drawInfoIcon(canvas, iconSize);
        break;
      case FlameFacilityType.restaurant:
        _drawRestaurantIcon(canvas, iconSize);
        break;
    }
  }

  void _drawPaymentIcon(Canvas canvas, double size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Dibujar un símbolo de dólar simplificado
    canvas.drawCircle(Offset.zero, size / 2, paint);
    
    final textStyle = TextStyle(
      color: color,
      fontSize: size * 0.7,
      fontWeight: FontWeight.bold,
    );

    final textSpan = TextSpan(
      text: '\$',
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
  }

  void _drawElevatorIcon(Canvas canvas, double size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Dibujar un cuadrado para el elevador
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: size,
        height: size,
      ),
      paint,
    );

    // Dibujar flechas arriba y abajo
    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Flecha hacia arriba
    final upArrowPath = Path();
    upArrowPath.moveTo(0, -size / 4);
    upArrowPath.lineTo(size / 4, 0);
    upArrowPath.lineTo(-size / 4, 0);
    upArrowPath.close();

    // Flecha hacia abajo
    final downArrowPath = Path();
    downArrowPath.moveTo(0, size / 4);
    downArrowPath.lineTo(size / 4, 0);
    downArrowPath.lineTo(-size / 4, 0);
    downArrowPath.close();

    canvas.drawPath(upArrowPath, arrowPaint);
    canvas.drawPath(downArrowPath, arrowPaint);
  }

  void _drawStairsIcon(Canvas canvas, double size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Dibujar escaleras simplificadas
    final path = Path();
    path.moveTo(-size / 2, size / 2);
    path.lineTo(-size / 2, size / 4);
    path.lineTo(-size / 6, size / 4);
    path.lineTo(-size / 6, 0);
    path.lineTo(size / 6, 0);
    path.lineTo(size / 6, -size / 4);
    path.lineTo(size / 2, -size / 4);
    path.lineTo(size / 2, -size / 2);

    canvas.drawPath(path, paint);
  }

  void _drawRestroomIcon(Canvas canvas, double size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Dibujar figuras de hombre y mujer simplificadas
    // Círculo para la cabeza
    canvas.drawCircle(Offset(-size / 4, -size / 4), size / 8, paint);
    canvas.drawCircle(Offset(size / 4, -size / 4), size / 8, paint);

    // Cuerpo del hombre
    final malePath = Path();
    malePath.moveTo(-size / 4, -size / 8);
    malePath.lineTo(-size / 4, size / 4);
    malePath.moveTo(-size / 2, 0);
    malePath.lineTo(0, 0);

    // Cuerpo de la mujer (vestido)
    final femalePath = Path();
    femalePath.moveTo(size / 4, -size / 8);
    femalePath.lineTo(0, size / 4);
    femalePath.lineTo(size / 2, size / 4);
    femalePath.close();

    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(malePath, strokePaint);
    canvas.drawPath(femalePath, paint);
  }

  void _drawOfficeIcon(Canvas canvas, double size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Dibujar un edificio de oficina simplificado
    final path = Path();
    path.moveTo(-size / 2, size / 2);
    path.lineTo(-size / 2, -size / 2);
    path.lineTo(size / 2, -size / 2);
    path.lineTo(size / 2, size / 2);

    // Ventanas
    path.moveTo(-size / 3, -size / 3);
    path.lineTo(-size / 6, -size / 3);
    path.lineTo(-size / 6, -size / 6);
    path.lineTo(-size / 3, -size / 6);
    path.close();

    path.moveTo(size / 6, -size / 3);
    path.lineTo(size / 3, -size / 3);
    path.lineTo(size / 3, -size / 6);
    path.lineTo(size / 6, -size / 6);
    path.close();

    path.moveTo(-size / 3, 0);
    path.lineTo(-size / 6, 0);
    path.lineTo(-size / 6, size / 6);
    path.lineTo(-size / 3, size / 6);
    path.close();

    path.moveTo(size / 6, 0);
    path.lineTo(size / 3, 0);
    path.lineTo(size / 3, size / 6);
    path.lineTo(size / 6, size / 6);
    path.close();

    // Puerta
    path.moveTo(-size / 8, size / 2);
    path.lineTo(-size / 8, size / 4);
    path.lineTo(size / 8, size / 4);
    path.lineTo(size / 8, size / 2);

    canvas.drawPath(path, paint);
  }

  void _drawChargingIcon(Canvas canvas, double size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Dibujar un símbolo de carga (rayo)
    final path = Path();
    path.moveTo(0, -size / 2);
    path.lineTo(size / 4, -size / 6);
    path.lineTo(0, size / 6);
    path.lineTo(0, size / 2);
    path.lineTo(-size / 4, 0);
    path.lineTo(0, -size / 3);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawSecurityIcon(Canvas canvas, double size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Dibujar un escudo
    final path = Path();
    path.moveTo(0, -size / 2);
    path.lineTo(size / 2, -size / 4);
    path.lineTo(size / 2, size / 4);
    path.lineTo(0, size / 2);
    path.lineTo(-size / 2, size / 4);
    path.lineTo(-size / 2, -size / 4);
    path.close();

    canvas.drawPath(path, paint);

    // Dibujar una cerradura en el centro
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(Offset.zero, size / 6, strokePaint);
    canvas.drawLine(
      Offset.zero,
      Offset(0, size / 8),
      strokePaint,
    );
  }

  void _drawCameraIcon(Canvas canvas, double size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Dibujar cuerpo de la cámara
    final path = Path();
    path.moveTo(-size / 2, -size / 4);
    path.lineTo(size / 2, -size / 4);
    path.lineTo(size / 2, size / 4);
    path.lineTo(-size / 2, size / 4);
    path.close();

    // Dibujar protuberancia superior
    path.moveTo(-size / 4, -size / 4);
    path.lineTo(-size / 6, -size / 3);
    path.lineTo(size / 6, -size / 3);
    path.lineTo(size / 4, -size / 4);

    canvas.drawPath(path, paint);

    // Dibujar lente
    final lensePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset.zero, size / 6, lensePaint);
    canvas.drawCircle(Offset.zero, size / 10, paint);
  }

  void _drawInfoIcon(Canvas canvas, double size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Dibujar un círculo con una "i" en el centro
    canvas.drawCircle(Offset.zero, size / 2, paint);
    
    final textStyle = TextStyle(
      color: color,
      fontSize: size * 0.8,
      fontWeight: FontWeight.bold,
    );

    final textSpan = TextSpan(
      text: 'i',
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
  }

  void _drawRestaurantIcon(Canvas canvas, double size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Dibujar un tenedor y un cuchillo
    final forkPath = Path();
    forkPath.moveTo(-size / 8, -size / 2);
    forkPath.lineTo(-size / 8, size / 3);
    forkPath.moveTo(-size / 4, -size / 2);
    forkPath.lineTo(-size / 8, -size / 4);
    forkPath.moveTo(-size / 8, -size / 4);
    forkPath.lineTo(-size / 16, -size / 2);
    forkPath.moveTo(-size / 8, -size / 4);
    forkPath.lineTo(-size / 4, -size / 4);

    final knifePath = Path();
    knifePath.moveTo(size / 8, -size / 2);
    knifePath.lineTo(size / 8, size / 3);
    knifePath.moveTo(size / 8, -size / 2);
    knifePath.lineTo(size / 4, -size / 3);
    knifePath.lineTo(size / 4, size / 3);
    knifePath.lineTo(size / 8, size / 3);

    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(forkPath, strokePaint);
    canvas.drawPath(knifePath, strokePaint);
  }

  void _drawSelectionIndicators(Canvas canvas) {
    final borderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Dibujar rectángulo de selección
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.x + 8,
        height: size.y + 8,
      ),
      borderPaint,
    );

    // Dibujar puntos de control
    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final handleBorderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Dibujar manijas en las esquinas
    _drawHandle(canvas, Vector2(-size.x/2 - 4, -size.y/2 - 4), handlePaint, handleBorderPaint);
    _drawHandle(canvas, Vector2(size.x/2 + 4, -size.y/2 - 4), handlePaint, handleBorderPaint);
    _drawHandle(canvas, Vector2(-size.x/2 - 4, size.y/2 + 4), handlePaint, handleBorderPaint);
    _drawHandle(canvas, Vector2(size.x/2 + 4, size.y/2 + 4), handlePaint, handleBorderPaint);

    // Dibujar el punto de rotación
    canvas.drawCircle(
      Offset(0, -size.y/2 - 20),
      5.0,
      handlePaint,
    );
    canvas.drawCircle(
      Offset(0, -size.y/2 - 20),
      5.0,
      handleBorderPaint,
    );

    // Dibujar línea al punto de rotación
    final linePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(0, -size.y/2 - 4),
      Offset(0, -size.y/2 - 20),
      linePaint,
    );
  }

  void _drawLabel(Canvas canvas) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      backgroundColor: Colors.black45,
    );

    final textSpan = TextSpan(
      text: label,
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, size.y/2 + 5),
    );
  }

  void _drawHandle(Canvas canvas, Vector2 position, Paint fillPaint, Paint strokePaint) {
    canvas.drawCircle(
      Offset(position.x, position.y),
      5.0,
      fillPaint,
    );
    canvas.drawCircle(
      Offset(position.x, position.y),
      5.0,
      strokePaint,
    );
  }
} 