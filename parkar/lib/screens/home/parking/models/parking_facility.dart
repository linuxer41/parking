import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;
import 'dart:math' show min;

import '../utils/drawing_utils.dart';
import 'enums.dart';
import 'parking_elements.dart';

/// Implementación de una instalación de parkeo
class ParkingFacility extends ParkingElement {
  // Tipo de instalación
  FacilityType type;
  
  // Nombre o descripción
  String name;
  
  // Estado de disponibilidad
  bool _isAvailable;
  
  // Constructor
  ParkingFacility({
    required String id,
    required vector_math.Vector2 position,
    required this.type,
    required this.name,
    bool isAvailable = true,
    double rotation = 0.0,
    double scale = 1.0,
    bool isVisible = true,
    bool isLocked = false,
    bool isSelected = false,
  }) : _isAvailable = isAvailable,
       super(
         id: id,
         position: position,
         rotation: rotation,
         scale: scale,
         isVisible: isVisible,
         isLocked: isLocked,
         isSelected: isSelected,
       );
  
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
        HSLColor.fromColor(color).withLightness((HSLColor.fromColor(color).lightness + 0.15).clamp(0.0, 1.0)).toColor(),
        color,
        HSLColor.fromColor(color).withLightness((HSLColor.fromColor(color).lightness - 0.1).clamp(0.0, 1.0)).toColor(),
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
      ..color = HSLColor.fromColor(color).withLightness((HSLColor.fromColor(color).lightness + 0.3).clamp(0.0, 1.0)).toColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    canvas.drawRRect(mainRRect, borderPaint);
    
    // Dibujar icono apropiado según tipo de instalación
    IconData iconData;
    
    switch (type) {
      case FacilityType.bathroom:
        iconData = Icons.wc;
        break;
      case FacilityType.elevator:
        iconData = Icons.elevator;
        break;
      case FacilityType.stairs:
        iconData = Icons.stairs;
        break;
      case FacilityType.paymentStation:
        iconData = Icons.payments;
        break;
      case FacilityType.chargingStation:
        iconData = Icons.electric_car;
        break;
      case FacilityType.securityPost:
        iconData = Icons.security;
        break;
      default:
        iconData = Icons.business;
    }
    
    // Dibujar el icono directamente sin círculo de fondo
    drawIcon(
      canvas, 
      iconData, 
      Size(width * 0.6, height * 0.6), // Hacer el icono más grande ya que no tiene fondo
      Colors.white, // Usar blanco para mejor contraste con el fondo de color
      1.0,
    );
    
    // ETIQUETA DENTRO DEL ELEMENTO (en la parte inferior)
    if (name.isNotEmpty) {
      _renderInternalLabel(canvas, rect);
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
      case FacilityType.elevator:
      case FacilityType.stairs:
        return ElementProperties.purple;
      case FacilityType.bathroom:
        return ElementProperties.blue;
      case FacilityType.paymentStation:
      case FacilityType.chargingStation:
        return ElementProperties.green;
      case FacilityType.securityPost:
        return ElementProperties.red;
      default:
        return ElementProperties.purple;
    }
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
  
  /// Factory para crear una instalación desde JSON
  static ParkingFacility fromJson(Map<String, dynamic> json) {
    final facilityTypeStr = json['facilityType'] as String;
    
    FacilityType facilityType;
    try {
      facilityType = FacilityType.values.firstWhere(
        (e) => e.toString() == facilityTypeStr,
      );
    } catch (_) {
      facilityType = FacilityType.securityPost;
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