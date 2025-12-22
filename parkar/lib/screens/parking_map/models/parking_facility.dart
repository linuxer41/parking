import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;
import 'dart:async';
import 'dart:math' as math;

import 'enums.dart';
import 'parking_elements.dart';
import '../../../models/parking_model.dart';

/// Implementación de una instalación de parkeo
class ParkingFacility extends ParkingElement {
  // Tipo de instalación
  FacilityType type;

  // Nombre o descripción
  String name;

  // Estado de disponibilidad
  bool _isAvailable;

  // Estado de selección
  bool _isSelected = false;

  // Animación para el efecto de selección
  double _pulseValue = 0.0;
  Timer? _pulseTimer;

  // Constructor
  ParkingFacility({
    required super.id,
    required super.position,
    required this.type,
    required this.name,
    bool isAvailable = true,
    super.rotation,
    super.scale,
    super.isVisible,
    super.isLocked,
    super.isSelected,
  }) : _isAvailable = isAvailable {
    if (isSelected) {
      _startPulseAnimation();
    }
  }

  @override
  bool get isSelected => _isSelected;

  @override
  set isSelected(bool value) {
    if (value == _isSelected) return;
    _isSelected = value;

    if (_isSelected) {
      _startPulseAnimation();
    } else {
      _stopPulseAnimation();
    }

    notifyListeners();
  }

  void _startPulseAnimation() {
    _pulseTimer?.cancel();
    _pulseTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _pulseValue = 0.5 + 0.5 * math.sin(timer.tick * 0.2);
      notifyListeners();
    });
  }

  void _stopPulseAnimation() {
    _pulseTimer?.cancel();
    _pulseTimer = null;
    _pulseValue = 0.0;
  }

  @override
  void dispose() {
    _stopPulseAnimation();
    super.dispose();
  }

  // Getters y setters
  bool get isAvailable => _isAvailable;
  set isAvailable(bool value) {
    if (_isAvailable != value) {
      _isAvailable = value;
      notifyListeners();
    }
  }

  @override
  Size getSize() {
    final ElementVisuals visuals = ElementProperties.facilityVisuals[type]!;
    return Size(visuals.width, visuals.height);
  }

  @override
  void render(Canvas canvas, dynamic renderer) {
    final ElementVisuals visuals = ElementProperties.facilityVisuals[type]!;

    final Size size = getSize();
    final double width = size.width;
    final double height = size.height;

    // Determinar el color del elemento
    final Color color = _getFacilityColor();

    // Definir el rectángulo base
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: width,
      height: height,
    );

    // Dibujar sombra debajo del elemento
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    // Usar RRect para esquinas redondeadas modernas
    final rrect = RRect.fromRectAndRadius(
      rect.translate(2, 2),
      const Radius.circular(12.0),
    );

    canvas.drawRRect(rrect, shadowPaint);

    // Gradiente moderno
    final Gradient gradient = RadialGradient(
      center: Alignment.center,
      radius: 0.8,
      colors: [
        HSLColor.fromColor(color)
            .withLightness(
              (HSLColor.fromColor(color).lightness + 0.15).clamp(0.0, 1.0),
            )
            .toColor(),
        color,
        HSLColor.fromColor(color)
            .withLightness(
              (HSLColor.fromColor(color).lightness - 0.1).clamp(0.0, 1.0),
            )
            .toColor(),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final mainPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    // Dibujar forma principal - usar círculo para instalaciones
    final mainRRect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(12.0),
    );

    canvas.drawRRect(mainRRect, mainPaint);

    // Dibujar un borde con brillo
    final borderPaint = Paint()
      ..color = HSLColor.fromColor(color)
          .withLightness(
            (HSLColor.fromColor(color).lightness + 0.3).clamp(0.0, 1.0),
          )
          .toColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(mainRRect, borderPaint);

    // Dibujar icono apropiado según tipo de instalación
    IconData iconData;

    switch (type) {
      case FacilityType.office:
        iconData = Icons.business;
        break;
      case FacilityType.bathroom:
        iconData = Icons.wc;
        break;
      case FacilityType.cafeteria:
        iconData = Icons.local_cafe;
        break;
      case FacilityType.elevator:
        iconData = Icons.elevator;
        break;
      case FacilityType.stairs:
        iconData = Icons.stairs;
        break;
      case FacilityType.information:
        iconData = Icons.info_outline;
        break;
      default:
        iconData = Icons.business;
    }

    // Dibujar el icono directamente sin círculo de fondo
    drawIcon(
      canvas,
      iconData,
      Size(
        width * 0.6,
        height * 0.6,
      ), // Hacer el icono más grande ya que no tiene fondo
      Colors.white, // Usar blanco para mejor contraste con el fondo de color
      1.0,
    );

    // ETIQUETA DENTRO DEL ELEMENTO (en la parte inferior)
    if (name.isNotEmpty) {
      _renderInternalLabel(canvas, rect);
    }

    // Dibujar indicador de selección si está seleccionado
    if (_isSelected) {
      final selectionPaint = Paint()
        ..color = Colors.white.withOpacity(0.5 + _pulseValue * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect.inflate(4 + _pulseValue * 3),
          const Radius.circular(16),
        ),
        selectionPaint,
      );
    }
  }

  /// Método auxiliar para dibujar la etiqueta dentro del elemento
  void _renderInternalLabel(Canvas canvas, Rect elementRect) {
    // Texto de la etiqueta sin fondo, solo el texto
    final textSpan = TextSpan(
      text: name,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 8, // Tamaño más pequeño
        fontWeight: FontWeight.bold,
        shadows: [
          // Añadir sombra para mejorar legibilidad
          Shadow(
            offset: Offset(1.0, 1.0),
            blurRadius: 1.0,
            color: Colors.black54,
          ),
        ],
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout(maxWidth: elementRect.width);

    // Posicionar la etiqueta en la parte inferior
    textPainter.paint(
      canvas,
      Offset(
        elementRect.center.dx - textPainter.width / 2,
        elementRect.bottom - textPainter.height - 3,
      ),
    );
  }

  /// Obtiene el color apropiado para la instalación según su tipo
  Color _getFacilityColor() {
    // Para instalaciones, obtener color basado en tipo
    switch (type) {
      case FacilityType.office:
      case FacilityType.elevator:
      case FacilityType.stairs:
        return ElementProperties.purple;
      case FacilityType.bathroom:
      case FacilityType.information:
        return ElementProperties.blue;
      case FacilityType.cafeteria:
        return ElementProperties.orange;
      default:
        return ElementProperties.purple;
    }
  }

  /// Obtiene el icono apropiado para la instalación según su tipo
  IconData _getFacilityIcon() {
    IconData iconData;
    switch (type) {
      case FacilityType.office:
        iconData = Icons.business;
        break;
      case FacilityType.bathroom:
        iconData = Icons.wc;
        break;
      case FacilityType.cafeteria:
        iconData = Icons.local_cafe;
        break;
      case FacilityType.elevator:
        iconData = Icons.elevator;
        break;
      case FacilityType.stairs:
        iconData = Icons.stairs;
        break;
      case FacilityType.information:
        iconData = Icons.info_outline;
        break;
      default:
        iconData = Icons.business;
    }
    return iconData;
  }

  @override
  ParkingElement clone() {
    return ParkingFacility(
      id: '$id-copy',
      position: vector_math.Vector2(position.x, position.y),
      type: type,
      name: '$name-copy',
      isAvailable: _isAvailable,
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
      'type': 'facility',
      'facilityType': type.toString(),
      'name': name,
      'isAvailable': _isAvailable,
      'position': {'x': position.x, 'y': position.y},
      'rotation': rotation,
      'scale': scale,
      'isVisible': isVisible,
      'isLocked': isLocked,
    };
  }

  /// Factory para crear una instalación desde JSON
  static ParkingFacility fromJson(Map<String, dynamic> json) {
    final facilityTypeStr = json['facilityType'] as String;

    FacilityType facilityType;
    try {
      facilityType = FacilityType.values.firstWhere(
        (e) => e.toString() == facilityTypeStr,
      );
    } catch (_) {
      facilityType = FacilityType.office;
    }

    final position = vector_math.Vector2(
      json['position']['x'] as double,
      json['position']['y'] as double,
    );

    return ParkingFacility(
      id: json['id'] as String,
      position: position,
      type: facilityType,
      name: json['name'] as String,
      isAvailable: json['isAvailable'] as bool,
      rotation: json['rotation'] as double,
      scale: json['scale'] as double,
      isVisible: json['isVisible'] as bool,
      isLocked: json['isLocked'] as bool,
    );
  }
}

extension ParkingFacilityElementConversion on ParkingFacility {
  // Convertir ParkingFacility a ElementModel
  ElementModel toElementModel() {
    return ElementModel(
      id: id,
      name: name,
      type: ElementType.facility,
      subType: type.index + 1, // Add 1 to match backend schema
      posX: position.x,
      posY: position.y,
      posZ: 0.0,
      rotation: rotation,
      scale: scale,
      isActive: _isAvailable,
      status: _isAvailable ? 'available' : 'maintenance',
    );
  }

  // Método estático para crear un ParkingFacility desde un ElementModel
  static ParkingFacility fromElementModel(ElementModel element) {
    return ParkingFacility(
      id: element.id,
      position: vector_math.Vector2(element.posX, element.posY),
      type:
          FacilityType.values[(element.subType - 1).clamp(
            0,
            FacilityType.values.length - 1,
          )], // Subtract 1 to match enum
      name: element.name,
      isAvailable: element.status == 'available',
      rotation: element.rotation,
      scale: element.scale,
      isVisible: true,
      isLocked: false,
    );
  }
}
