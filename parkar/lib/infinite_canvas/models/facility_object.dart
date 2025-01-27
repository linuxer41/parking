import 'package:flutter/material.dart';
import 'package:parkar/infinite_canvas/models/canvas_object.dart';
import 'dart:math' as math;

import 'grid_object.dart';
import 'helpers/selected_inidcator.dart';

enum FacilityObjectType { office, elevator, stairs, bathroom }

FacilityObjectType intToFacilityObjectType(int value) {
  if (value >= 0 && value < FacilityObjectType.values.length) {
    return FacilityObjectType.values[value];
  } else {
    return FacilityObjectType.office;
  }
}

class FacilityObject extends GridObject {
  final FacilityObjectType type;
  final String label;

  // Tamaños predefinidos para cada tipo de instalación
  static const Map<FacilityObjectType, Size> facilitySizes = {
    FacilityObjectType.office: Size(8, 8), // 8x8 metros
    FacilityObjectType.elevator: Size(4, 4), // 4x4 metros
    FacilityObjectType.stairs: Size(6, 6), // 6x6 metros
    FacilityObjectType.bathroom: Size(6, 4), // 6x4 metros
  };

  // Colores predefinidos para cada tipo de instalación
  static const Map<FacilityObjectType, Color> facilityColors = {
    FacilityObjectType.office: Colors.greenAccent, // Azul suave
    FacilityObjectType.elevator: Color(0xFFDAA520), // Dorado
    FacilityObjectType.stairs: Color(0xFF32CD32), // Verde lima
    FacilityObjectType.bathroom: Color(0xFFFF6347), // Coral
  };

  // Etiquetas predefinidas para cada tipo de instalación
  static const Map<FacilityObjectType, String> facilityLabels = {
    FacilityObjectType.office: 'Oficina',
    FacilityObjectType.elevator: 'Ascensor',
    FacilityObjectType.stairs: 'Gradas',
    FacilityObjectType.bathroom: 'Baño',
  };

  FacilityObject({
    super.position = const Offset(0, 0),
    super.id,
    required this.type,
    String? customLabel, // Etiqueta personalizada (opcional)
  })  : label = customLabel ??
            facilityLabels[
                type]!, // Usar etiqueta predefinida si no se proporciona una personalizada
        super(
          size: Size(facilitySizes[type]!.width, facilitySizes[type]!.height),
          color: facilityColors[type]!,
        );

  @override
  void drawContent(
    Canvas canvas,
    Paint paint,
    Rect rect,
    Offset canvasOffset,
    double gridSize,
    double scale,
  ) {
    // Dibujar el texto
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white, // Texto en blanco
          fontSize: 10, // Tamaño de fuente más pequeño
          fontWeight: FontWeight.normal,
          shadows: [
            Shadow(
              color: Colors.black.withAlpha(128), // Sombra del texto
              blurRadius: 2,
              offset: const Offset(1, 1),
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
        (size.width * gridSize - textPainter.width) / 2,
        (size.height * gridSize - textPainter.height) / 2,
      ),
    );
  }

}
