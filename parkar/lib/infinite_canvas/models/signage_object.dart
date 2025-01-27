import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'grid_object.dart';
import 'helpers/selected_inidcator.dart';

enum SignageObjectType { exit, entrance, via }

enum SignageObjectDirection { left, right, up, down }

SignageObjectType intToSignageObjectType(int value) {
  if (value >= 0 && value < SignageObjectType.values.length) {
    return SignageObjectType.values[value];
  } else {
    return SignageObjectType.entrance;
  }
}

class SignageObject extends GridObject {
  final SignageObjectType type;
  SignageObjectDirection direction;

  // Tamaños predefinidos para cada tipo de señal
  static const Map<SignageObjectType, Size> signalSizes = {
    SignageObjectType.exit: Size(6, 2), // 6x2 metros
    SignageObjectType.entrance: Size(6, 2), // 6x2 metros
    SignageObjectType.via: Size(6, 2), // 6x2 metros
  };

  // Colores predefinidos para cada tipo de señal (Material 3)
  static const Map<SignageObjectType, Color> signalColors = {
    SignageObjectType.exit: Colors.red, // Rojo para salida
    SignageObjectType.entrance: Colors.green, // Verde para entrada
    SignageObjectType.via: Colors.blue, // Azul para via
  };

  // Etiquetas predefinidas para cada tipo de señal
  static const Map<SignageObjectType, String> signalLabels = {
    SignageObjectType.exit: 'Salida',
    SignageObjectType.entrance: 'Entrada',
    SignageObjectType.via: 'Via',
  };

  SignageObject({
    required this.type,
    this.direction = SignageObjectDirection.right,
    super.position = const Offset(0, 0),
    super.id,
  }) : super(
          size: Size(signalSizes[type]!.width, signalSizes[type]!.height),
          color: signalColors[type]!,
        );

  // Getter para obtener la etiqueta automáticamente
  String get label => signalLabels[type]!;

  @override
  void drawContent(Canvas canvas, Paint paint, Rect rect, Offset canvasOffset,
      double gridSize, double scale) {
    // Dibujar las dos franjas horizontales
    _drawHorizontalStripes(canvas, rect);

    // Dibujar el ícono y el label (si no es de tipo "via")
    _drawIconAndLabel(canvas, rect);
  }

  void toggleDirection() {
    if (direction == SignageObjectDirection.right) {
      direction = SignageObjectDirection.left;
    } else {
      direction = SignageObjectDirection.right;
    }
  }

  void _drawHorizontalStripes(Canvas canvas, Rect rect) {
    final stripeHeight = rect.height * 0.1; // 10% del alto del rectángulo
    final margin =
        rect.width * 0.1; // 10% de margen en los lados izquierdo y derecho

    // Franja superior
    final topStripeRect = Rect.fromLTWH(
      margin, // Margen izquierdo
      rect.height * 0.15, // Margen superior (15%)
      rect.width - 2 * margin, // Ancho del rectángulo menos los márgenes
      stripeHeight, // Altura de la franja
    );
    canvas.drawRect(topStripeRect, Paint()..color = Colors.white);

    // Franja inferior
    final bottomStripeRect = Rect.fromLTWH(
      margin, // Margen izquierdo
      rect.height - rect.height * 0.15 - stripeHeight, // Margen inferior (15%)
      rect.width - 2 * margin, // Ancho del rectángulo menos los márgenes
      stripeHeight, // Altura de la franja
    );
    canvas.drawRect(bottomStripeRect, Paint()..color = Colors.white);
  }

  void _drawIconAndLabel(Canvas canvas, Rect rect) {
    // Tamaño del ícono
    final iconSize = rect.height * 0.85; // 85% del alto del rectángulo

    // Crear un TextPainter para dibujar el ícono (flecha)
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.arrow_right_alt.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          fontFamily: Icons.arrow_right_alt.fontFamily,
          color: Colors.white, // Color del ícono
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();

    // Rotación del ícono según la dirección
    final iconRotation = _getIconRotation();

    // Calcular la posición del ícono
    final iconOffset = _getIconOffset(rect, iconPainter);

    // Dibujar el ícono rotado
    canvas.save();
    canvas.translate(iconOffset.dx + iconPainter.width / 2,
        iconOffset.dy + iconPainter.height / 2);
    canvas.rotate(iconRotation);
    canvas.translate(-iconPainter.width / 2, -iconPainter.height / 2);
    iconPainter.paint(canvas, Offset.zero);
    canvas.restore();

    // Si no es de tipo "via", dibujar el label
    if (type != SignageObjectType.via) {
      _drawLabel(canvas, rect, iconPainter);
    }
  }

  void _drawLabel(Canvas canvas, Rect rect, TextPainter iconPainter) {
    // Tamaño del texto
    final textSize = rect.height * 0.35; // 35% del alto del rectángulo

    // Crear un TextPainter para dibujar la etiqueta
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white, // Texto en blanco
          fontSize: textSize,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black
                  .withOpacity(0.5), // Sombra para mejorar la legibilidad
              blurRadius: 2,
              offset: const Offset(1, 1),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Calcular la posición del texto según la dirección
    final textOffset = _getLabelOffset(rect, textPainter, iconPainter);

    // Dibujar el texto
    textPainter.paint(canvas, textOffset);
  }

  Offset _getIconOffset(Rect rect, TextPainter iconPainter) {
    switch (direction) {
      case SignageObjectDirection.left:
        return Offset(
          rect.width * 0.1, // Margen izquierdo
          (rect.height - iconPainter.height) / 2, // Centrar verticalmente
        );
      case SignageObjectDirection.right:
        return Offset(
          rect.width - iconPainter.width - rect.width * 0.1, // Margen derecho
          (rect.height - iconPainter.height) / 2, // Centrar verticalmente
        );
      case SignageObjectDirection.up:
      case SignageObjectDirection.down:
        return Offset(
          (rect.width - iconPainter.width) / 2, // Centrar horizontalmente
          (rect.height - iconPainter.height) / 2, // Centrar verticalmente
        );
    }
  }

  Offset _getLabelOffset(
      Rect rect, TextPainter textPainter, TextPainter iconPainter) {
    final padding =
        rect.width * 0.05; // 5% de padding entre el ícono y el texto

    switch (direction) {
      case SignageObjectDirection.left:
        return Offset(
          rect.width - textPainter.width - rect.width * 0.1, // Margen derecho
          (rect.height - textPainter.height) / 2, // Centrar verticalmente
        );
      case SignageObjectDirection.right:
        return Offset(
          rect.width * 0.1, // Margen izquierdo
          (rect.height - textPainter.height) / 2, // Centrar verticalmente
        );
      case SignageObjectDirection.up:
        return Offset(
          rect.width - textPainter.width - rect.width * 0.1, // Margen derecho
          (rect.height - textPainter.height) / 2, // Centrar verticalmente
        );
      case SignageObjectDirection.down:
        return Offset(
          rect.width * 0.1, // Margen izquierdo
          (rect.height - textPainter.height) / 2, // Centrar verticalmente
        );
    }
  }

  double _getIconRotation() {
    switch (direction) {
      case SignageObjectDirection.left:
        return math.pi; // 180 grados (apunta a la izquierda)
      case SignageObjectDirection.right:
        return 0; // 0 grados (apunta a la derecha)
      case SignageObjectDirection.up:
        return -math.pi / 2; // -90 grados (apunta hacia arriba)
      case SignageObjectDirection.down:
        return math.pi / 2; // 90 grados (apunta hacia abajo)
    }
  }
}
