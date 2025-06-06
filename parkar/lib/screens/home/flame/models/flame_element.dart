import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

/// Clase base para todos los elementos del estacionamiento en Flame
abstract class FlameElement extends PositionComponent {
  final String id;
  final String type;
  String label;
  bool isSelected = false;
  bool isDraggable = true;
  bool isRotatable = true;
  double opacity = 1.0;
  Color color = Colors.blue;

  FlameElement({
    required this.id,
    required this.type,
    required vector_math.Vector2 position,
    required Vector2 size,
    this.label = '',
    double rotation = 0,
  }) : super(
          position: Vector2(position.x, position.y),
          size: size,
          angle: rotation,
        );

  /// Crea una copia exacta del componente
  FlameElement clone();

  /// Verifica si un punto está dentro del elemento
  bool containsPoint(vector_math.Vector2 point) {
    // Convertir point a Vector2 de Flame
    final flamePoint = Vector2(point.x, point.y);
    
    // Ajustar según la rotación
    final adjustedPoint = _rotatePoint(
      flamePoint, 
      Vector2(position.x, position.y), 
      -angle
    );
    
    // Comprobar si el punto está dentro del rectángulo
    return adjustedPoint.x >= position.x - size.x / 2 &&
           adjustedPoint.x <= position.x + size.x / 2 &&
           adjustedPoint.y >= position.y - size.y / 2 &&
           adjustedPoint.y <= position.y + size.y / 2;
  }

  /// Rotar un punto alrededor de un centro
  Vector2 _rotatePoint(Vector2 point, Vector2 center, double angle) {
    final dx = point.x - center.x;
    final dy = point.y - center.y;
    
    return Vector2(
      center.x + dx * math.cos(angle) - dy * math.sin(angle),
      center.y + dx * math.sin(angle) + dy * math.cos(angle),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final paint = Paint()
      ..color = color.withOpacity(opacity)
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
    
    // Si está seleccionado, dibujar un borde
    if (isSelected) {
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
      
      // Dibujar puntos de control para redimensionar
      final handlePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      final handleBorderPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      
      // Dibujar manijas en las esquinas
      _drawHandle(canvas, Vector2(-size.x/2, -size.y/2), handlePaint, handleBorderPaint);
      _drawHandle(canvas, Vector2(size.x/2, -size.y/2), handlePaint, handleBorderPaint);
      _drawHandle(canvas, Vector2(-size.x/2, size.y/2), handlePaint, handleBorderPaint);
      _drawHandle(canvas, Vector2(size.x/2, size.y/2), handlePaint, handleBorderPaint);
      
      // Dibujar el punto de rotación
      canvas.drawCircle(
        Offset(0, -size.y/2 - 15),
        5.0,
        handlePaint,
      );
      canvas.drawCircle(
        Offset(0, -size.y/2 - 15),
        5.0,
        handleBorderPaint,
      );
      
      // Dibujar línea al punto de rotación
      final linePaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      
      canvas.drawLine(
        Offset(0, -size.y/2),
        Offset(0, -size.y/2 - 15),
        linePaint,
      );
    }
    
    // Dibujar la etiqueta
    if (label.isNotEmpty) {
      final textStyle = TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
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