// game_object.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameObject extends PositionComponent {
  final Color color;

  GameObject({
    required Vector2 position,
    required Vector2 size,
    required this.color,
  }) : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Dibujar el objeto como un rectángulo
    final paint = Paint()..color = color;
    canvas.drawRect(size.toRect(), paint);

    // Dibujar la posición del objeto en texto
    final textStyle = TextStyle(color: Colors.black, fontSize: 12);
    final textPainter = TextPainter(
      text: TextSpan(
        text: "(${position.x.toStringAsFixed(1)}, ${position.y.toStringAsFixed(1)})",
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(5, 5));
  }

  bool containsPoint(Vector2 point) {
    return toRect().contains(point.toOffset());
  }
}