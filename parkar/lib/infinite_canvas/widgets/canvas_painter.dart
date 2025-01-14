import 'package:flutter/material.dart';
import '../models/canvas_object.dart';

/// Pintor personalizado para el lienzo.
class InfiniteCanvasPainter extends CustomPainter {
  final List<InfiniteCanvasObject> objects;
  final List<InfiniteCanvasObject> selectedObjects;
  final double gridSize;
  final double zoom;
  final Offset canvasOffset;
  final Size viewportSize;
  final double scalePerGrid;
  final Color gridColor;
  final List<Offset> freeFormPoints;

  InfiniteCanvasPainter({
    required this.objects,
    required this.selectedObjects,
    required this.gridSize,
    required this.zoom,
    required this.canvasOffset,
    required this.viewportSize,
    required this.scalePerGrid,
    required this.gridColor,
    required this.freeFormPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(canvasOffset.dx, canvasOffset.dy);
    canvas.scale(zoom);

    _drawGrid(canvas, size);

    for (var object in objects) {
      object.draw(canvas, Paint()..color = object.color, Offset.zero, 1.0, gridSize);

      if (selectedObjects.contains(object)) {
        final borderPaint = Paint()
          ..color = const Color.fromARGB(255, 3, 222, 69)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 / zoom;
        object.draw(canvas, borderPaint, Offset.zero, 1.0, gridSize);
      }
    }

    if (freeFormPoints.isNotEmpty) {
      final path = Path();
      path.moveTo(freeFormPoints[0].dx, freeFormPoints[0].dy);
      for (var point in freeFormPoints) {
        path.lineTo(point.dx, point.dy);
      }
      final paint = Paint()
        ..color = Colors.purple
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 / zoom;
      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  // void _drawGrid(Canvas canvas, Size size) {
  //   final paint = Paint()
  //     ..color = gridColor
  //     ..strokeWidth = 1 / zoom;

  //   final startX = -canvasOffset.dx / zoom;
  //   final endX = (size.width - canvasOffset.dx) / zoom;
  //   final startY = -canvasOffset.dy / zoom;
  //   final endY = (size.height - canvasOffset.dy) / zoom;

  //   for (double x = (startX / gridSize).floor() * gridSize;
  //       x <= endX;
  //       x += gridSize) {
  //     canvas.drawLine(Offset(x, startY), Offset(x, endY), paint);
  //   }

  //   for (double y = (startY / gridSize).floor() * gridSize;
  //       y <= endY;
  //       y += gridSize) {
  //     canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
  //   }
  // }
  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1 / zoom;

    final startX = (-canvasOffset.dx / zoom / gridSize).floor() * gridSize;
    final endX = ((size.width - canvasOffset.dx) / zoom / gridSize).ceil() * gridSize;
    final startY = (-canvasOffset.dy / zoom / gridSize).floor() * gridSize;
    final endY = ((size.height - canvasOffset.dy) / zoom / gridSize).ceil() * gridSize;

    for (double x = startX; x <= endX; x += gridSize) {
      canvas.drawLine(Offset(x, startY), Offset(x, endY), paint);
    }

    for (double y = startY; y <= endY; y += gridSize) {
      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
    }
  }

  @override
  bool shouldRepaint(InfiniteCanvasPainter oldDelegate) {
    return true;
  }
}
