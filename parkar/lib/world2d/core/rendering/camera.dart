
import 'package:flutter/material.dart';

class Camera {
  double x = 0;
  double y = 0;
  double zoom = 1.0;

  void translate(double dx, double dy) {
    x += dx;
    y += dy;
  }

  void zoomIn() {
    zoom += 0.1;
  }

  void zoomOut() {
    zoom -= 0.1;
  }
}
    