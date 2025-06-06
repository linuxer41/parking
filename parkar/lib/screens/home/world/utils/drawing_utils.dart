import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;
import '../models/world_elements.dart';

/// Clase con utilidades para dibujo de elementos en el mapa
class DrawingUtils {
  /// Dibuja un indicador de selección
  /// Nota: Este método debe ser llamado después de aplicar la rotación al canvas
  /// para que el indicador de selección rote correctamente con el elemento
  static void drawSelectionIndicator(
      Canvas canvas, Offset center, double width, double height, Color color) {
    final selectionPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity(ElementProperties.opacitySelected);

    // Usar RRect para bordes redondeados en el indicador de selección
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: width * 1.2,
        height: height * 1.2,
      ),
      Radius.circular(
          ElementProperties.borderRadius * 1.5), // Radio ligeramente mayor
    );

    canvas.drawRRect(rrect, selectionPaint);

    // Añadir un borde punteado para el indicador de selección
    final dashPaint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    _drawDashedRRect(canvas, rrect, dashPaint, dashLength: 5, dashSpace: 3);
  }

  /// Método para dibujar un RRect con líneas punteadas
  static void _drawDashedRRect(Canvas canvas, RRect rrect, Paint paint,
      {double dashLength = 5, double dashSpace = 3}) {
    // Convertir el RRect a un path para poder dibujar líneas punteadas
    final Path path = Path()..addRRect(rrect);

    // Dibujar el path con líneas punteadas
    final Path dashPath = Path();
    final ui.PathMetrics pathMetrics = path.computeMetrics();

    for (ui.PathMetric metric in pathMetrics) {
      double distance = 0.0;
      bool draw = true;

      while (distance < metric.length) {
        final double len = draw ? dashLength : dashSpace;
        if (draw) {
          dashPath.addPath(
              metric.extractPath(distance, distance + len), Offset.zero);
        }
        distance += len;
        draw = !draw;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  /// Dibuja una etiqueta de texto
  static void drawLabel(
      Canvas canvas, String? text, Offset position, double zoom,
      {Color? textColor, bool withBackground = true}) {
    if (text == null || text.isEmpty) return;

    final color = textColor ?? ElementProperties.textColor;

    // Crear un estilo de texto más moderno
    final textStyle = TextStyle(
      color: color,
      fontSize: ElementProperties.textSizeLabel * zoom,
      fontWeight: FontWeight.w500, // Peso medio para mejor legibilidad
      letterSpacing: 0.2 * zoom, // Ligero espaciado entre letras
    );

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Si tiene fondo, dibujar un rectángulo redondeado
    if (withBackground) {
      final bgPaint = Paint()
        ..color =
            Colors.white.withOpacity(ElementProperties.opacityTextBackground);

      final padding = 3.0 * zoom;
      final bgRect = Rect.fromLTWH(
        position.dx - textPainter.width / 2 - padding,
        position.dy - padding,
        textPainter.width + padding * 2,
        textPainter.height + padding * 2,
      );

      final bgRRect = RRect.fromRectAndRadius(
        bgRect,
        Radius.circular(4.0 * zoom),
      );

      // Dibujar sombra sutil para el texto
      canvas.drawShadow(
        Path()..addRRect(bgRRect),
        Colors.black.withOpacity(0.2),
        2.0 * zoom,
        true,
      );

      canvas.drawRRect(bgRRect, bgPaint);

      // Añadir borde sutil
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5 * zoom
        ..color = Colors.black.withOpacity(0.1);

      canvas.drawRRect(bgRRect, borderPaint);
    }

    textPainter.paint(
      canvas,
      Offset(position.dx - textPainter.width / 2, position.dy),
    );
  }

  /// Convierte una posición del mundo a posición en pantalla
  static vector_math.Vector2 worldToScreenPosition(vector_math.Vector2 position,
      double zoom, vector_math.Vector2 cameraOffset) {
    return vector_math.Vector2(
      position.x * zoom - cameraOffset.x,
      position.y * zoom - cameraOffset.y,
    );
  }
  
  /// Dibuja un rectángulo con líneas discontinuas
  static void drawDashedRect(Canvas canvas, Rect rect, Paint paint, 
      {required double dashLength, required double dashSpace}) {
    // Dibujar líneas discontinuas para cada lado del rectángulo
    
    // Lado superior
    double startX = rect.left;
    while (startX < rect.right) {
      final endX = startX + dashLength < rect.right ? startX + dashLength : rect.right;
      canvas.drawLine(Offset(startX, rect.top), Offset(endX, rect.top), paint);
      startX = endX + dashSpace;
    }
    
    // Lado derecho
    double startY = rect.top;
    while (startY < rect.bottom) {
      final endY = startY + dashLength < rect.bottom ? startY + dashLength : rect.bottom;
      canvas.drawLine(Offset(rect.right, startY), Offset(rect.right, endY), paint);
      startY = endY + dashSpace;
    }
    
    // Lado inferior
    startX = rect.right;
    while (startX > rect.left) {
      final endX = startX - dashLength > rect.left ? startX - dashLength : rect.left;
      canvas.drawLine(Offset(startX, rect.bottom), Offset(endX, rect.bottom), paint);
      startX = endX - dashSpace;
    }
    
    // Lado izquierdo
    startY = rect.bottom;
    while (startY > rect.top) {
      final endY = startY - dashLength > rect.top ? startY - dashLength : rect.top;
      canvas.drawLine(Offset(rect.left, startY), Offset(rect.left, endY), paint);
      startY = endY - dashSpace;
    }
  }
  
  /// Dibuja una etiqueta de texto con alineación personalizable
  static void drawLabelWithAlign(
    Canvas canvas,
    String text,
    Offset position,
    double zoom, {
    Color? textColor,
    bool withBackground = false,
    TextAlign textAlign = TextAlign.center,
  }) {
    final effectiveTextColor = textColor ?? ElementProperties.textColor;

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 10 * zoom,
          color: effectiveTextColor,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: textAlign,
    );
    textPainter.layout();

    if (withBackground) {
      // Crear un fondo sutil con esquinas redondeadas
      final bgRect = Rect.fromCenter(
        center: position,
        width: textPainter.width + 6 * zoom,
        height: textPainter.height + 3 * zoom,
      );
      
      final bgRRect = RRect.fromRectAndRadius(
        bgRect,
        Radius.circular(2.0 * zoom),
      );
      
      final bgPaint = Paint()
        ..color = Colors.white.withOpacity(0.15)
        ..style = PaintingStyle.fill;
      
      // Dibujar el fondo con una sombra muy sutil
      canvas.drawRRect(bgRRect, bgPaint);
      
      // Borde fino para el fondo
      final bgBorderPaint = Paint()
        ..color = effectiveTextColor.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5 * zoom;
      
      canvas.drawRRect(bgRRect, bgBorderPaint);
    }

    // Ajustar la posición según la alineación
    Offset textPos;
    if (textAlign == TextAlign.center) {
      textPos = Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      );
    } else if (textAlign == TextAlign.right) {
      textPos = Offset(
        position.dx - textPainter.width,
        position.dy - textPainter.height / 2,
      );
    } else {
      textPos = Offset(
        position.dx,
        position.dy - textPainter.height / 2,
      );
    }

    textPainter.paint(canvas, textPos);
  }
  
  /// Dibuja un punto de color (para indicadores de categoría)
  static void drawColorDot(
    Canvas canvas,
    Offset position,
    double zoom, {
    required Color dotColor,
    double radius = 4.0,
  }) {
    // Dibujar un pequeño círculo sólido
    final dotRadius = radius * zoom;
    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(position, dotRadius, dotPaint);
  }
}
