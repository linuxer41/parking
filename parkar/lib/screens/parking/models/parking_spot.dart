import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;
import 'dart:math' show min;

import '../utils/drawing_utils.dart';
import 'enums.dart';
import 'parking_elements.dart';

/// Clase que representa un espacio de estacionamiento
class ParkingSpot extends ParkingElement {
  // Tipo de espacio (auto, moto, camión)
  final SpotType type;

  // Categoría del espacio (normal, discapacitado, reservado, vip)
  final SpotCategory category;

  // Etiqueta para mostrar en el UI
  @override
  final String label;

  // Estado de ocupación
  bool _isOccupied;

  // Datos del vehículo estacionado
  String? vehiclePlate;
  String? vehicleColor;
  DateTime? entryTime;
  DateTime? exitTime;

  // Constructor
  ParkingSpot({
    required super.id,
    required super.position,
    required this.type,
    required this.label,
    this.category = SpotCategory.normal,
    bool isOccupied = false,
    this.vehiclePlate,
    this.vehicleColor,
    this.entryTime,
    this.exitTime,
    super.rotation,
    super.scale,
    super.isVisible,
    super.isLocked,
    super.isSelected,
  })  : _isOccupied = isOccupied;

  // Getters y setters
  bool get isOccupied => _isOccupied;
  set isOccupied(bool value) {
    if (_isOccupied != value) {
      _isOccupied = value;
      notifyListeners();
    }
  }

  // Obtener tiempo de estacionamiento en minutos
  int get parkingTimeMinutes {
    if (!_isOccupied || entryTime == null) return 0;

    final endTime = exitTime ?? DateTime.now();
    return endTime.difference(entryTime!).inMinutes;
  }

  // Obtener tiempo de estacionamiento formateado
  String get formattedParkingTime {
    final minutes = parkingTimeMinutes;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0) {
      return '$hours h ${remainingMinutes.toString().padLeft(2, '0')} min';
    } else {
      return '$remainingMinutes min';
    }
  }

  @override
  Size getSize() {
    final visuals = ElementProperties.spotVisuals[type]!;
    return Size(visuals.width, visuals.height);
  }

  @override
  void render(Canvas canvas, dynamic renderer) {
    final ElementVisuals visuals = ElementProperties.spotVisuals[type]!;
    final ElementVisuals categoryVisuals =
        ElementProperties.spotCategoryVisuals[category]!;

    final Size size = getSize();
    final double width = size.width;
    final double height = size.height;

    // Definir el rectángulo base
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: width,
      height: height,
    );

    // Obtener el color apropiado según categoría y tipo
    final Color baseColor = _getSpotColor();

    // Modificar el color según la ocupación
    final Color color = isOccupied
        ? HSLColor.fromColor(Colors.red).withLightness(0.4).toColor()
        : baseColor;

    // Dibujar sombra debajo del elemento
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

    // Usar RRect para esquinas redondeadas modernas
    final rrect = RRect.fromRectAndRadius(
      rect.translate(2, 2),
      const Radius.circular(8.0),
    );

    canvas.drawRRect(rrect, shadowPaint);

    // Gradiente moderno según estado de ocupación
    final Gradient gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isOccupied
          ? [
              HSLColor.fromColor(color).withLightness(0.5).toColor(),
              color,
              HSLColor.fromColor(color).withLightness(0.3).toColor(),
            ]
          : [
              HSLColor.fromColor(color)
                  .withLightness((HSLColor.fromColor(color).lightness + 0.2)
                      .clamp(0.0, 1.0))
                  .toColor(),
              color,
              HSLColor.fromColor(color)
                  .withLightness((HSLColor.fromColor(color).lightness - 0.1)
                      .clamp(0.0, 1.0))
                  .toColor(),
            ],
      stops: const [0.0, 0.6, 1.0],
    );

    final mainPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    // Dibujar rectángulo principal con bordes redondeados
    final mainRRect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(8.0),
    );

    canvas.drawRRect(mainRRect, mainPaint);

    // Dibujar un borde con brillo (diferente según ocupación)
    final borderPaint = Paint()
      ..color = isOccupied
          ? HSLColor.fromColor(Colors.red).withLightness(0.6).toColor()
          : HSLColor.fromColor(color)
              .withLightness(
                  (HSLColor.fromColor(color).lightness + 0.3).clamp(0.0, 1.0))
              .toColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = isOccupied ? 2.0 : 1.5;

    canvas.drawRRect(mainRRect, borderPaint);

    // Dibujar icono apropiado para el tipo de spot
    IconData iconData;

    // Determinar icono según categoría y tipo
    if (category == SpotCategory.disabled) {
      iconData = Icons.accessible;
    } else if (category == SpotCategory.vip) {
      iconData = Icons.star;
    } else if (category == SpotCategory.reserved) {
      iconData = Icons.bookmark;
    } else {
      // Según tipo de vehículo
      switch (type) {
        case SpotType.motorcycle:
          iconData = Icons.motorcycle;
          break;
        case SpotType.truck:
          iconData = Icons.local_shipping;
          break;
        default:
          iconData = Icons.directions_car;
      }
    }

    // Dibujar el icono centrado y con buen tamaño
    drawIcon(
      canvas,
      iconData,
      Size(width * 0.5, height * 0.3),
      Colors.white.withOpacity(0.8),
      1.2,
    );

    // Si el spot está ocupado, mostrar indicador moderno
    if (isOccupied) {
      // Dibujar un indicador de ocupado moderno
      // Un indicador visual más claro en la parte superior
      final stateBgPaint = Paint()
        ..color = Colors.red.withOpacity(0.8)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
              -width / 2 + 8, -height / 2 + 8, width / 2 - 8, -height / 2 + 26),
          const Radius.circular(4.0),
        ),
        stateBgPaint,
      );

      // Dibujar el texto "OCUPADO"
      final textSpan = const TextSpan(
        text: "OCUPADO",
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -height / 2 + 9),
      );

      // Mostrar tiempo de ocupación si existe
      if (entryTime != null) {
        final timeSpan = TextSpan(
          text: formattedParkingTime,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        );

        final timePainter = TextPainter(
          text: timeSpan,
          textDirection: TextDirection.ltr,
        );

        timePainter.layout();
        timePainter.paint(
          canvas,
          Offset(-timePainter.width / 2, height * 0.2),
        );
      }
    } else {
      // Si está disponible, mostrar indicador de disponible
      final statusText = category == SpotCategory.normal
          ? "DISPONIBLE"
          : categoryVisuals.label.toUpperCase();
      final textSpan = TextSpan(
        text: statusText,
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, height * 0.1),
      );
    }

    // ETIQUETA DENTRO DEL ELEMENTO (en la parte inferior)
    if (label.isNotEmpty) {
      _renderInternalLabel(canvas, rect);
    }

    // Dibujar indicador de selección si está seleccionado
    if (isSelected) {
      DrawingUtils.drawSelectionIndicator(canvas, rect, 8.0);
    }
  }

  /// Método auxiliar para dibujar la etiqueta dentro del elemento
  void _renderInternalLabel(Canvas canvas, Rect elementRect) {
    // Crear el área para la etiqueta en la parte inferior del elemento
    final labelRect = Rect.fromLTRB(
      elementRect.left + 4,
      elementRect.bottom - 24,
      elementRect.right - 4,
      elementRect.bottom - 4,
    );

    // Fondo semitransparente para la etiqueta
    final labelBgPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, const Radius.circular(4.0)),
      labelBgPaint,
    );

    // Texto de la etiqueta
    final textSpan = TextSpan(
      text: label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout(maxWidth: labelRect.width - 8);

    // Centrar el texto en el área de etiqueta
    textPainter.paint(
      canvas,
      Offset(
        labelRect.left + (labelRect.width - textPainter.width) / 2,
        labelRect.top + (labelRect.height - textPainter.height) / 2,
      ),
    );
  }

  /// Obtiene el color apropiado para el spot según su categoría y tipo
  Color _getSpotColor() {
    // Para spots, usar el color basado en la categoría
    switch (category) {
      case SpotCategory.disabled:
        return ElementProperties.purple;
      case SpotCategory.vip:
        return ElementProperties.gold;
      case SpotCategory.reserved:
        return ElementProperties.orange;
      default:
        // Color basado en tipo de vehículo
        switch (type) {
          case SpotType.motorcycle:
            return ElementProperties.green;
          case SpotType.truck:
            return ElementProperties.orange;
          default:
            return ElementProperties.blue;
        }
    }
  }

  /// Convierte un nombre de color a un objeto Color
  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'blanco':
        return Colors.white;
      case 'negro':
        return Colors.black87;
      case 'gris':
        return Colors.grey;
      case 'plateado':
        return Colors.grey.shade300;
      case 'rojo':
        return Colors.red;
      case 'azul':
        return Colors.blue;
      case 'verde':
        return Colors.green;
      case 'amarillo':
        return Colors.yellow;
      case 'naranja':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  ParkingElement clone() {
    return ParkingSpot(
      id: '$id-copy',
      position: vector_math.Vector2(position.x, position.y),
      type: type,
      label: '$label-copy',
      category: category,
      isOccupied: _isOccupied,
      vehiclePlate: vehiclePlate,
      vehicleColor: vehicleColor,
      entryTime: entryTime,
      exitTime: exitTime,
      rotation: rotation,
      scale: scale,
      isVisible: isVisible,
      isLocked: isLocked,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': 'spot',
      'spotType': type.toString().split('.').last,
      'label': label,
      'category': category.toString().split('.').last,
      'isOccupied': _isOccupied,
      'vehiclePlate': vehiclePlate,
      'vehicleColor': vehicleColor,
      'entryTime': entryTime?.toIso8601String(),
      'exitTime': exitTime?.toIso8601String(),
      'position': {
        'x': position.x,
        'y': position.y,
      },
      'rotation': rotation,
      'scale': scale,
      'isVisible': isVisible,
      'isLocked': isLocked,
    };
  }

  factory ParkingSpot.fromJson(Map<String, dynamic> json) {
    final spotTypeStr = json['spotType'] as String;
    final categoryStr = json['category'] as String;

    return ParkingSpot(
      id: json['id'] as String,
      position: vector_math.Vector2(
        (json['position']['x'] as num).toDouble(),
        (json['position']['y'] as num).toDouble(),
      ),
      type: SpotType.values.firstWhere(
        (e) => e.toString().split('.').last == spotTypeStr,
      ),
      label: json['label'] as String,
      category: SpotCategory.values.firstWhere(
        (e) => e.toString().split('.').last == categoryStr,
      ),
      isOccupied: json['isOccupied'] as bool,
      vehiclePlate: json['vehiclePlate'] as String?,
      vehicleColor: json['vehicleColor'] as String?,
      entryTime: json['entryTime'] != null
          ? DateTime.parse(json['entryTime'] as String)
          : null,
      exitTime: json['exitTime'] != null
          ? DateTime.parse(json['exitTime'] as String)
          : null,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      isVisible: json['isVisible'] as bool? ?? true,
      isLocked: json['isLocked'] as bool? ?? false,
    );
  }
}
