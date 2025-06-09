import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

/// Extensión para añadir métodos útiles a Color
extension ColorExtension on Color {
  /// Devuelve una versión más oscura del color
  Color darker([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    
    return hslDark.toColor();
  }
  
  /// Devuelve una versión más clara del color
  Color lighter([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    
    return hslLight.toColor();
  }
}

/// Clase de utilidades para dibujo en el sistema de parkeo
class DrawingUtils {
  /// Dibuja un rectángulo redondeado con borde y relleno
  static void drawRoundedRect(
    Canvas canvas, {
    required Rect rect,
    required Color fillColor,
    required Color borderColor,
    double borderWidth = 1.0,
    double borderRadius = 4.0,
    bool shadow = false,
    Color shadowColor = Colors.black,
  }) {
    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          rect,
          Radius.circular(borderRadius),
        ),
      );

    if (shadow) {
      canvas.drawShadow(path, shadowColor.withOpacity(0.3), 4.0, true);
    }

    // Dibujar el relleno
    final Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Dibujar el borde
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawPath(path, borderPaint);
  }

  /// Dibuja un rectángulo con degradado
  static void drawGradientRect(
    Canvas canvas, {
    required Rect rect,
    required List<Color> colors,
    required List<double> stops,
    Alignment begin = Alignment.topCenter,
    Alignment end = Alignment.bottomCenter,
    double borderWidth = 0.0,
    Color borderColor = Colors.transparent,
    double borderRadius = 4.0,
    bool shadow = false,
    Color shadowColor = Colors.black,
  }) {
    final RRect rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );
    
    final Path path = Path()..addRRect(rrect);
    
    if (shadow) {
      canvas.drawShadow(path, shadowColor.withOpacity(0.3), 4.0, true);
    }
    
    // Crear el gradiente
    final Gradient gradient = LinearGradient(
      begin: begin,
      end: end,
      colors: colors,
      stops: stops,
    );
    
    // Dibujar el relleno con gradiente
    final Paint fillPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(rrect, fillPaint);
    
    // Dibujar el borde si se especifica
    if (borderWidth > 0) {
      final Paint borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      
      canvas.drawRRect(rrect, borderPaint);
    }
  }

  /// Dibuja un círculo con borde y relleno
  static void drawCircle(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color fillColor,
    required Color borderColor,
    double borderWidth = 1.0,
    bool shadow = false,
    Color shadowColor = Colors.black,
  }) {
    final Path path = Path()
      ..addOval(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
      );

    if (shadow) {
      canvas.drawShadow(path, shadowColor.withOpacity(0.3), 4.0, true);
    }

    // Dibujar el relleno
    final Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Dibujar el borde
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawPath(path, borderPaint);
  }

  /// Dibuja un badge circular moderno
  static void drawBadge(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
    IconData? icon,
    String? text,
    Color iconColor = Colors.white,
    double iconSize = 12.0,
    bool shadow = true,
  }) {
    // Dibujar círculo con sombra
    final Paint circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    if (shadow) {
      final Path path = Path()
        ..addOval(Rect.fromCircle(center: center, radius: radius));
      canvas.drawShadow(path, Colors.black.withOpacity(0.3), 2.0, true);
    }
    
    canvas.drawCircle(center, radius, circlePaint);
    
    // Dibujar icono o texto
    if (icon != null) {
      drawIcon(
        canvas,
        icon: icon,
        position: center,
        color: iconColor,
        size: iconSize,
      );
    } else if (text != null) {
      drawText(
        canvas,
        text: text,
        position: center,
        color: iconColor,
        fontSize: iconSize,
        fontWeight: FontWeight.bold,
      );
    }
  }

  /// Dibuja una flecha direccional
  static void drawArrow(
    Canvas canvas, {
    required Offset start,
    required Offset end,
    required Color color,
    double strokeWidth = 2.0,
    double arrowSize = 10.0,
  }) {
    // Calcular ángulo de la flecha
    final double dx = end.dx - start.dx;
    final double dy = end.dy - start.dy;
    final double angle = atan2(dy, dx);

    // Dibujar línea principal
    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawLine(start, end, linePaint);

    // Dibujar cabeza de flecha
    final Path arrowPath = Path();
    arrowPath.moveTo(end.dx, end.dy);
    arrowPath.lineTo(
      end.dx - arrowSize * cos(angle - pi / 6),
      end.dy - arrowSize * sin(angle - pi / 6),
    );
    arrowPath.lineTo(
      end.dx - arrowSize * cos(angle + pi / 6),
      end.dy - arrowSize * sin(angle + pi / 6),
    );
    arrowPath.close();

    final Paint arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(arrowPath, arrowPaint);
  }

  /// Dibuja un icono en una posición específica
  static void drawIcon(
    Canvas canvas, {
    required IconData icon,
    required Offset position,
    required Color color,
    required double size,
    TextDirection textDirection = TextDirection.ltr,
    double opacity = 1.0,
    Color? backgroundColor,
  }) {
    // Si hay un fondo, dibujarlo primero
    if (backgroundColor != null) {
      final double backgroundSize = size * 1.5;
      final Rect backgroundRect = Rect.fromCenter(
        center: position,
        width: backgroundSize,
        height: backgroundSize,
      );
      
      drawRoundedRect(
        canvas,
        rect: backgroundRect,
        fillColor: backgroundColor,
        borderColor: backgroundColor,
        borderRadius: backgroundSize / 4,
      );
    }
    
    // Ajustar la opacidad del color
    final effectiveColor = opacity < 1.0 
        ? color.withOpacity(opacity) 
        : color;
    
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size,
          fontFamily: icon.fontFamily,
          color: effectiveColor,
        ),
      ),
      textDirection: textDirection,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  /// Dibuja texto con un fondo opcional
  static void drawText(
    Canvas canvas, {
    required String text,
    required Offset position,
    required Color color,
    double fontSize = 12.0,
    FontWeight fontWeight = FontWeight.normal,
    TextAlign textAlign = TextAlign.center,
    Color? backgroundColor,
    EdgeInsets padding = const EdgeInsets.all(4.0),
    double borderRadius = 2.0,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        ),
      ),
      textDirection: textDirection,
      textAlign: textAlign,
    );
    textPainter.layout();

    // Dibujar fondo si se especifica
    if (backgroundColor != null) {
      final Rect backgroundRect = Rect.fromCenter(
        center: Offset(
          position.dx,
          position.dy,
        ),
        width: textPainter.width + padding.horizontal,
        height: textPainter.height + padding.vertical,
      );

      drawRoundedRect(
        canvas,
        rect: backgroundRect,
        fillColor: backgroundColor,
        borderColor: backgroundColor,
        borderRadius: borderRadius,
      );
    }

    // Dibujar texto
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }
} 