import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Enum que define los modos de edición y tipos de objetos.
enum InfiniteCanvasMode { gridObject, text, line, freeForm }

/// Clase base para los objetos del lienzo.
abstract class InfiniteCanvasObject {
  final InfiniteCanvasMode objectMode;
  Offset position;
  Color color;
  double rotation;
  

  InfiniteCanvasObject({
    required this.position,
    required this.color,
    this.rotation = 0.0,
    required this.objectMode,
  });

  void draw(Canvas canvas, Paint paint, Offset canvasOffset, double scale,
      double gridSize);

  bool contains(Offset point, Offset canvasOffset, double scale, double gridSize);

  Offset rotatePoint(Offset point, double angle) {
    final radians = angle * (math.pi / 180);
    final cosTheta = math.cos(radians);
    final sinTheta = math.sin(radians);
    return Offset(
      point.dx * cosTheta - point.dy * sinTheta,
      point.dx * sinTheta + point.dy * cosTheta,
    );
  }
}
