import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:uuid/uuid.dart';

/// Enum que define los modos de edición y tipos de objetos.
enum InfiniteCanvasObjectType { gridObject, text, line, freeForm }

/// Clase base para los objetos del lienzo.
abstract class InfiniteCanvasObject {
  final InfiniteCanvasObjectType objectType;
  final key = GlobalKey();
  final String id;
  Offset position;
  Color color;
  double rotation;
  double scale;
  Size size;
  bool selected = false;

  InfiniteCanvasObject({
    Offset? position,
    Color? color,
    double? rotation,
    double? scale,
    Size? size,
    String? id,
    required this.objectType,
  })  : id = id ?? const Uuid().v4(), // Inicializa id en el cuerpo
        position = position ?? Offset.zero, // Valor por defecto sin const
        color = color ?? const Color.fromARGB(255, 154, 1, 250),
        rotation = rotation ?? 0.0,
        scale = scale ?? 1.0,
        size = size ?? const Size(1, 1);

  // InfiniteCanvasObject copyWith({
  //   String? id,
  //   Offset? position,
  //   Color? color,
  //   double? rotation,
  //   double? scale,
  //   Size? size,
  // });

  void draw(Canvas canvas, Paint paint, Offset canvasOffset, double gridSize,
      double scale);

  bool contains(
      Offset point, Offset canvasOffset, double gridSize, double scale);

  Offset rotatePoint(Offset point, double angle) {
    final radians = angle * (math.pi / 180);
    final cosTheta = math.cos(radians);
    final sinTheta = math.sin(radians);
    return Offset(
      point.dx * cosTheta - point.dy * sinTheta,
      point.dx * sinTheta + point.dy * cosTheta,
    );
  }

  void rotate(double angle) {
    rotation += angle;
  }

  void scalate(double scale) {
    this.scale *= scale;
  }

  void translate(Offset offset) {
    position += offset;
  }

  void resize(Size size) {
    this.size = size;
  }

  void select() {
    selected = !selected;
  }
}
