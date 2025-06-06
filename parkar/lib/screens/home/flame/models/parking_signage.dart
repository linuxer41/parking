import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

import 'flame_element.dart';

/// Tipos de señalizaciones
enum FlameSignageType {
  noParking,
  reserved,
  handicapped,
  exit,
  entrance,
  oneway,
  stop,
  yield,
  speed,
  info,
}

/// Clase que representa una señalización de tráfico
class FlameSignage extends FlameElement {
  final FlameSignageType signageType;
  String direction;

  FlameSignage({
    required String id,
    required vector_math.Vector2 position,
    required Vector2 size,
    this.signageType = FlameSignageType.noParking,
    String label = '',
    double rotation = 0.0,
    this.direction = 'north',
  }) : super(
          id: id,
          type: signageType.toString(),
          position: position,
          size: size,
          label: label,
          rotation: rotation,
        ) {
    // Configurar color según el tipo
    switch (signageType) {
      case FlameSignageType.noParking:
        color = Colors.red.shade700;
        break;
      case FlameSignageType.reserved:
        color = Colors.blue.shade700;
        break;
      case FlameSignageType.handicapped:
        color = Colors.indigo;
        break;
      case FlameSignageType.exit:
        color = Colors.green;
        break;
      case FlameSignageType.entrance:
        color = Colors.green.shade700;
        break;
      case FlameSignageType.oneway:
        color = Colors.blue;
        break;
      case FlameSignageType.stop:
        color = Colors.red;
        break;
      case FlameSignageType.yield:
        color = Colors.amber.shade700;
        break;
      case FlameSignageType.speed:
        color = Colors.blue.shade800;
        break;
      case FlameSignageType.info:
        color = Colors.teal;
        break;
    }
  }

  @override
  FlameSignage clone() {
    return FlameSignage(
      id: id,
      position: vector_math.Vector2(position.x, position.y),
      size: size.clone(),
      signageType: signageType,
      label: label,
      rotation: angle,
      direction: direction,
    );
  }

  @override
  void render(Canvas canvas) {
    // Dependiendo del tipo de señal, dibujamos una forma diferente
    switch (signageType) {
      case FlameSignageType.stop:
        _drawStopSign(canvas);
        break;
      case FlameSignageType.yield:
        _drawTriangleSign(canvas);
        break;
      case FlameSignageType.noParking:
      case FlameSignageType.reserved:
      case FlameSignageType.handicapped:
      case FlameSignageType.info:
        _drawRectangleSign(canvas);
        break;
      case FlameSignageType.exit:
      case FlameSignageType.entrance:
      case FlameSignageType.oneway:
      case FlameSignageType.speed:
        _drawArrowSign(canvas);
        break;
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

  void _drawStopSign(Canvas canvas) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    // Dibujar un octágono
    final path = Path();
    final radius = size.x / 2;
    final sides = 8;
    final angleStep = 2 * math.pi / sides;
    final startAngle = angleStep / 2; // Rotar para que quede derecho

    for (int i = 0; i < sides; i++) {
      final angle = startAngle + i * angleStep;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);

    // Dibujar borde
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(path, borderPaint);

    // Dibujar texto "STOP"
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: size.x * 0.25,
      fontWeight: FontWeight.bold,
    );

    final textSpan = TextSpan(
      text: 'STOP',
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

  void _drawTriangleSign(Canvas canvas) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    // Dibujar un triángulo
    final path = Path();
    final halfWidth = size.x / 2;
    final halfHeight = size.y / 2;

    path.moveTo(0, -halfHeight);
    path.lineTo(halfWidth, halfHeight);
    path.lineTo(-halfWidth, halfHeight);
    path.close();

    canvas.drawPath(path, paint);

    // Dibujar borde
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(path, borderPaint);

    // Dibujar texto "YIELD"
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: size.x * 0.15,
      fontWeight: FontWeight.bold,
    );

    final textSpan = TextSpan(
      text: 'YIELD',
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
      Offset(-textPainter.width / 2, -textPainter.height / 5),
    );
  }

  void _drawRectangleSign(Canvas canvas) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    // Dibujar un rectángulo
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.x,
        height: size.y,
      ),
      paint,
    );

    // Dibujar borde
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.x,
        height: size.y,
      ),
      borderPaint,
    );

    // Dibujar texto según el tipo
    String text = '';
    switch (signageType) {
      case FlameSignageType.noParking:
        text = 'NO\nPARKING';
        break;
      case FlameSignageType.reserved:
        text = 'RESERVED';
        break;
      case FlameSignageType.handicapped:
        text = 'HANDICAPPED';
        break;
      case FlameSignageType.info:
        text = 'INFO';
        break;
      default:
        text = '';
    }

    if (text.isNotEmpty) {
      final textStyle = TextStyle(
        color: Colors.white,
        fontSize: size.x * 0.15,
        fontWeight: FontWeight.bold,
      );

      final textSpan = TextSpan(
        text: text,
        style: textStyle,
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      textPainter.layout(maxWidth: size.x - 10);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
    }
  }

  void _drawArrowSign(Canvas canvas) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    // Dibujar un círculo
    canvas.drawCircle(
      Offset.zero,
      size.x / 2,
      paint,
    );

    // Dibujar borde
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(
      Offset.zero,
      size.x / 2,
      borderPaint,
    );

    // Dibujar flecha
    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final arrowPath = Path();
    final arrowSize = size.x * 0.3;

    // Dirección de la flecha según el tipo
    String arrowText = '';
    switch (signageType) {
      case FlameSignageType.exit:
        arrowPath.moveTo(0, -arrowSize);
        arrowPath.lineTo(arrowSize, 0);
        arrowPath.lineTo(0, arrowSize);
        arrowPath.lineTo(-arrowSize, 0);
        arrowPath.close();
        arrowText = 'EXIT';
        break;
      case FlameSignageType.entrance:
        arrowPath.moveTo(-arrowSize / 2, -arrowSize);
        arrowPath.lineTo(arrowSize / 2, -arrowSize);
        arrowPath.lineTo(arrowSize / 2, arrowSize / 2);
        arrowPath.lineTo(arrowSize, arrowSize / 2);
        arrowPath.lineTo(0, arrowSize);
        arrowPath.lineTo(-arrowSize, arrowSize / 2);
        arrowPath.lineTo(-arrowSize / 2, arrowSize / 2);
        arrowPath.close();
        arrowText = 'ENTER';
        break;
      case FlameSignageType.oneway:
        arrowPath.moveTo(0, -arrowSize);
        arrowPath.lineTo(arrowSize / 2, 0);
        arrowPath.lineTo(arrowSize / 4, 0);
        arrowPath.lineTo(arrowSize / 4, arrowSize);
        arrowPath.lineTo(-arrowSize / 4, arrowSize);
        arrowPath.lineTo(-arrowSize / 4, 0);
        arrowPath.lineTo(-arrowSize / 2, 0);
        arrowPath.close();
        arrowText = 'ONE WAY';
        break;
      case FlameSignageType.speed:
        arrowText = '30';
        break;
      default:
        break;
    }

    canvas.drawPath(arrowPath, arrowPaint);

    // Dibujar texto
    if (arrowText.isNotEmpty) {
      final textStyle = TextStyle(
        color: Colors.white,
        fontSize: size.x * 0.15,
        fontWeight: FontWeight.bold,
      );

      final textSpan = TextSpan(
        text: arrowText,
        style: textStyle,
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      textPainter.layout();

      // Posición del texto según el tipo
      Offset textOffset;
      if (signageType == FlameSignageType.speed) {
        textOffset = Offset(-textPainter.width / 2, -textPainter.height / 2);
      } else {
        textOffset = Offset(-textPainter.width / 2, size.y / 4);
      }

      textPainter.paint(canvas, textOffset);
    }
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