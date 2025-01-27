import 'package:flutter/material.dart';
import 'package:parkar/infinite_canvas/widgets/canvas_controller.dart';
import '../models/canvas_object.dart';
import '../models/grid_object.dart';

/// Pintor personalizado para el lienzo.
class InfiniteCanvasPainter extends CustomPainter {
  final InfiniteCanvasController controller;
  final Color gridColor;

  InfiniteCanvasPainter({
    required this.gridColor,
    required this.controller,
  });

@override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(controller.canvasOffset.dx, controller.canvasOffset.dy);
    canvas.scale(controller.zoom);

    if (controller.showGrid) {
      _drawGrid(canvas, size);
    }

    for (var object in controller.objects) {
      if (controller.selectedObjects.lastOrNull == object) {
        if (object is GridObject) {
          object.selected = true;
        }
      } else {
        if (object is GridObject) {
          object.selected = false;
        }
      }

      // Dibujar el objeto con animación de movimiento
      if (controller.isAnimating.value && object == controller.objects.last) {
        final startPosition = Offset(size.width / 2, size.height / 2); // Centro de la pantalla
        final endPosition = object.position;

        // Interpolación lineal para la posición
        final animatedPosition = Offset.lerp(startPosition, endPosition, 0.5)!;

        object.draw(canvas, Paint()..color = object.color, animatedPosition, controller.gridSize, 1.0);
      } else {
        object.draw(canvas, Paint()..color = object.color, Offset.zero, controller.gridSize, 1.0);
      }
    }

    canvas.restore();
  }
  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1 / controller.zoom;

    final startX = (-controller.canvasOffset.dx / controller.zoom / controller.gridSize).floor() * controller.gridSize;
    final endX =
        ((size.width - controller.canvasOffset.dx) / controller.zoom / controller.gridSize).ceil() * controller.gridSize;
    final startY = (-controller.canvasOffset.dy / controller.zoom / controller.gridSize).floor() * controller.gridSize;
    final endY =
        ((size.height - controller.canvasOffset.dy) / controller.zoom / controller.gridSize).ceil() * controller.gridSize;

    for (double x = startX; x <= endX; x += controller.gridSize) {
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, endY),
        gridPaint,
      );
    }

    for (double y = startY; y <= endY; y += controller.gridSize) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(endX, y),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(InfiniteCanvasPainter oldDelegate) {
    return true;
  }
}
