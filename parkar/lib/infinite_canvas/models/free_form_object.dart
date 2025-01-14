import 'package:flutter/material.dart';
import 'canvas_object.dart';
import 'dart:math' as math;

/// Objeto que representa una forma libre.
class FreeFormObject extends InfiniteCanvasObject {
  List<Offset> points;

  FreeFormObject({
    required super.position,
    required super.color,
    required this.points,
  }) : super(objectMode: InfiniteCanvasMode.freeForm);

  @override
  void draw(Canvas canvas, Paint paint, Offset canvasOffset, double scale, double gridSize) {
    canvas.save();
    canvas.translate(canvasOffset.dx, canvasOffset.dy);
    canvas.scale(scale);
    canvas.translate(position.dx, position.dy);
    canvas.rotate(rotation * (math.pi / 180));

    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      for (var point in points) {
        path.lineTo(point.dx, point.dy);
      }
      path.close();
    }

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawPath(path, paint);

    canvas.restore();
  }

  @override
  bool contains(Offset point, Offset canvasOffset, double scale, double gridSize) {
    final transformedPoint = (point - canvasOffset) / scale;
    final rotatedPoint = rotatePoint(transformedPoint - position, -rotation);

    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      for (var point in points) {
        path.lineTo(point.dx, point.dy);
      }
      path.close();
    }

    return path.contains(rotatedPoint);
  }
}
