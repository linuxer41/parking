import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'grid_object.dart';

enum SpotObjectType { car, bus, truck, van, motorcycle, bicycle }
enum SpotObjectCategory { standart, vip, electric, handicap }

class SpotObject extends GridObject {
  final SpotObjectType type;
  final SpotObjectCategory category;
  String label;
  bool isFree;

  // Tamaños predefinidos para cada tipo de spot
  static const Map<SpotObjectType, Size> spotSizes = {
    SpotObjectType.car: Size(2.5, 5), // 2.5m x 5m
    SpotObjectType.bus: Size(3, 12),  // 3m x 12m
    SpotObjectType.truck: Size(3, 8), // 3m x 8m
    SpotObjectType.van: Size(2.5, 6), // 2.5m x 6m
    SpotObjectType.motorcycle: Size(1, 2), // 1m x 2m
    SpotObjectType.bicycle: Size(0.8, 1.5), // 0.8m x 1.5m
  };

  // Colores predefinidos para cada categoría
  static const Map<SpotObjectCategory, Color> categoryColors = {
    SpotObjectCategory.standart: Colors.blue,
    SpotObjectCategory.vip: Colors.purple,
    SpotObjectCategory.electric: Colors.green,
    SpotObjectCategory.handicap: Colors.orange,
  };

  SpotObject({
    super.position = const Offset(0, 0),
    this.label = "",
    this.isFree = true,
    required this.type,
    required this.category,
  }) : super(
          width: spotSizes[type]!.width, // Tamaño basado en el tipo
          height: spotSizes[type]!.height, // Tamaño basado en el tipo
          color: categoryColors[category]!, // Color basado en la categoría
        );

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

    // Dibujar el rectángulo con bordes redondeados
    final rect = Rect.fromLTWH(
      0,
      0,
      width * gridSize,
      height * gridSize,
    );
    final radius = Radius.circular(10); // Bordes redondeados

    // Color de fondo basado en la categoría
    paint.color = isFree ? color : Colors.grey; // Si no está libre, se marca en gris
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), paint);

    // Dibujar el borde con sombra
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), borderPaint);

    // Dibujar un icono o símbolo según el tipo de spot
    _drawSpotIcon(canvas, rect);

    // Dibujar el texto
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: (width * gridSize) / 4,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 2,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (width * gridSize - textPainter.width) / 2,
        (height * gridSize - textPainter.height) / 2,
      ),
    );

    canvas.restore();
  }

  void _drawSpotIcon(Canvas canvas, Rect rect) {
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    switch (type) {
      case SpotObjectType.car:
        _drawCarIcon(canvas, rect, iconPaint);
        break;
      default:
        _drawBusIcon(canvas, rect, iconPaint);
        break;
        
    }
  }

  void _drawCarIcon(Canvas canvas, Rect rect, Paint paint) {
    // Dibujar un icono de auto simple
    final path = Path();
    path.moveTo(rect.left + rect.width * 0.2, rect.top + rect.height * 0.5);
    path.lineTo(rect.left + rect.width * 0.8, rect.top + rect.height * 0.5);
    path.lineTo(rect.left + rect.width * 0.7, rect.top + rect.height * 0.7);
    path.lineTo(rect.left + rect.width * 0.3, rect.top + rect.height * 0.7);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawBusIcon(Canvas canvas, Rect rect, Paint paint) {
    // Dibujar un icono de bus simple
    final path = Path();
    path.addRect(Rect.fromLTWH(
      rect.left + rect.width * 0.1,
      rect.top + rect.height * 0.3,
      rect.width * 0.8,
      rect.height * 0.4,
    ));
    canvas.drawPath(path, paint);
  }

  // Métodos similares para _drawTruckIcon, _drawVanIcon, _drawMotorcycleIcon, _drawBicycleIcon
}