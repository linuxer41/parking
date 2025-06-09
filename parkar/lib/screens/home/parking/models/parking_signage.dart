import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;
import 'dart:math' show min;

import '../utils/drawing_utils.dart';
import 'enums.dart';
import 'parking_elements.dart';

/// Implementación de una señalización de parkeo
class ParkingSignage extends ParkingElement {
  // Tipo de señalización
  SignageType type;
  
  // Texto adicional (opcional)
  String? text;
  
  // Constructor
  ParkingSignage({
    required String id,
    required vector_math.Vector2 position,
    required this.type,
    this.text,
    double rotation = 0.0,
    double scale = 1.0,
    bool isVisible = true,
    bool isLocked = false,
    bool isSelected = false,
  }) : super(
         id: id,
         position: position,
         rotation: rotation,
         scale: scale,
         isVisible: isVisible,
         isLocked: isLocked,
         isSelected: isSelected,
       );
  
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
    
    // Dibujar sombra debajo del elemento
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    
    // Usar un hexágono redondeado para señalización
    final signShape = _getSignageShape(rect);
    
    // Sombra
    canvas.drawPath(
      signShape.shift(const Offset(2, 2)),
      shadowPaint,
    );
    
    // Fondo con gradiente
    final Gradient gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        HSLColor.fromColor(color).withLightness((HSLColor.fromColor(color).lightness + 0.1).clamp(0.0, 1.0)).toColor(),
        color,
        HSLColor.fromColor(color).withLightness((HSLColor.fromColor(color).lightness - 0.1).clamp(0.0, 1.0)).toColor(),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    final mainPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(signShape, mainPaint);
    
    // Borde brillante
    final borderPaint = Paint()
      ..color = HSLColor.fromColor(color).withLightness((HSLColor.fromColor(color).lightness + 0.2).clamp(0.0, 1.0)).toColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    canvas.drawPath(signShape, borderPaint);
    
    // Dibujar características adicionales según tipo de señalización
    switch (type) {
      case SignageType.entrance:
      case SignageType.exit:
      case SignageType.noParking:
      case SignageType.path:
      case SignageType.oneWay:
      case SignageType.twoWay:
      case SignageType.info:
        // Seleccionar el icono apropiado
        IconData iconData;
        switch (type) {
          case SignageType.entrance:
            iconData = Icons.login;
            break;
          case SignageType.exit:
            iconData = Icons.logout;
            break;
          case SignageType.noParking:
            iconData = Icons.do_not_disturb;
            break;
          case SignageType.path:
            iconData = Icons.trending_flat;
            break;
          case SignageType.oneWay:
            iconData = Icons.trending_flat;
            break;
          case SignageType.twoWay:
            iconData = Icons.sync_alt;
            break;
          case SignageType.info:
            iconData = Icons.info_outline;
            break;
          default:
            iconData = Icons.sign_language;
        }
        
        // Dibujar el icono directamente sin círculo de fondo
        drawIcon(
          canvas, 
          iconData, 
          Size(width * 0.5, height * 0.5),  // Aumentar tamaño del icono
          Colors.white,  // Utilizar blanco para mejor contraste
          1.0,
        );
        
        break;
    }
    
    // ETIQUETA DENTRO DEL ELEMENTO
    final label = _getSignageLabel();
    if (label.isNotEmpty) {
      _renderInternalLabel(canvas, rect, label);
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
      case SignageType.noParking:
        return ElementProperties.red;
      case SignageType.path:
      case SignageType.oneWay:
      case SignageType.twoWay:
        return ElementProperties.blue;
      case SignageType.info:
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
      case SignageType.noParking:
        return "No Estacionar";
      case SignageType.path:
        return "Vía";
      case SignageType.oneWay:
        return "Una Vía";
      case SignageType.twoWay:
        return "Doble Vía";
      case SignageType.info:
        return "Información";
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
    
    switch (type) {
      case SignageType.entrance:
      case SignageType.exit:
      case SignageType.info:
        // Rectangular con esquinas redondeadas
        path.addRRect(
          RRect.fromRectAndRadius(
            rect,
            Radius.circular(cornerRadius),
          ),
        );
        break;
        
      case SignageType.noParking:
        // Forma circular
        path.addOval(rect);
        break;
        
      case SignageType.oneWay:
      case SignageType.twoWay:
      case SignageType.path:
        // Forma hexagonal para señales direccionales
        final centerX = rect.center.dx;
        final centerY = rect.center.dy;
        final radiusX = rect.width / 2;
        final radiusY = rect.height / 2;
        
        path.moveTo(centerX - radiusX / 2, centerY - radiusY);
        path.lineTo(centerX + radiusX / 2, centerY - radiusY);
        path.lineTo(centerX + radiusX, centerY);
        path.lineTo(centerX + radiusX / 2, centerY + radiusY);
        path.lineTo(centerX - radiusX / 2, centerY + radiusY);
        path.lineTo(centerX - radiusX, centerY);
        path.close();
        break;
        
      default:
        // Por defecto: rectangular con esquinas redondeadas
        path.addRRect(
          RRect.fromRectAndRadius(
            rect,
            Radius.circular(cornerRadius),
          ),
        );
        break;
    }
    
    return path;
  }
  
  /// Método auxiliar para dibujar la etiqueta dentro del elemento
  void _renderInternalLabel(Canvas canvas, Rect elementRect, String labelText) {
    // Texto de la etiqueta sin fondo, solo el texto
    final textSpan = TextSpan(
      text: labelText,
      style: const TextStyle(
        color: Colors.white,  // Color blanco para mejor contraste
        fontSize: 7,  // Tamaño más pequeño
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
    
    textPainter.layout(maxWidth: elementRect.width - 4);
    
    // Posicionar la etiqueta en la parte inferior
    textPainter.paint(
      canvas, 
      Offset(
        elementRect.center.dx - textPainter.width / 2,
        elementRect.bottom - textPainter.height - 3,
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
      signageType = SignageType.info;
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