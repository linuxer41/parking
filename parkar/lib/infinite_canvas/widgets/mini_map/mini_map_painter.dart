import 'package:flutter/material.dart';
import '../../models/canvas_object.dart';

/// Pintor personalizado para el minimapa.
class MiniMapPainter extends CustomPainter {
  final List<InfiniteCanvasObject> objects;
  final Offset canvasOffset;
  final double zoom;
  final Size viewportSize;
  final double gridSize;

  MiniMapPainter({
    required this.objects,
    required this.canvasOffset,
    required this.zoom,
    required this.viewportSize,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final minimapScale = size.width / 1000;

    final backgroundPaint = Paint()..color = Colors.white.withOpacity(0.8);
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // final gridPaint = Paint()
    //   ..color = Colors.grey.withOpacity(0.3)
    //   ..strokeWidth = 1;
    // for (double x = 0; x <= size.width; x += gridSize * minimapScale) {
    //   canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    // }
    // for (double y = 0; y <= size.height; y += gridSize * minimapScale) {
    //   canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    // }

    for (var object in objects) {
      final position = Offset(
        object.position.dx * minimapScale,
        object.position.dy * minimapScale,
      );

      if (position.dx >= 0 &&
          position.dx <= size.width &&
          position.dy >= 0 &&
          position.dy <= size.height) {
        object.draw(canvas, Paint()..color = object.color, position, gridSize,
            minimapScale);
      }
    }

    final viewPortScale = minimapScale / 5;

    final viewportRect = Rect.fromLTWH(
      -canvasOffset.dx * viewPortScale,
      -canvasOffset.dy * viewPortScale,
      viewportSize.width * viewPortScale / zoom,
      viewportSize.height * viewPortScale / zoom,
    );

    final viewportPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(viewportRect, viewportPaint);
  }

  @override
  bool shouldRepaint(MiniMapPainter oldDelegate) {
    return true;
  }
}
