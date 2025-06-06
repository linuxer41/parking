import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

import '../core/world_state.dart';
import '../models/index.dart';
import '../utils/index.dart';

/// Clase responsable de renderizar el mundo y sus elementos
class WorldRenderer {
  final WorldState state;
  final Size canvasSize;

  // Configuración de renderizado
  final bool showGrid;
  final double gridSize;
  final Color gridColor;
  final double gridOpacity;

  // Tema de renderizado moderno y minimalista
  final Color backgroundColor;
  final Color selectionColor;
  final double selectionStrokeWidth;
  final bool showElementIcons;
  final bool showElementLabels;

  // Nuevos parámetros para efectos visuales mejorados
  final bool isDarkMode;
  final bool enableShadows;
  final bool showHeatmap;
  final double ambientLightIntensity;

  WorldRenderer({
    required this.state,
    required this.canvasSize,
    this.showGrid = true,
    this.gridSize = 20.0,
    this.gridColor = Colors.grey,
    this.gridOpacity = 0.15, // Reducido para un aspecto más sutil
    this.backgroundColor = Colors.white,
    this.selectionColor = Colors.blue, // Color azul para selección
    this.selectionStrokeWidth = 1.5, // Más fino para un aspecto minimalista
    this.showElementIcons = true,
    this.showElementLabels = true,
    this.isDarkMode = false,
    this.enableShadows = true,
    this.showHeatmap = false,
    this.ambientLightIntensity = 1.0,
  });

  /// Método principal para renderizar todo el mundo
  void render(Canvas canvas) {
    // Dibujar el fondo
    _drawBackground(canvas);

    // Dibujar la cuadrícula si está habilitada
    if (showGrid) {
      _drawGrid(canvas);
    }

    // Dibujar mapa de calor si está habilitado
    if (showHeatmap) {
      _drawHeatmap(canvas);
    }

    // Dibujar todos los elementos
    _drawElements(canvas);

    // Dibujar elementos de interfaz adicionales
    _drawUI(canvas);
  }

  /// Método para dibujar el fondo
  void _drawBackground(Canvas canvas) {
    final Color effectiveBackgroundColor = isDarkMode
        ? const Color(0xFF121212) // Color oscuro para modo nocturno
        : backgroundColor;

    final paint = Paint()
      ..color = effectiveBackgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height),
      paint,
    );

    // Si está en modo oscuro, añadir un efecto sutil de viñeta
    if (isDarkMode) {
      final Rect rect =
          Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height);
      final Gradient gradient = RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.3),
        ],
        stops: const [0.7, 1.0],
      );

      final Paint vignettePaint = Paint()
        ..shader = gradient.createShader(rect)
        ..blendMode = BlendMode.darken;

      canvas.drawRect(rect, vignettePaint);
    }
  }

  /// Método para dibujar la cuadrícula
  void _drawGrid(Canvas canvas) {
    final Color effectiveGridColor = isDarkMode
        ? Colors.white.withOpacity(gridOpacity * 0.7)
        : gridColor.withOpacity(gridOpacity);

    final paint = Paint()
      ..color = effectiveGridColor
      ..strokeWidth = 0.5; // Líneas más finas para un aspecto minimalista

    final effectiveGridSize = gridSize * state.zoom;
    final offsetX = state.cameraPosition.x % effectiveGridSize;
    final offsetY = state.cameraPosition.y % effectiveGridSize;

    // Dibujar líneas verticales
    for (double x = -offsetX; x < canvasSize.width; x += effectiveGridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, canvasSize.height),
        paint,
      );
    }

    // Dibujar líneas horizontales
    for (double y = -offsetY; y < canvasSize.height; y += effectiveGridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(y, canvasSize.width),
        paint,
      );
    }

    // Dibujar líneas principales más destacadas
    final mainGridSize = effectiveGridSize * 5;
    final mainOffsetX = state.cameraPosition.x % mainGridSize;
    final mainOffsetY = state.cameraPosition.y % mainGridSize;

    final mainPaint = Paint()
      ..color = effectiveGridColor.withOpacity(gridOpacity * 2)
      ..strokeWidth = 0.8;

    // Dibujar líneas verticales principales
    for (double x = -mainOffsetX; x < canvasSize.width; x += mainGridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, canvasSize.height),
        mainPaint,
      );
    }

    // Dibujar líneas horizontales principales
    for (double y = -mainOffsetY; y < canvasSize.height; y += mainGridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(canvasSize.width, y),
        mainPaint,
      );
    }
  }

  /// Método para dibujar mapa de calor
  void _drawHeatmap(Canvas canvas) {
    // Implementación básica de mapa de calor basado en ocupación
    if (state.spots.isEmpty) return;

    final List<ParkingSpot> occupiedSpots =
        state.spots.where((spot) => spot.isOccupied && spot.isVisible).toList();

    if (occupiedSpots.isEmpty) return;

    // Crear una capa de mapa de calor
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.plus;

    for (final spot in occupiedSpots) {
      final screenPos =
          spot.getScreenPosition(state.zoom, state.cameraPosition);
      final heatRadius = 100.0 * state.zoom;

      final gradient = RadialGradient(
        colors: [
          Colors.red.withOpacity(0.3),
          Colors.red.withOpacity(0.0),
        ],
        stops: const [0.0, 1.0],
      );

      paint.shader = gradient.createShader(
        Rect.fromCircle(
          center: Offset(screenPos.x, screenPos.y),
          radius: heatRadius,
        ),
      );

      canvas.drawCircle(
        Offset(screenPos.x, screenPos.y),
        heatRadius,
        paint,
      );
    }
  }

  /// Método para dibujar todos los elementos
  void _drawElements(Canvas canvas) {
    // Guardar el estado actual del canvas
    canvas.save();

    // Aplicar transformaciones globales (zoom y desplazamiento)
    final zoom = state.zoom;
    final cameraOffset = state.cameraPosition;

    // Ordenar elementos por tipo para dibujarlos en capas
    // (primero spots, luego facilities, finalmente signages)
    final List<WorldElement> orderedElements = [];
    orderedElements.addAll(state.spots);
    orderedElements.addAll(state.facilities);
    orderedElements.addAll(state.signages);

    // Ordenar por posición Y para simular profundidad
    orderedElements.sort((a, b) {
      // Usar la posición Y como aproximación de profundidad
      return a.position.y.compareTo(b.position.y);
    });

    // Filtrar elementos visibles y en el nivel actual
    final visibleElements = orderedElements.where((element) {
      // Verificar si el elemento está en la vista actual
      final screenPos = element.getScreenPosition(zoom, cameraOffset);
      final isInView = screenPos.x >= -100 &&
          screenPos.x <= canvasSize.width + 100 &&
          screenPos.y >= -100 &&
          screenPos.y <= canvasSize.height + 100;

      // Verificar si el elemento es visible
      return element.isVisible && isInView;
    }).toList();

    // Dibujar elementos visibles
    for (final element in visibleElements) {
      // Actualizar propiedades basadas en selección
      if (state.firstSelectedElement == element || state.selectedElements.contains(element)) {
        element.isSelected = true;
      } else {
        element.isSelected = false;
      }

      // Ajustar opacidad en modo oscuro si es necesario
      if (isDarkMode) {
        element.opacity = element.opacity * ambientLightIntensity;
      }

      // Renderizar el elemento
      element.render(canvas, canvasSize, zoom, cameraOffset);
      
      // Si el elemento está siendo arrastrado y colisiona, mostrar indicador de colisión
      if (element.isSelected && element == state.firstSelectedElement) {
        if (state.collisionManager.checkElementCollisions(element)) {
          _drawCollisionIndicator(canvas, element, zoom, cameraOffset);
        }
      }
    }

    // Restaurar el estado del canvas
    canvas.restore();
  }

  /// Método para dibujar un indicador de colisión alrededor de un elemento
  void _drawCollisionIndicator(Canvas canvas, WorldElement element, double zoom, vector_math.Vector2 cameraOffset) {
    final screenPos = element.getScreenPosition(zoom, cameraOffset);
    final width = element.size.width * zoom;
    final height = element.size.height * zoom;
    
    // Dibujar un borde rojo parpadeante alrededor del elemento
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Crear un rectángulo alrededor del elemento, considerando la rotación
    final rect = Rect.fromCenter(
      center: Offset(screenPos.x, screenPos.y),
      width: width + 8,
      height: height + 8,
    );
    
    // Guardar el estado actual del canvas para aplicar transformaciones
    canvas.save();
    
    // Trasladar al centro del elemento
    canvas.translate(screenPos.x, screenPos.y);
    
    // Rotar el canvas según la rotación del elemento
    if (element.rotation != 0) {
      canvas.rotate(element.rotation);
    }
    
    // Dibujar un rectángulo rotado con esquinas redondeadas
    final elementRect = Rect.fromCenter(
      center: Offset.zero,
      width: width + 8,
      height: height + 8,
    );
    
    final rrect = RRect.fromRectAndRadius(elementRect, const Radius.circular(4));
    canvas.drawRRect(rrect, paint);
    
    // Restaurar el estado del canvas
    canvas.restore();
    
    // Dibujar un icono de advertencia encima del elemento
    final iconPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    
    // Dibujar un círculo para el icono
    canvas.drawCircle(
      Offset(screenPos.x, screenPos.y - height/2 - 15),
      10.0,
      iconPaint,
    );
    
    // Dibujar el símbolo de exclamación
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 14.0,
      fontWeight: FontWeight.bold,
    );
    
    final textSpan = TextSpan(
      text: '!',
      style: textStyle,
    );
    
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas, 
      Offset(
        screenPos.x - textPainter.width / 2, 
        screenPos.y - height/2 - 15 - textPainter.height / 2
      )
    );
    
    // Mostrar mensaje de colisión
    final messageStyle = TextStyle(
      color: Colors.white,
      fontSize: 10.0,
      fontWeight: FontWeight.bold,
      backgroundColor: Colors.red.withOpacity(0.7),
    );
    
    final messageSpan = TextSpan(
      text: 'Colisión detectada',
      style: messageStyle,
    );
    
    final messagePainter = TextPainter(
      text: messageSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    messagePainter.layout();
    messagePainter.paint(
      canvas, 
      Offset(
        screenPos.x - messagePainter.width / 2, 
        screenPos.y + height/2 + 10
      )
    );
  }

  /// Método para dibujar elementos de interfaz adicionales
  void _drawUI(Canvas canvas) {
    // Dibujar guías de alineación si hay elementos seleccionados y estamos en modo edición
    if ((state.firstSelectedElement != null || state.selectedElements.isNotEmpty) &&
        state.isEditMode) {
      _drawAlignmentGuides(canvas);
    }

    // Ya no dibujamos indicadores de selección aquí, se manejan en cada elemento
    // _drawSelectionIndicators(canvas);

    // Dibujar información de estado
    _drawStateInfo(canvas);

    // Dibujar controles de edición si estamos en modo edición
    if (state.isEditMode) {
      _drawEditControls(canvas);
    }
  }

  /// Método para dibujar guías de alineación
  void _drawAlignmentGuides(Canvas canvas) {
    // Solo dibujar guías si hay un elemento seleccionado
    if (state.firstSelectedElement == null && state.selectedElements.isEmpty) return;

    final List<WorldElement> selectedElements = [];
    if (state.firstSelectedElement != null) {
      selectedElements.add(state.firstSelectedElement!);
    } else {
      selectedElements.addAll(state.selectedElements);
    }

    // Obtener todos los elementos excepto los seleccionados
    final List<WorldElement> otherElements = state.allElements
        .where((element) =>
            !selectedElements.contains(element) && element.isVisible)
        .toList();

    if (otherElements.isEmpty) return;

    // Para cada elemento seleccionado, buscar alineaciones con otros elementos
    for (final selectedElement in selectedElements) {
      final selectedScreenPos =
          selectedElement.getScreenPosition(state.zoom, state.cameraPosition);

      // Umbral de alineación (en píxeles de pantalla)
      final alignThreshold = 10.0;

      // Guías horizontales y verticales encontradas
      final List<double> horizontalGuides = [];
      final List<double> verticalGuides = [];

      // Comprobar alineación con cada elemento no seleccionado
      for (final otherElement in otherElements) {
        final otherScreenPos =
            otherElement.getScreenPosition(state.zoom, state.cameraPosition);

        // Comprobar alineación horizontal (misma coordenada Y)
        if ((selectedScreenPos.y - otherScreenPos.y).abs() < alignThreshold) {
          horizontalGuides.add(otherScreenPos.y);
        }

        // Comprobar alineación vertical (misma coordenada X)
        if ((selectedScreenPos.x - otherScreenPos.x).abs() < alignThreshold) {
          verticalGuides.add(otherScreenPos.x);
        }

        // Comprobar alineación de bordes
        final selectedWidth = selectedElement.size.width * state.zoom;
        final selectedHeight = selectedElement.size.height * state.zoom;
        final otherWidth = otherElement.size.width * state.zoom;
        final otherHeight = otherElement.size.height * state.zoom;

        // Borde izquierdo alineado con borde izquierdo
        if (((selectedScreenPos.x - selectedWidth / 2) -
                    (otherScreenPos.x - otherWidth / 2))
                .abs() <
            alignThreshold) {
          verticalGuides.add(otherScreenPos.x - otherWidth / 2);
        }

        // Borde derecho alineado con borde derecho
        if (((selectedScreenPos.x + selectedWidth / 2) -
                    (otherScreenPos.x + otherWidth / 2))
                .abs() <
            alignThreshold) {
          verticalGuides.add(otherScreenPos.x + otherWidth / 2);
        }

        // Borde superior alineado con borde superior
        if (((selectedScreenPos.y - selectedHeight / 2) -
                    (otherScreenPos.y - otherHeight / 2))
                .abs() <
            alignThreshold) {
          horizontalGuides.add(otherScreenPos.y - otherHeight / 2);
        }

        // Borde inferior alineado con borde inferior
        if (((selectedScreenPos.y + selectedHeight / 2) -
                    (otherScreenPos.y + otherHeight / 2))
                .abs() <
            alignThreshold) {
          horizontalGuides.add(otherScreenPos.y + otherHeight / 2);
        }
      }

      // Dibujar guías de alineación encontradas
      if (horizontalGuides.isNotEmpty || verticalGuides.isNotEmpty) {
        _drawGuideLines(canvas, horizontalGuides, verticalGuides);
      }
    }
  }

  /// Método para dibujar líneas guía
  void _drawGuideLines(Canvas canvas, List<double> horizontalGuides,
      List<double> verticalGuides) {
    final guideColor = isDarkMode ? Colors.cyan : Colors.blue;

    final guidePaint = Paint()
      ..color = guideColor.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Dibujar guías horizontales
    for (final y in horizontalGuides) {
      canvas.drawLine(
        Offset(0, y),
        Offset(canvasSize.width, y),
        guidePaint,
      );

      // Dibujar pequeños indicadores en los extremos
      final indicatorPaint = Paint()
        ..color = guideColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(10, y), 2.0, indicatorPaint);
      canvas.drawCircle(Offset(canvasSize.width - 10, y), 2.0, indicatorPaint);
    }

    // Dibujar guías verticales
    for (final x in verticalGuides) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, canvasSize.height),
        guidePaint,
      );

      // Dibujar pequeños indicadores en los extremos
      final indicatorPaint = Paint()
        ..color = guideColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, 10), 2.0, indicatorPaint);
      canvas.drawCircle(Offset(x, canvasSize.height - 10), 2.0, indicatorPaint);
    }
  }

  /// Método para dibujar controles de edición
  void _drawEditControls(Canvas canvas) {
    if (state.firstSelectedElement == null) return;

    final element = state.firstSelectedElement!;
    final screenPos = DrawingUtils.worldToScreenPosition(
      element.position,
      state.zoom,
      state.cameraPosition,
    );

    // Si el elemento es rotable, dibujar control de rotación
    if (element.isRotatable) {
      final rotationHandleOffset = Offset(screenPos.x, screenPos.y - 30);

      // Dibujar línea punteada para un aspecto más moderno
      final dashPaint = Paint()
        ..color = selectionColor.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;

      _drawDashedLine(canvas, Offset(screenPos.x, screenPos.y),
          rotationHandleOffset, dashPaint);

      // Dibujar un círculo pequeño como control de rotación
      final handlePaint = Paint()
        ..color = selectionColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(rotationHandleOffset, 3.0, handlePaint);
    }

    // Dibujar barra de herramientas debajo del elemento
    _drawElementToolbar(canvas, element, screenPos);
  }

  /// Método para dibujar la barra de herramientas del elemento
  void _drawElementToolbar(
      Canvas canvas, WorldElement element, vector_math.Vector2 screenPos) {
    // Calcular posición de la barra de herramientas (debajo del elemento)
    final toolbarY = screenPos.y + (element.size.height * state.zoom / 2) + 15;
    final toolbarX = screenPos.x;

    // Configuración de la barra de herramientas
    final iconSize = 16.0; // Tamaño más pequeño para los iconos
    final iconSpacing = 12.0; // Más espacio entre iconos
    final totalButtons = 5; // Eliminar, Rotar izq, Rotar der, Copiar, Editar etiqueta
    final totalWidth =
        (iconSize * totalButtons) + (iconSpacing * (totalButtons - 1));

    // Dibujar fondo de la barra de herramientas - más delgado y minimalista
    final bgColor = isDarkMode ? Colors.grey[850]! : Colors.white;
    final borderColor = isDarkMode ? Colors.grey[700]! : Colors.black12;

    final bgPaint = Paint()
      ..color = bgColor.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5; // Más fino para un aspecto minimalista

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(toolbarX, toolbarY),
        width: totalWidth + 16,
        height: iconSize + 12, // Más compacto
      ),
      Radius.circular(4.0), // Menos redondeado para un aspecto más minimalista
    );

    // Dibujar fondo con sombra sutil
    canvas.drawShadow(
      Path()..addRRect(bgRect),
      Colors.black.withOpacity(0.2),
      2.0, // Sombra más sutil
      true,
    );

    canvas.drawRRect(bgRect, bgPaint);
    
    // Añadir un sutil efecto de brillo en la parte superior
    final Path highlightPath = Path();
    final Rect highlightRect = Rect.fromLTRB(
      bgRect.left + 1, 
      bgRect.top + 1, 
      bgRect.right - 1, 
      bgRect.top + (bgRect.height * 0.4)
    );
    highlightPath.addRRect(RRect.fromRectAndCorners(
      highlightRect,
      topLeft: Radius.circular(4.0),
      topRight: Radius.circular(4.0),
    ));
    
    final Paint highlightPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(highlightRect.left, highlightRect.top),
        Offset(highlightRect.left, highlightRect.bottom),
        [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.0),
        ],
      )
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(highlightPath, highlightPaint);
    
    // Dibujar el borde
    canvas.drawRRect(bgRect, borderPaint);

    // Posiciones de los iconos
    final startX = toolbarX - totalWidth / 2 + iconSize / 2;

    // Colores vibrantes para los iconos
    final deleteColor = Colors.red.shade400;
    final rotateLeftColor = Colors.blue.shade400;
    final rotateRightColor = Colors.green.shade400;
    final copyColor = Colors.amber.shade600;
    final editColor = Colors.purple.shade400;

    // 1. Icono eliminar
    _drawToolbarIcon(canvas, Icons.delete_outline, Offset(startX, toolbarY),
        iconSize, deleteColor);

    // 2. Icono rotar antihorario (izquierda)
    _drawToolbarIcon(canvas, Icons.rotate_left, 
        Offset(startX + iconSize + iconSpacing, toolbarY), iconSize, rotateLeftColor);

    // 3. Icono rotar horario (derecha)
    _drawToolbarIcon(canvas, Icons.rotate_right, 
        Offset(startX + (iconSize + iconSpacing) * 2, toolbarY), iconSize, rotateRightColor);

    // 4. Icono copiar
    _drawToolbarIcon(canvas, Icons.content_copy, 
        Offset(startX + (iconSize + iconSpacing) * 3, toolbarY), iconSize, copyColor);

    // 5. Icono editar etiqueta
    _drawToolbarIcon(canvas, Icons.edit, 
        Offset(startX + (iconSize + iconSpacing) * 4, toolbarY), iconSize, editColor);
  }

  /// Método para dibujar un botón de la barra de herramientas - versión minimalista
  void _drawToolbarButton(
    Canvas canvas,
    Offset center,
    double size,
    Color color,
    IconData icon,
  ) {
    // Dibujar solo el icono, sin círculo ni borde
    final iconSize = size;
    final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: ui.TextAlign.center,
      maxLines: 1,
    ))
      ..pushStyle(ui.TextStyle(
        color: color,
        fontSize: iconSize,
        fontFamily: icon.fontFamily,
        fontWeight: FontWeight.w400, // Más ligero para un aspecto minimalista
      ));

    // Usar el código del icono como texto
    paragraphBuilder.addText(String.fromCharCode(icon.codePoint));

    final paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: iconSize * 2));

    // Centrar el icono
    canvas.drawParagraph(
      paragraph,
      Offset(center.dx - iconSize / 2, center.dy - iconSize / 2),
    );
  }

  /// Método para dibujar una línea punteada
  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final Path path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);

    final dashWidth = 3.0;
    final dashSpace = 2.0;

    final dashPath = Path();
    final distance = (end - start).distance;

    for (double i = 0; i < distance; i += dashWidth + dashSpace) {
      final to = i + dashWidth < distance ? i + dashWidth : distance;
      dashPath.addPath(
          Path()
            ..moveTo(start.dx + (end.dx - start.dx) * i / distance,
                start.dy + (end.dy - start.dy) * i / distance)
            ..lineTo(start.dx + (end.dx - start.dx) * to / distance,
                start.dy + (end.dy - start.dy) * to / distance),
          Offset.zero);
    }

    canvas.drawPath(dashPath, paint);
  }

  /// Método para dibujar un control de redimensionamiento
  void _drawResizeHandle(Canvas canvas, Offset position, Paint paint) {
    // Usar círculos pequeños para un aspecto más moderno
    final fillPaint = Paint()
      ..color = selectionColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, 3.0, fillPaint);
    canvas.drawCircle(position, 3.0, paint);
  }

  /// Método para dibujar información de estado
  void _drawStateInfo(Canvas canvas) {
    // Usar un estilo más moderno para la información de estado
    final textColor = isDarkMode ? Colors.white70 : Colors.black87;
    final bgColor = isDarkMode
        ? Colors.grey[850]!.withOpacity(0.7)
        : Colors.white.withOpacity(0.7);
    final borderColor = isDarkMode ? Colors.grey[700]! : Colors.black12;

    final textStyle = ui.TextStyle(
      color: textColor,
      fontSize: 11.0, // Más pequeño para un aspecto minimalista
    );

    final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: ui.TextAlign.left,
      maxLines: 10,
      ellipsis: '...',
    ))
      ..pushStyle(textStyle);

    // Información básica
    paragraphBuilder.addText('Zoom: ${state.zoom.toStringAsFixed(1)}x');

    // Mostrar solo información esencial para un aspecto minimalista
    if (state.firstSelectedElement != null) {
      final element = state.firstSelectedElement!;
      paragraphBuilder
        ..addText(
            '\nElemento: ${element.runtimeType.toString().replaceAll("Parking", "")}')
        ..addText(
            '\nPos: (${element.position.x.toStringAsFixed(0)}, ${element.position.y.toStringAsFixed(0)})');
    } else if (state.selectedElements.isNotEmpty) {
      paragraphBuilder
          .addText('\nSeleccionados: ${state.selectedElements.length}');
    }

    final paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: 150.0));

    // Dibujar un fondo más sutil y moderno
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;

    final bgRect = Rect.fromLTWH(8.0, 8.0, 154.0, paragraph.height + 12.0);
    final rrect = RRect.fromRectAndRadius(bgRect, Radius.circular(8.0));

    // Añadir sombra sutil
    canvas.drawShadow(
      Path()..addRRect(rrect),
      Colors.black.withOpacity(0.2),
      3.0,
      true,
    );

    canvas.drawRRect(rrect, bgPaint);

    // Dibujar un borde sutil
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    canvas.drawRRect(rrect, borderPaint);

    // Posicionar el texto con un pequeño padding
    canvas.drawParagraph(
      paragraph,
      Offset(12.0, 14.0),
    );
  }

  /// Método para dibujar un icono en la barra de herramientas
  void _drawToolbarIcon(
    Canvas canvas,
    IconData icon,
    Offset center,
    double size,
    Color color,
  ) {
    // Dibujar un círculo de fondo para el icono
    final bgPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, size * 0.75, bgPaint);
    
    // Añadir un sutil efecto de brillo en la parte superior del círculo
    final highlightPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(center.dx - size * 0.2, center.dy - size * 0.2),
        size * 0.75,
        [
          Colors.white.withOpacity(0.3),
          Colors.transparent,
        ],
        [0.0, 1.0],
      )
      ..style = PaintingStyle.fill
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 2.0);
    
    canvas.drawCircle(
      Offset(center.dx - size * 0.2, center.dy - size * 0.2),
      size * 0.3,
      highlightPaint
    );
    
    // Dibujar el icono
    final iconSize = size;
    final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: ui.TextAlign.center,
      maxLines: 1,
    ))
      ..pushStyle(ui.TextStyle(
        color: color,
        fontSize: iconSize,
        fontFamily: icon.fontFamily,
        fontWeight: FontWeight.w500, // Un poco más visible
      ));

    // Usar el código del icono como texto
    paragraphBuilder.addText(String.fromCharCode(icon.codePoint));

    final paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: iconSize * 2));

    // Centrar el icono
    canvas.drawParagraph(
      paragraph,
      Offset(center.dx - iconSize / 2, center.dy - iconSize / 2),
    );
  }
}
