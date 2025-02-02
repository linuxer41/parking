
import 'package:flutter/material.dart';

class TransformComponent {
  double x;
  double y;
  double z;
  Size size;
  double scale;
  double rotation;

  TransformComponent({
    required this.x,
    required this.y,
    this.z = 0.0,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.size = const Size(1, 1),
  });
}
    