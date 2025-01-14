import 'package:flutter/material.dart';
import 'canvas_object.dart';
import 'dart:math' as math;

import 'grid_object.dart';

class OfficeObject extends GridObject {
  String label;

  OfficeObject({
    super.position = const Offset(0, 0),
    super.color = const Color.fromARGB(255, 220, 169, 169),
    required this.label,
  }) : super(
          width: 4, // 4 metros de ancho
          height: 4, // 4 metros de alto
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

    // Dibujar el rectángulo transparente
    final rect = Rect.fromLTWH(
      0,
      0,
      width * gridSize,
      height * gridSize,
    );
    paint.color = color.withOpacity(0.3); // Transparencia
    paint.style = PaintingStyle.fill;
    canvas.drawRect(rect, paint);

    // Dibujar el borde segmentado
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final dashWidth = 5; // Longitud del segmento
    final dashSpace = 5; // Espacio entre segmentos
    double startX = 0;
    while (startX < width * gridSize) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        borderPaint,
      );
      startX += dashWidth + dashSpace;
    }
    startX = 0;
    while (startX < width * gridSize) {
      canvas.drawLine(
        Offset(startX, height * gridSize),
        Offset(startX + dashWidth, height * gridSize),
        borderPaint,
      );
      startX += dashWidth + dashSpace;
    }
    double startY = 0;
    while (startY < height * gridSize) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashWidth),
        borderPaint,
      );
      startY += dashWidth + dashSpace;
    }
    startY = 0;
    while (startY < height * gridSize) {
      canvas.drawLine(
        Offset(width * gridSize, startY),
        Offset(width * gridSize, startY + dashWidth),
        borderPaint,
      );
      startY += dashWidth + dashSpace;
    }

    // Dibujar el texto
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.black,
          fontSize: (width * gridSize) / 4,
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