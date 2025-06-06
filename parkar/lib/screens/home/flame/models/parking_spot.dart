import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

import 'flame_element.dart';

/// Tipos de espacios de estacionamiento
enum FlameSpotType {
  standard,
  disabled,
  electric,
  premium,
  compact,
  motorcycle,
  loading,
}

/// Clase que representa un espacio de estacionamiento
class FlameSpot extends FlameElement {
  final FlameSpotType spotType;
  bool isOccupied;
  String vehiclePlate;

  FlameSpot({
    required String id,
    required vector_math.Vector2 position,
    required Vector2 size,
    this.spotType = FlameSpotType.standard,
    String label = '',
    double rotation = 0.0,
    this.isOccupied = false,
    this.vehiclePlate = '',
  }) : super(
          id: id,
          type: spotType.toString(),
          position: position,
          size: size,
          label: label,
          rotation: rotation,
        ) {
    // Configurar color según el tipo
    switch (spotType) {
      case FlameSpotType.standard:
        color = Colors.blue.shade700;
        break;
      case FlameSpotType.disabled:
        color = Colors.indigo;
        break;
      case FlameSpotType.electric:
        color = Colors.green;
        break;
      case FlameSpotType.premium:
        color = Colors.amber.shade700;
        break;
      case FlameSpotType.compact:
        color = Colors.cyan;
        break;
      case FlameSpotType.motorcycle:
        color = Colors.teal;
        break;
      case FlameSpotType.loading:
        color = Colors.deepOrange;
        break;
    }
  }

  @override
  FlameSpot clone() {
    return FlameSpot(
      id: id,
      position: vector_math.Vector2(position.x, position.y),
      size: size.clone(),
      spotType: spotType,
      label: label,
      rotation: angle,
      isOccupied: isOccupied,
      vehiclePlate: vehiclePlate,
    );
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = isOccupied ? color.withOpacity(0.8) : color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    // Dibujar el rectángulo base
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.x,
        height: size.y,
      ),
      paint,
    );

    // Dibujar líneas de estacionamiento
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.x - 4,
        height: size.y - 4,
      ),
      linePaint,
    );

    // Dibujar símbolo específico según el tipo
    switch (spotType) {
      case FlameSpotType.disabled:
        _drawDisabledSymbol(canvas);
        break;
      case FlameSpotType.electric:
        _drawElectricSymbol(canvas);
        break;
      case FlameSpotType.premium:
        _drawPremiumSymbol(canvas);
        break;
      default:
        break;
    }

    // Si está ocupado, mostrar un vehículo
    if (isOccupied) {
      _drawVehicle(canvas);
    }

    // Si está seleccionado, dibujar indicadores de selección
    if (isSelected) {
      _drawSelectionIndicators(canvas);
    }

    // Dibujar la etiqueta
    if (label.isNotEmpty) {
      _drawLabel(canvas);
    }
  }

  void _drawDisabledSymbol(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Dibujar un símbolo de accesibilidad simplificado
    final radius = size.x * 0.15;
    canvas.drawCircle(Offset.zero, radius, paint);

    final figurePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(Offset.zero, radius - 2, figurePaint);
  }

  void _drawElectricSymbol(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Dibujar un rayo simplificado
    final path = Path();
    final size = this.size.x * 0.15;
    path.moveTo(-size / 2, -size);
    path.lineTo(size / 2, -size / 3);
    path.lineTo(0, 0);
    path.lineTo(size / 2, size);
    path.lineTo(-size / 2, size / 3);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawPremiumSymbol(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Dibujar una estrella simplificada
    final size = this.size.x * 0.15;
    canvas.drawCircle(Offset.zero, size, paint);

    final textStyle = TextStyle(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.bold,
    );

    final textSpan = TextSpan(
      text: 'P',
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

  void _drawVehicle(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    // Dibujar un rectángulo representando un vehículo
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.x * 0.7,
        height: size.y * 0.7,
      ),
      paint,
    );

    // Dibujar parabrisas
    final windshieldPaint = Paint()
      ..color = Colors.lightBlue.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(0, -size.y * 0.15),
        width: size.x * 0.6,
        height: size.y * 0.2,
      ),
      windshieldPaint,
    );
  }

  void _drawSelectionIndicators(Canvas canvas) {
    final borderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.x + 4,
        height: size.y + 4,
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
    _drawHandle(canvas, Vector2(-size.x / 2, -size.y / 2), handlePaint, handleBorderPaint);
    _drawHandle(canvas, Vector2(size.x / 2, -size.y / 2), handlePaint, handleBorderPaint);
    _drawHandle(canvas, Vector2(-size.x / 2, size.y / 2), handlePaint, handleBorderPaint);
    _drawHandle(canvas, Vector2(size.x / 2, size.y / 2), handlePaint, handleBorderPaint);

    // Dibujar el punto de rotación
    canvas.drawCircle(
      Offset(0, -size.y / 2 - 15),
      5.0,
      handlePaint,
    );
    canvas.drawCircle(
      Offset(0, -size.y / 2 - 15),
      5.0,
      handleBorderPaint,
    );

    // Dibujar línea al punto de rotación
    final linePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(0, -size.y / 2),
      Offset(0, -size.y / 2 - 15),
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
      Offset(-textPainter.width / 2, -textPainter.height / 2),
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