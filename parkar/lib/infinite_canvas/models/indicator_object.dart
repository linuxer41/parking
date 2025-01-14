import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'grid_object.dart';

enum InidicatorObjectType { exit, entrance }

class IndicatorObject extends GridObject {
  String label;
  InidicatorObjectType type;

  IndicatorObject({
    required this.label,
    required this.type,
    super.position = const Offset(0, 0),
  }) : super(
          width: 0.25, // 25 cm de ancho
          height: 0.5, // 50 cm de alto
          color: type == InidicatorObjectType.exit ? Colors.red : Colors.green,
        );

  @override
  void draw(Canvas canvas, Paint paint, Offset canvasOffset, double scale, double gridSize) {
    canvas.save();
    canvas.translate(canvasOffset.dx, canvasOffset.dy);
    canvas.scale(scale);
    canvas.translate(
      (position.dx / gridSize).round() * gridSize,
      (position.dy / gridSize).round() * gridSize,
    );
    canvas.rotate(rotation * (math.pi / 180));

    // Dibujar el rectángulo
    final rect = Rect.fromLTWH(
      0,
      0,
      width * gridSize,
      height * gridSize,
    );
    paint.color = color;
    paint.style = PaintingStyle.fill;
    canvas.drawRect(rect, paint);

    // Dibujar el borde
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(rect, borderPaint);

    // Dibujar el texto
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: (width * gridSize) / 2,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (width * gridSize - textPainter.width) / 2,
        (height * gridSize - textPainter.height) / 2,
      ),
    );

    canvas.restore();
  }
}