import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/scene.dart';
import '../core/vector2.dart';
import '../game_objects/game_object.dart';

/// System that handles rendering of all game objects in the scene
class RenderingSystem {
  // Rendering settings
  bool _drawGrid = false; // Por defecto desactivado para mejor rendimiento
  double _gridSize = 20.0;
  Color _gridColor = Colors.grey.withOpacity(0.3);
  bool _debugMode = false;
  
  // Optimization flags
  bool _simplifiedRendering = true; // Activado por defecto
  bool _useOcclusionCulling = true;
  bool _useLowDetailMode = true; // Para renderizado ultra simplificado
  
  // Frame skipping para ahorrar ciclos de CPU
  int _frameCounter = 0;
  int _renderEveryNFrames = 1; // Renderizar cada N frames
  
  // Cache para grid lines to avoid recalculating them every frame
  List<Offset> _verticalGridLines = [];
  List<Offset> _horizontalGridLines = [];
  bool _gridDirty = true;
  
  // Size del último canvas para evitar recálculos
  Size? _lastSize;
  
  // Getters and setters for rendering settings
  bool get drawGrid => _drawGrid;
  set drawGrid(bool value) => _drawGrid = value;
  
  double get gridSize => _gridSize;
  set gridSize(double value) { 
    _gridSize = value;
    _gridDirty = true; 
  }
  
  Color get gridColor => _gridColor;
  set gridColor(Color value) => _gridColor = value;
  
  bool get debugMode => _debugMode;
  set debugMode(bool value) => _debugMode = value;
  
  bool get simplifiedRendering => _simplifiedRendering;
  set simplifiedRendering(bool value) => _simplifiedRendering = value;
  
  bool get useLowDetailMode => _useLowDetailMode;
  set useLowDetailMode(bool value) => _useLowDetailMode = value;

  // Render the entire scene
  void render(Canvas canvas, Size size, Scene scene, double zoom, Vector2 cameraPosition) {
    // Incrementar contador de frames para frame skipping
    _frameCounter++;
    if (_frameCounter % _renderEveryNFrames != 0) {
      // No renderizar este frame para ahorrar ciclos
      return;
    }
    
    // Comprobar si cambió el tamaño para actualizar caché
    if (_lastSize == null || size.width != _lastSize!.width || size.height != _lastSize!.height) {
      _gridDirty = true;
      _lastSize = size;
    }
    
    // Save canvas state
    canvas.save();
    
    // Draw background (simple solid color for better performance)
    _drawBackground(canvas, size);
    
    // Draw grid if enabled - muy costoso en rendimiento
    if (_drawGrid && !_useLowDetailMode) {
      _renderGrid(canvas, size, zoom, cameraPosition);
    }
    
    // Calculate visible area for culling
    final Rect visibleRect = Rect.fromLTWH(
      cameraPosition.x - (size.width / 2) / zoom, 
      cameraPosition.y - (size.height / 2) / zoom,
      size.width / zoom,
      size.height / zoom
    );
    
    // Lista de elementos para renderizar
    List<GameObject> objectsToRender;
    
    // Modo ultra rápido - no ordenar ni culling agresivo
    if (_useLowDetailMode) {
      // Limitar la cantidad de objetos a renderizar y evitar ordenar
      objectsToRender = scene.gameObjects.where((obj) => obj.isActive).take(100).toList();
    }
    // Modo simplificado pero con culling normal
    else if (_simplifiedRendering) {
      objectsToRender = scene.gameObjects.where((obj) => obj.isActive).toList();
      
      // Aplicar culling si está activado
      if (_useOcclusionCulling) {
        objectsToRender = _applyOcclusionCulling(objectsToRender, visibleRect);
      }
    } 
    // Modo normal con ordenamiento por capas
    else {
      // Ordenar objetos por capa - operación costosa
      objectsToRender = List.of(scene.gameObjects.where((obj) => obj.isActive));
      objectsToRender.sort((a, b) => a.layer.compareTo(b.layer));
      
      if (_useOcclusionCulling) {
        objectsToRender = _applyOcclusionCulling(objectsToRender, visibleRect);
      }
    }
    
    // Renderizar objetos usando la técnica más rápida
    _renderObjects(canvas, objectsToRender, zoom);
    
    // Draw debug information if debug mode is enabled
    if (_debugMode && !_useLowDetailMode) {
      _drawDebugInfo(canvas, size, scene, zoom, objectsToRender.length);
    }
    
    // Restore canvas state
    canvas.restore();
  }
  
  /// Aplicar occlusion culling como función separada para el perfil de rendimiento
  List<GameObject> _applyOcclusionCulling(List<GameObject> objects, Rect visibleRect) {
    if (objects.length <= 10) return objects; // No aplicar para pocos objetos
    
    return objects.where((obj) {
      final pos = obj.transform.worldPosition;
      
      // Culling agresivo - distancia máxima más corta para alto rendimiento
      final radius = _useLowDetailMode ? 50.0 : 100.0;
      return (pos.x + radius > visibleRect.left &&
              pos.x - radius < visibleRect.right &&
              pos.y + radius > visibleRect.top &&
              pos.y - radius < visibleRect.bottom);
    }).toList();
  }
  
  /// Renderizar objetos con técnica optimizada
  void _renderObjects(Canvas canvas, List<GameObject> objects, double zoom) {
    // En modo ultraligero, limitar número de objetos
    final int maxObjectsToRender = _useLowDetailMode ? 50 : 200;
    final int objectCount = objects.length > maxObjectsToRender ? maxObjectsToRender : objects.length;
    
    // Renderizar solo los objetos visibles y limitar cantidad
    for (int i = 0; i < objectCount; i++) {
      objects[i].render(canvas, zoom);
    }
  }
  
  // Draw background
  void _drawBackground(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(rect, paint);
  }
  
  // Draw grid
  void _renderGrid(Canvas canvas, Size size, double zoom, Vector2 cameraPosition) {
    // Saltar si estamos en modo ultraligero
    if (_useLowDetailMode) return;
    
    // Use cached grid lines if possible
    if (_gridDirty || _verticalGridLines.isEmpty || _horizontalGridLines.isEmpty) {
      _calculateGridLines(size, zoom, cameraPosition);
      _gridDirty = false;
    }
    
    final gridPaint = Paint()
      ..color = _gridColor
      ..strokeWidth = 0.5;
    
    // Optimización: Dibujar menos líneas en zoom bajo
    final maxLinesToDraw = zoom < 0.5 ? 30 : 100;
    
    // Draw vertical lines - limitar cantidad para rendimiento
    final vCount = _verticalGridLines.length ~/ 2;
    final vStep = vCount > maxLinesToDraw ? (vCount ~/ maxLinesToDraw) : 1;
    
    for (int i = 0; i < _verticalGridLines.length - 1; i += 2 * vStep) {
      if (i + 1 < _verticalGridLines.length) {
        canvas.drawLine(_verticalGridLines[i], _verticalGridLines[i+1], gridPaint);
      }
    }
    
    // Draw horizontal lines - limitar cantidad para rendimiento
    final hCount = _horizontalGridLines.length ~/ 2;
    final hStep = hCount > maxLinesToDraw ? (hCount ~/ maxLinesToDraw) : 1;
    
    for (int i = 0; i < _horizontalGridLines.length - 1; i += 2 * hStep) {
      if (i + 1 < _horizontalGridLines.length) {
        canvas.drawLine(_horizontalGridLines[i], _horizontalGridLines[i+1], gridPaint);
      }
    }
    
    // Centro solo si no estamos en modo ultraligero
    if (!_useLowDetailMode) {
      // Draw center crosshair
      final centerX = size.width / 2 - cameraPosition.x * zoom;
      final centerY = size.height / 2 - cameraPosition.y * zoom;
      
      final centerPaint = Paint()
        ..color = Colors.red.withOpacity(0.5)
        ..strokeWidth = 1.0;
      
      canvas.drawLine(
        Offset(centerX - 10, centerY),
        Offset(centerX + 10, centerY),
        centerPaint,
      );
      
      canvas.drawLine(
        Offset(centerX, centerY - 10),
        Offset(centerX, centerY + 10),
        centerPaint,
      );
    }
  }
  
  // Pre-calculate grid lines for better performance
  void _calculateGridLines(Size size, double zoom, Vector2 cameraPosition) {
    _verticalGridLines = [];
    _horizontalGridLines = [];
    
    final gridSizeScaled = _gridSize * zoom;
    final startX = (cameraPosition.x * zoom) % gridSizeScaled - gridSizeScaled;
    final startY = (cameraPosition.y * zoom) % gridSizeScaled - gridSizeScaled;
    
    // Calculate how many lines we need based on screen size (max 100 lines)
    final vLineCount = (size.width / gridSizeScaled).ceil() + 2;
    final hLineCount = (size.height / gridSizeScaled).ceil() + 2;
    
    // Limitar cantidad de líneas para mejor rendimiento
    final maxLines = 100;
    final vStride = vLineCount > maxLines ? (vLineCount / maxLines).ceil() : 1;
    final hStride = hLineCount > maxLines ? (hLineCount / maxLines).ceil() : 1;
    
    // Pre-calculate vertical lines
    for (int i = 0; i < vLineCount; i += vStride) {
      final x = startX + i * gridSizeScaled;
      _verticalGridLines.add(Offset(x, 0));
      _verticalGridLines.add(Offset(x, size.height));
    }
    
    // Pre-calculate horizontal lines
    for (int i = 0; i < hLineCount; i += hStride) {
      final y = startY + i * gridSizeScaled;
      _horizontalGridLines.add(Offset(0, y));
      _horizontalGridLines.add(Offset(size.width, y));
    }
  }
  
  // Draw debug information
  void _drawDebugInfo(Canvas canvas, Size size, Scene scene, double zoom, int visibleCount) {
    // Skip en modo ultra rápido
    if (_useLowDetailMode) return;
    
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );
    
    final objectCount = scene.gameObjects.length;
    final activeCount = scene.gameObjects.where((obj) => obj.isActive).length;
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Objetos: $objectCount (activos: $activeCount, visibles: $visibleCount)\n'
             'Zoom: ${(zoom * 100).toStringAsFixed(0)}%',
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    // Draw background for text
    final rectPaint = Paint()..color = Colors.white.withOpacity(0.8);
    canvas.drawRect(
      Rect.fromLTWH(10, 10, textPainter.width + 10, textPainter.height + 10),
      rectPaint,
    );
    
    textPainter.paint(canvas, const Offset(15, 15));
  }
  
  // Cambiar configuración para modo ultra rápido
  void setUltraPerformanceMode(bool enabled) {
    _useLowDetailMode = enabled;
    _simplifiedRendering = enabled;
    _drawGrid = !enabled; // Desactivar grid en modo ultra rápido
    _renderEveryNFrames = enabled ? 2 : 1; // Frame skipping en modo ultra rápido
  }
} 