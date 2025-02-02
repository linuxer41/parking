// utils/fps_monitor.dart
import 'package:flutter/material.dart';

class FPSMonitor {
  int _frameCount = 0;
  double _fps = 0;
  DateTime _lastTime = DateTime.now();
  final ValueNotifier<double> fpsNotifier = ValueNotifier(0.0);

  void update() {
    _frameCount++;
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(_lastTime);
    
    if (difference.inSeconds >= 1) {
      _fps = _frameCount / difference.inSeconds;
      _frameCount = 0;
      _lastTime = now;
      fpsNotifier.value = _fps;
    }
  }

  double get fps => _fps;
}