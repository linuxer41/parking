import 'package:flutter/material.dart';
import 'canvas_object.dart';
import 'dart:math' as math;

import 'helpers/selected_inidcator.dart';

abstract class GridObject extends InfiniteCanvasObject {
  GridObject({
    super.position,
    super.color,
    super.scale,
    super.size,
    super.rotation,
    super.id,
    super.objectType = InfiniteCanvasObjectType.gridObject,
  });

  @override
  void draw(
    Canvas canvas,
    Paint paint,
    Offset canvasOffset,
    double gridSize,
    double scale,
  ) {
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
      size.width * gridSize,
      size.height * gridSize,
    );

    paint.color = color;
    canvas.drawRect(rect, paint);

    const radius = Radius.circular(4);
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), paint);

    // Dibujar el borde
    Paint borderPaint = getSelectedIndicatorPaint(color, selected);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), borderPaint);

    drawContent(canvas, paint, rect, canvasOffset, gridSize, scale);

    canvas.restore();
  }

  void drawContent(Canvas canvas, Paint paint, Rect rect, Offset canvasOffset,
      double gridSize, double scale);

  @override
  bool contains(
    Offset point,
    Offset canvasOffset,
    double gridSize,
    double scale,
  ) {
    final transformedPoint = (point - canvasOffset) / scale;
    final rotatedPoint = rotatePoint(transformedPoint - position, -rotation);
    return rotatedPoint.dx >= 0 &&
        rotatedPoint.dx <= size.width * gridSize &&
        rotatedPoint.dy >= 0 &&
        rotatedPoint.dy <= size.height * gridSize;
  }
}
