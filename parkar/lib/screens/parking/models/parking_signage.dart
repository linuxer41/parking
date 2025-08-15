import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;
import 'dart:math' show min;
import 'dart:async';
import 'dart:math' as math;

import 'enums.dart';
import 'parking_elements.dart';
import '../../../models/element_model.dart';

/// Implementación de una señalización de parkeo
class ParkingSignage extends ParkingElement {
  // Tipo de señalización
  SignageType type;

  // Texto adicional (opcional)
  String? text;

  // Estado de selección
  bool _isSelected = false;

  // Animación para el efecto de selección
  double _pulseValue = 0.0;
  Timer? _pulseTimer;

  // Constructor
  ParkingSignage({
    required super.id,
    required super.position,
    required this.type,
    this.text,
    super.rotation,
    super.scale,
    super.isVisible,
    super.isLocked,
    super.isSelected,
  }) {
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

  @override
  Size getSize() {
    final ElementVisuals visuals = ElementProperties.signageVisuals[type]!;
    return Size(visuals.width, visuals.height);
  }

  @override
  void render(Canvas canvas, dynamic renderer) {
    final ElementVisuals visuals = ElementProperties.signageVisuals[type]!;

    final Size size = getSize();
    final double width = size.width;
    final double height = size.height;

    // Determinar el color del elemento
    final Color color = _getSignageColor();

    // Definir el rectángulo base
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: width,
      height: height,
    );

    // Sombra más sutil
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    final signShape = _getSignageShape(rect);

    // Sombra más sutil y cercana para un look moderno
    canvas.drawPath(
      signShape.shift(const Offset(1, 1)),
      shadowPaint,
    );

    // Fondo plano con color ligeramente más claro para un aspecto minimalista
    final mainPaint = Paint()
      ..color = HSLColor.fromColor(color)
          .withLightness(
              (HSLColor.fromColor(color).lightness + 0.05).clamp(0.0, 1.0))
          .toColor()
      ..style = PaintingStyle.fill;

    canvas.drawPath(signShape, mainPaint);

    // Borde sutil
    final borderPaint = Paint()
      ..color = HSLColor.fromColor(color)
          .withLightness(
              (HSLColor.fromColor(color).lightness - 0.1).clamp(0.0, 1.0))
          .toColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawPath(signShape, borderPaint);

    // Dibujar características adicionales según tipo de señalización
    switch (type) {
      case SignageType.entrance:
      case SignageType.exit:
      case SignageType.direction:
      case SignageType.bidirectional:
      case SignageType.stop:
        // Seleccionar el icono apropiado
        IconData iconData;
        switch (type) {
          case SignageType.entrance:
            iconData = Icons.login;
            break;
          case SignageType.exit:
            iconData = Icons.logout;
            break;
          case SignageType.direction:
            iconData = Icons.trending_flat;
            break;
          case SignageType.bidirectional:
            iconData = Icons.sync_alt;
            break;
          case SignageType.stop:
            iconData = Icons.do_not_disturb;
            break;
          default:
            iconData = Icons.sign_language;
        }

        // Dibujar el icono con tamaño más grande
        drawIcon(
          canvas,
          iconData,
          Size(width * 0.65, height * 0.65), // Iconos más grandes
          Colors.white.withOpacity(0.95),
          1.0,
        );

        break;
    }

    // ETIQUETA DENTRO DEL ELEMENTO con estilo refinado
    final label = _getSignageLabel();
    if (label.isNotEmpty) {
      _renderInternalLabel(canvas, rect, label);
    }

    // Dibujar indicador de selección si está seleccionado
    if (_isSelected) {
      final selectionCornerRadius = min(width, height) * 0.2;
      final selectionPaint = Paint()
        ..color = Colors.white.withOpacity(0.5 + _pulseValue * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect.inflate(4 + _pulseValue * 3),
          Radius.circular(selectionCornerRadius + 4),
        ),
        selectionPaint,
      );
    }
  }

  /// Obtiene el color apropiado para la señalización según su tipo
  Color _getSignageColor() {
    // Para señalización, obtener color basado en tipo de señal
    switch (type) {
      case SignageType.entrance:
        return ElementProperties.green;
      case SignageType.exit:
        return ElementProperties.red;
      case SignageType.stop:
        return ElementProperties.red;
      case SignageType.direction:
      case SignageType.bidirectional:
        return ElementProperties.blue;
      default:
        return ElementProperties.orange;
    }
  }

  /// Devuelve el texto a mostrar como etiqueta
  String _getSignageLabel() {
    if (text != null && text!.isNotEmpty) {
      return text!;
    }

    // Si no hay texto personalizado, usar la etiqueta predefinida
    switch (type) {
      case SignageType.entrance:
        return "Entrada";
      case SignageType.exit:
        return "Salida";
      case SignageType.direction:
        return "Dirección";
      case SignageType.bidirectional:
        return "Bidireccional";
      case SignageType.stop:
        return "Pare";
      default:
        return "Señalización";
    }
  }

  /// Crea un camino (path) para dibujar la forma de la señal
  Path _getSignageShape(Rect rect) {
    final path = Path();
    final w = rect.width;
    final h = rect.height;
    final cornerRadius = min(w, h) * 0.2;

    // Todas las señales con forma rectangular con esquinas redondeadas
    path.addRRect(
      RRect.fromRectAndRadius(
        rect,
        Radius.circular(cornerRadius),
      ),
    );

    return path;
  }

  /// Método auxiliar para dibujar la etiqueta dentro del elemento
  void _renderInternalLabel(Canvas canvas, Rect elementRect, String labelText) {
    // Texto de la etiqueta con estilo minimalista
    final textSpan = TextSpan(
      text: labelText,
      style: TextStyle(
        color:
            Colors.white.withOpacity(0.95), // Blanco ligeramente transparente
        fontSize: 6.5, // Tamaño más pequeño para un look minimalista
        fontWeight: FontWeight.w500, // Menos negrita para aspecto más refinado
        letterSpacing: 0.3, // Espaciado de letras para elegancia
        shadows: const [
          // Sombra muy sutil
          Shadow(
            offset: Offset(0.5, 0.5),
            blurRadius: 0.5,
            color: Colors.black38,
          ),
        ],
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout(maxWidth: elementRect.width - 4);

    // Posicionar la etiqueta en la parte inferior
    textPainter.paint(
      canvas,
      Offset(
        elementRect.center.dx - textPainter.width / 2,
        elementRect.bottom - textPainter.height - 2,
      ),
    );
  }

  @override
  ParkingElement clone() {
    return ParkingSignage(
      id: '$id-copy',
      position: vector_math.Vector2(position.x, position.y),
      type: type,
      text: text,
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
      'type': 'signage',
      'signageType': type.toString(),
      'text': text,
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

  /// Factory para crear una señalización desde JSON
  static ParkingSignage fromJson(Map<String, dynamic> json) {
    final signageTypeStr = json['signageType'] as String;

    SignageType signageType;
    try {
      signageType = SignageType.values.firstWhere(
        (e) => e.toString() == signageTypeStr,
      );
    } catch (_) {
      signageType = SignageType.direction;
    }

    final position = vector_math.Vector2(
      json['position']['x'] as double,
      json['position']['y'] as double,
    );

    return ParkingSignage(
      id: json['id'] as String,
      position: position,
      type: signageType,
      text: json['text'] as String?,
      rotation: json['rotation'] as double,
      scale: json['scale'] as double,
      isVisible: json['isVisible'] as bool,
      isLocked: json['isLocked'] as bool,
    );
  }
}

extension ParkingSignageElementConversion on ParkingSignage {
  // Convertir ParkingSignage a ElementModel
  ElementModel toElementModel(String areaId, String parkingId) {
    return ElementModel(
      id: id,
      areaId: areaId,
      parkingId: parkingId,
      name: text ?? _getSignageLabel(),
      type: ElementType.signage,
      subType: type.index + 1, // Add 1 to match backend schema
      posX: position.x,
      posY: position.y,
      posZ: 0.0,
      rotation: rotation,
      scale: scale,
      accessId: null, // Las señalizaciones no tienen accessId
      occupancy: ElementOccupancyModel(
        status: 'active',
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      deletedAt: null,
    );
  }
  
  // Método estático para crear un ParkingSignage desde un ElementModel
  static ParkingSignage fromElementModel(ElementModel element) {
    return ParkingSignage(
      id: element.id,
      position: vector_math.Vector2(element.posX, element.posY),
      type: SignageType.values[element.subType - 1], // Subtract 1 to match enum
      text: element.name,
      rotation: element.rotation,
      scale: element.scale,
      isVisible: true,
      isLocked: false,
    );
  }
}
