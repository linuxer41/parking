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

  // Caché de elementos visibles
  List<WorldElement>? _visibleElements;
  
  // Flags para invalidar caché
  bool _cacheInvalidated = true;
  Size? _lastCanvasSize;
  double? _lastZoom;
  vector_math.Vector2? _lastCameraPosition;

  WorldRenderer({
    required this.state,
    required this.canvasSize,
    this.showGrid = true,
    this.gridSize = 20.0,
    this.gridColor = Colors.grey,
    this.gridOpacity = 0.3,
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

    // Actualizar caché de elementos visibles si es necesario
    if (_shouldUpdateCache()) {
      _updateVisibleElementsCache();
    }

    // Dibujar elementos visibles
    _renderVisibleElements(canvas);

    // Dibujar elementos de interfaz adicionales
    _drawUI(canvas);
  }

  /// Obtiene solo los elementos que son visibles en el viewport actual
  List<WorldElement> _getVisibleElements() {
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

    // Aplicar culling: filtrar elementos visibles y en el nivel actual
    // Ampliamos ligeramente el área visible para evitar apariciones abruptas
    final visibleRect = Rect.fromLTWH(
      -100, -100, 
      canvasSize.width + 200, 
      canvasSize.height + 200
    );
    
    return orderedElements.where((element) {
      // Verificar si el elemento está en la vista actual
      final screenPos = element.getScreenPosition(state.zoom, state.cameraPosition);
      final isInView = visibleRect.contains(Offset(screenPos.x, screenPos.y));

      // Verificar si el elemento es visible
      return element.isVisible && 
             isInView;
    }).toList();
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

  /// Método para dibujar la cuadrícula de manera optimizada
  void _drawGrid(Canvas canvas) {
    final Color effectiveGridColor = isDarkMode
        ? Colors.white.withOpacity(gridOpacity * 0.7)
        : gridColor.withOpacity(gridOpacity);

    // Reutilizar el mismo objeto Paint para mejor rendimiento
    final paint = Paint()
      ..color = effectiveGridColor
      ..strokeWidth = 0.5;

    final effectiveGridSize = gridSize * state.zoom;
    final offsetX = state.cameraPosition.x % effectiveGridSize;
    final offsetY = state.cameraPosition.y % effectiveGridSize;
    
    // Calcular líneas visibles para evitar dibujar más allá de los límites
    final int verticalLinesCount = (canvasSize.width / effectiveGridSize).ceil() + 1;
    final int horizontalLinesCount = (canvasSize.height / effectiveGridSize).ceil() + 1;
    
    // Crear listas de puntos para dibujar todas las líneas a la vez
    final List<Offset> gridPoints = [];
    
    // Añadir puntos para líneas verticales
    for (int i = 0; i < verticalLinesCount; i++) {
      final x = -offsetX + i * effectiveGridSize;
      gridPoints.add(Offset(x, 0));
      gridPoints.add(Offset(x, canvasSize.height));
    }
    
    // Añadir puntos para líneas horizontales
    for (int i = 0; i < horizontalLinesCount; i++) {
      final y = -offsetY + i * effectiveGridSize;
      gridPoints.add(Offset(0, y));
      gridPoints.add(Offset(canvasSize.width, y));
    }
    
    // Dibujar todas las líneas de la cuadrícula a la vez
    canvas.drawPoints(ui.PointMode.lines, gridPoints, paint);
    
    // Dibujar líneas principales más destacadas
    final mainGridSize = effectiveGridSize * 5;
    final mainOffsetX = state.cameraPosition.x % mainGridSize;
    final mainOffsetY = state.cameraPosition.y % mainGridSize;
    
    // Reutilizar el mismo objeto Paint para las líneas principales
    paint.color = effectiveGridColor.withOpacity(gridOpacity * 2);
    paint.strokeWidth = 0.8;
    
    // Crear listas de puntos para las líneas principales
    final List<Offset> mainGridPoints = [];
    
    // Añadir puntos para líneas verticales principales
    for (int i = 0; i <= (canvasSize.width / mainGridSize).ceil(); i++) {
      final x = -mainOffsetX + i * mainGridSize;
      mainGridPoints.add(Offset(x, 0));
      mainGridPoints.add(Offset(x, canvasSize.height));
    }
    
    // Añadir puntos para líneas horizontales principales
    for (int i = 0; i <= (canvasSize.height / mainGridSize).ceil(); i++) {
      final y = -mainOffsetY + i * mainGridSize;
      mainGridPoints.add(Offset(0, y));
      mainGridPoints.add(Offset(canvasSize.width, y));
    }
    
    // Dibujar todas las líneas principales a la vez
    canvas.drawPoints(ui.PointMode.lines, mainGridPoints, paint);
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
  void _drawElements(Canvas canvas, List<WorldElement> visibleElements) {
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

  /// Método para dibujar la barra de herramientas del elemento con estilo minimalista
  void _drawElementToolbar(
      Canvas canvas, WorldElement element, vector_math.Vector2 screenPos) {
    // Calcular posición de la barra de herramientas (debajo del elemento)
    final toolbarY = screenPos.y + (element.size.height * state.zoom / 2) + 12;
    final toolbarX = screenPos.x;

    // Configuración ultraminimalista de la barra de herramientas
    final iconSize = 14.0; // Iconos más pequeños
    final iconSpacing = 8.0; // Menos espacio entre iconos
    final totalButtons = 5;
    final totalWidth = (iconSize * totalButtons) + (iconSpacing * (totalButtons - 1));

    // Colores adaptados según el tema
    final bgColor = isDarkMode ? Colors.grey[900]! : Colors.white;
    final Color accentColor = isDarkMode ? Colors.white70 : Colors.grey[800]!;

    // Crear un contenedor con efecto de vidrio (glassmorphism)
    final glassBgPaint = Paint()
      ..color = bgColor.withOpacity(0.7) // Fondo translúcido
      ..style = PaintingStyle.fill;

    // Borde muy sutil
    final borderPaint = Paint()
      ..color = accentColor.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Forma redondeada para la barra de herramientas
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(toolbarX, toolbarY),
        width: totalWidth + 12, // Más compacto
        height: iconSize + 8, // Más delgado
      ),
      Radius.circular(iconSize), // Bordes completamente redondeados
    );

    // Añadir sombra ultraligera
    canvas.drawShadow(
      Path()..addRRect(bgRect),
      Colors.black.withOpacity(0.1),
      1.5,
      true,
    );

    // Dibujar el fondo con efecto de vidrio
    canvas.drawRRect(bgRect, glassBgPaint);
    
    // Efecto sutil de brillo
    final Path highlightPath = Path();
    final Rect highlightRect = Rect.fromLTRB(
      bgRect.left + 1, 
      bgRect.top + 1, 
      bgRect.right - 1, 
      bgRect.top + (bgRect.height * 0.5)
    );
    highlightPath.addRRect(RRect.fromRectAndCorners(
      highlightRect,
      topLeft: Radius.circular(iconSize),
      topRight: Radius.circular(iconSize),
    ));
    
    final Paint highlightPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(highlightRect.left, highlightRect.top),
        Offset(highlightRect.left, highlightRect.bottom),
        [
          Colors.white.withOpacity(isDarkMode ? 0.1 : 0.2),
          Colors.white.withOpacity(0.0),
        ],
      )
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(highlightPath, highlightPaint);
    
    // Dibujar el borde ultraligero
    canvas.drawRRect(bgRect, borderPaint);

    // Posiciones de los iconos
    final startX = toolbarX - totalWidth / 2 + iconSize / 2;

    // Colores monocromáticos para un aspecto más minimalista
    final baseColor = isDarkMode ? Colors.white : Colors.grey[800]!;
    final deleteColor = Colors.red.shade400;
    
    // Iconos con espaciado uniforme
    _drawMinimalistIcon(canvas, Icons.delete_outline, 
        Offset(startX, toolbarY), iconSize, deleteColor.withOpacity(0.8));
        
    _drawMinimalistIcon(canvas, Icons.rotate_left, 
        Offset(startX + (iconSize + iconSpacing), toolbarY), 
        iconSize, baseColor.withOpacity(0.8));
        
    _drawMinimalistIcon(canvas, Icons.rotate_right, 
        Offset(startX + (iconSize + iconSpacing) * 2, toolbarY), 
        iconSize, baseColor.withOpacity(0.8));
        
    _drawMinimalistIcon(canvas, Icons.content_copy, 
        Offset(startX + (iconSize + iconSpacing) * 3, toolbarY), 
        iconSize, baseColor.withOpacity(0.8));
        
    _drawMinimalistIcon(canvas, Icons.edit, 
        Offset(startX + (iconSize + iconSpacing) * 4, toolbarY), 
        iconSize, baseColor.withOpacity(0.8));
  }
  
  /// Método para dibujar un icono minimalista
  void _drawMinimalistIcon(
    Canvas canvas,
    IconData icon,
    Offset center,
    double size,
    Color color,
  ) {
    // Dibujar el icono directamente, sin círculo de fondo
    final iconSize = size * 1.2; // Ligeramente más grande para mejor visibilidad
    final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: ui.TextAlign.center,
      maxLines: 1,
    ))
      ..pushStyle(ui.TextStyle(
        color: color,
        fontSize: iconSize,
        fontFamily: icon.fontFamily,
        fontWeight: FontWeight.w300, // Más delgado para aspecto minimalista
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
    // Método vacío - overlay eliminado
  }

  /// Renderizar elementos visibles
  void _renderVisibleElements(Canvas canvas) {
    if (_visibleElements == null) return;
    
    // Ordenar elementos por capa para renderizar en el orden correcto
    // (primero los que están más atrás)
    _visibleElements!.sort((a, b) => a.renderPriority.compareTo(b.renderPriority));
    
    // Renderizar cada elemento visible
    for (final element in _visibleElements!) {
      // Usar el sistema de transformación matricial para optimizar
      canvas.save();
      
      // Aplicar zoom y desplazamiento de cámara
      canvas.translate(-state.cameraPosition.x, -state.cameraPosition.y);
      canvas.scale(state.zoom, state.zoom);
      
      // Renderizar el elemento
      element.render(canvas, canvasSize, state.zoom, state.cameraPosition);
      
      canvas.restore();
    }
  }
  
  /// Verificar si se debe actualizar la caché de elementos visibles
  bool _shouldUpdateCache() {
    // Actualizar si la caché está invalidada o si algún parámetro relevante ha cambiado
    if (_cacheInvalidated || 
        _visibleElements == null ||
        _lastCanvasSize != canvasSize ||
        _lastZoom != state.zoom ||
        _lastCameraPosition?.x != state.cameraPosition.x ||
        _lastCameraPosition?.y != state.cameraPosition.y) {
      return true;
    }
    
    return false;
  }
  
  /// Actualizar la caché de elementos visibles
  void _updateVisibleElementsCache() {
    // Calcular el área visible en coordenadas del mundo
    final visibleRect = Rect.fromLTWH(
      state.cameraPosition.x / state.zoom,
      state.cameraPosition.y / state.zoom,
      canvasSize.width / state.zoom,
      canvasSize.height / state.zoom,
    );
    
    // Filtrar elementos visibles (dentro del área visible)
    _visibleElements = state.allElements.where((element) {
      if (!element.isVisible) return false;
      
      // Calcular el rectángulo del elemento en coordenadas del mundo
      final elementRect = Rect.fromCenter(
        center: Offset(element.position.x, element.position.y),
        width: element.size.width,
        height: element.size.height,
      );
      
      // Comprobar si el elemento está dentro del área visible
      // (con un margen para elementos parcialmente visibles)
      return visibleRect.overlaps(elementRect);
    }).toList();
    
    // Actualizar parámetros para la próxima comprobación
    _lastCanvasSize = canvasSize;
    _lastZoom = state.zoom;
    _lastCameraPosition = vector_math.Vector2(state.cameraPosition.x, state.cameraPosition.y);
    _cacheInvalidated = false;
  }
  
  /// Invalidar la caché de elementos visibles
  void invalidateCache() {
    _cacheInvalidated = true;
  }
}
