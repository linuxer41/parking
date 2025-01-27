import 'package:flutter/material.dart';

Paint getSelectedIndicatorPaint(Color color, bool isSelected) {
  final borderColor = isSelected ? const Color.fromARGB(255, 104, 81, 247) : color;

  final paint = Paint()
    ..color = borderColor.withAlpha(isSelected ? 255 : 255)
    ..style = PaintingStyle.stroke
    ..strokeWidth = isSelected ? 2.5 : 1.5; // Grosor del borde

  // Agregar sombra si está seleccionado
  if (isSelected) {
    paint.maskFilter = const MaskFilter.blur(BlurStyle.solid, 5); // Efecto de sombra
  }

  return paint;
}