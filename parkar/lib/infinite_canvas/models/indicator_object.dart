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
          width: 6, // 25 cm de ancho
          height: 2, // 50 cm de alto
          color: type == InidicatorObjectType.exit ? Colors.red : Colors.green,
        );

  @override
  void draw(Canvas canvas, Paint paint, Offset canvasOffset, double scale, double scaledGrid) {
    canvas.save();
    canvas.translate(canvasOffset.dx, canvasOffset.dy);
    canvas.scale(scale);
    canvas.translate(
      (position.dx / scaledGrid).round() * scaledGrid,
      (position.dy / scaledGrid).round() * scaledGrid,
    );
    canvas.rotate(rotation * (math.pi / 180));

    // Dibujar el rectángulo con bordes redondeados
    final rect = Rect.fromLTWH(
      0,
      0,
      width * scaledGrid,
      height * scaledGrid,
    );
    const radius = Radius.circular(8); // Bordes redondeados

    // Color de fondo
    paint.color = color;
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), paint);

    // Dibujar el borde
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), borderPaint);

    // Dibujar el texto
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white, // Texto en blanco
          fontSize: 10, // Tamaño del texto reducido
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.5), // Sombra para mejorar la legibilidad
              blurRadius: 2,
              offset: const Offset(1, 1),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (width * scaledGrid - textPainter.width) / 2,
        (height * scaledGrid - textPainter.height) / 2,
      ),
    );

    canvas.restore();
  }
}