import 'package:flutter/material.dart';
import 'canvas_object.dart';
import 'dart:math' as math;

abstract class GridObject extends InfiniteCanvasObject {
  double width;
  double height;

  GridObject({
    required super.position,
    required super.color,
    required this.width,
    required this.height,
  }) : super(objectMode: InfiniteCanvasMode.gridObject);

  @override
  void draw(Canvas canvas, Paint paint, Offset canvasOffset, double scale,
      double gridSize) {
    canvas.save();
    canvas.translate(canvasOffset.dx, canvasOffset.dy);
    canvas.scale(scale);
    canvas.translate(
      (position.dx / gridSize).round() * gridSize,
      (position.dy / gridSize).round() * gridSize,
    );
    canvas.rotate(rotation * (math.pi / 180));

    final rect = Rect.fromLTWH(
      0,
      0,
      width * gridSize,
      height * gridSize,
    );
    paint.color = color;
    canvas.drawRect(rect, paint);

    canvas.restore();
  }

  @override
  bool contains(Offset point, Offset canvasOffset, double scale, double gridSize) {
    final transformedPoint = (point - canvasOffset) / scale;
    final rotatedPoint = rotatePoint(transformedPoint - position, -rotation);
    return rotatedPoint.dx >= 0 &&
        rotatedPoint.dx <= width * gridSize &&
        rotatedPoint.dy >= 0 &&
        rotatedPoint.dy <= height * gridSize;
  }
}
