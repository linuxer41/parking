import 'package:flutter/material.dart';
import 'canvas_object.dart';
import 'dart:math' as math;

/// Objeto que representa un texto.
class TextObject extends InfiniteCanvasObject {
  String text;
  TextStyle style;

  TextObject({
    required super.position,
    required this.text,
    required super.color,
    this.style = const TextStyle(color: Colors.black, fontSize: 16),
  }) : super(objectMode: InfiniteCanvasMode.text);

  @override
  void draw(Canvas canvas, Paint paint, Offset canvasOffset, double scale,
      double baseUnitSize) {
    canvas.save();
    canvas.translate(canvasOffset.dx, canvasOffset.dy);
    canvas.scale(scale);
    canvas.translate(
      (position.dx / baseUnitSize).round() * baseUnitSize,
      (position.dy / baseUnitSize).round() * baseUnitSize,
    );
    canvas.rotate(rotation * (math.pi / 180));

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset.zero);

    canvas.restore();
  }

  @override
  Size get size {
    // Calcular el tamaño del texto usando un TextPainter
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.size;
  }

  @override
  bool contains(
      Offset point, Offset canvasOffset, double scale, double baseUnitSize) {
    final transformedPoint = (point - canvasOffset) / scale;
    final rotatedPoint = rotatePoint(transformedPoint - position, -rotation);
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: 16)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return rotatedPoint.dx >= 0 &&
        rotatedPoint.dx <= textPainter.width &&
        rotatedPoint.dy >= 0 &&
        rotatedPoint.dy <= textPainter.height;
  }
}
