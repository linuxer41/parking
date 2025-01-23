import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'grid_object.dart';

class OfficeObject extends GridObject {
  String label;

  OfficeObject({
    super.position = const Offset(0, 0),
    super.color = const Color.fromARGB(128, 103, 4, 242), // Morado suave
    required this.label,
  }) : super(
          width: 6, // 3 metros de ancho
          height: 6, // 3 metros de alto
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
    const radius = Radius.circular(10); // Bordes redondeados

    // Color de fondo con transparencia
    paint.color = color.withOpacity(0.3); // Transparencia
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), paint);

    // Dibujar el borde segmentado con bordes redondeados
    final borderPaint = Paint()
      ..color = const Color.fromARGB(255, 0, 0, 0).withOpacity(0.8) // Color del borde
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const dashWidth = 5; // Longitud del segmento
    const dashSpace = 5; // Espacio entre segmentos

    // Función para dibujar bordes segmentados con esquinas redondeadas
    void drawDashedRRect(RRect rrect) {
      final path = Path();
      final rect = rrect.outerRect;
      final radii = rrect.tlRadius;

      // Dibujar segmentos en los 4 bordes
      void drawDashedLine(Offset start, Offset end) {
        double distance = (end - start).distance;
        double step = (dashWidth + dashSpace).toDouble();
        for (double i = 0; i < distance; i += step) {
          final p1 = start + (end - start) * (i / distance);
          final p2 = start + (end - start) * ((i + dashWidth) / distance);
          path.moveTo(p1.dx, p1.dy);
          path.lineTo(p2.dx, p2.dy);
        }
      }

      // Borde superior
      drawDashedLine(
        Offset(rect.left + radii.x, rect.top),
        Offset(rect.right - radii.x, rect.top),
      );

      // Esquina superior derecha
      path.arcTo(
        Rect.fromCircle(
          center: Offset(rect.right - radii.x, rect.top + radii.y),
          radius: radii.x,
        ),
        -math.pi / 2,
        math.pi / 2,
        false,
      );

      // Borde derecho
      drawDashedLine(
        Offset(rect.right, rect.top + radii.y),
        Offset(rect.right, rect.bottom - radii.y),
      );

      // Esquina inferior derecha
      path.arcTo(
        Rect.fromCircle(
          center: Offset(rect.right - radii.x, rect.bottom - radii.y),
          radius: radii.x,
        ),
        0,
        math.pi / 2,
        false,
      );

      // Borde inferior
      drawDashedLine(
        Offset(rect.right - radii.x, rect.bottom),
        Offset(rect.left + radii.x, rect.bottom),
      );

      // Esquina inferior izquierda
      path.arcTo(
        Rect.fromCircle(
          center: Offset(rect.left + radii.x, rect.bottom - radii.y),
          radius: radii.x,
        ),
        math.pi / 2,
        math.pi / 2,
        false,
      );

      // Borde izquierdo
      drawDashedLine(
        Offset(rect.left, rect.bottom - radii.y),
        Offset(rect.left, rect.top + radii.y),
      );

      // Esquina superior izquierda
      path.arcTo(
        Rect.fromCircle(
          center: Offset(rect.left + radii.x, rect.top + radii.y),
          radius: radii.x,
        ),
        math.pi,
        math.pi / 2,
        false,
      );

      canvas.drawPath(path, borderPaint);
    }

    // Dibujar el borde segmentado con esquinas redondeadas
    drawDashedRRect(RRect.fromRectAndRadius(rect, radius));

    // Dibujar el texto
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white, // Texto en blanco
          fontSize: 10, // Tamaño de fuente más pequeño
          fontWeight: FontWeight.normal,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.5), // Sombra del texto
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