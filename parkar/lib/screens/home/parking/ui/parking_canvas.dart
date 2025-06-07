import 'dart:math';
import 'package:flutter/material.dart';
import '../core/engine.dart';
import '../core/vector2.dart';
import '../game_objects/game_object.dart';
import '../game_objects/collider_component.dart';
import '../parking_screen.dart';

/// Canvas widget for rendering the parking system using our game engine
class ParkingCanvas extends StatefulWidget {
  // Core properties
  final Engine engine;
  final List<GameObject> selectedObjects;
  final bool isEditMode;
  final EditorMode editorMode;
  
  // Callback functions
  final void Function(Offset position, List<GameObject> hitObjects)? onTap;
  final void Function(List<GameObject> objects, Vector2 delta)? onDragEnd;
  
  const ParkingCanvas({
    Key? key,
    required this.engine,
    this.selectedObjects = const [],
    this.isEditMode = false,
    this.editorMode = EditorMode.selection,
    this.onTap,
    this.onDragEnd,
  }) : super(key: key);

  @override
  State<ParkingCanvas> createState() => _ParkingCanvasState();
}

class _ParkingCanvasState extends State<ParkingCanvas> {
  // State for pan/zoom gestures
  Offset _lastPanPosition = Offset.zero;
  bool _isDragging = false;
  bool _isPanning = false;
  
  // Dragging state
  Offset _dragStart = Offset.zero;
  Vector2 _selectionStartPosition = Vector2.zero();
  List<Vector2> _initialPositions = [];
  
  // Selection box state
  bool _isSelecting = false;
  Offset _selectionStart = Offset.zero;
  Offset _selectionEnd = Offset.zero;
  
  // Frame time tracking
  int _lastFrameTimeMs = 0;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Handle taps
      onTapDown: _handleTapDown,
      
      // Use scale gesture recognizer only (superset of pan)
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      onScaleEnd: _handleScaleEnd,
      
      child: Container(
        color: Colors.grey[200],
        child: CustomPaint(
          painter: _ParkingCanvasPainter(
            engine: widget.engine,
            selectedObjects: widget.selectedObjects,
            isEditMode: widget.isEditMode,
            isSelecting: _isSelecting,
            selectionRect: _isSelecting
                ? Rect.fromPoints(_selectionStart, _selectionEnd)
                : null,
          ),
          size: Size.infinite,
          isComplex: true,
        ),
      ),
    );
  }
  
  /// Convert screen position to world position
  Vector2 _screenToWorld(Offset position) {
    final Size size = MediaQuery.of(context).size;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Offset from screen center - optimizado para rendimiento
    final offsetX = position.dx - centerX;
    final offsetY = position.dy - centerY;
    
    // Apply zoom - precalcular inverso para reducir división
    final invZoom = 1.0 / widget.engine.zoom;
    final worldX = offsetX * invZoom + widget.engine.cameraPosition.x;
    final worldY = offsetY * invZoom + widget.engine.cameraPosition.y;
    
    return Vector2(worldX, worldY);
  }
  
  /// Find game objects at the given screen position
  List<GameObject> _findObjectsAtPosition(Offset position) {
    final worldPos = _screenToWorld(position);
    final results = <GameObject>[];
    
    // Check all objects in the scene
    for (final obj in widget.engine.activeScene!.gameObjects) {
      if (!obj.isActive) continue;
      
      // Simple hit testing based on distance
      final objPos = obj.transform.worldPosition;
      final dx = objPos.x - worldPos.x;
      final dy = objPos.y - worldPos.y;
      final distance = sqrt(dx * dx + dy * dy);
      
      // Get object size (approximate)
      double objSize = 25.0;
      final collider = obj.getComponent<ColliderComponent>();
      if (collider != null) {
        objSize = max(collider.width, collider.height) / 2;
      }
      
      // Check if hit
      if (distance <= objSize) {
        results.add(obj);
      }
    }
    
    // Sort by distance (closest first)
    results.sort((a, b) {
      final posA = a.transform.worldPosition;
      final posB = b.transform.worldPosition;
      final distA = (posA.x - worldPos.x) * (posA.x - worldPos.x) + 
                    (posA.y - worldPos.y) * (posA.y - worldPos.y);
      final distB = (posB.x - worldPos.x) * (posB.x - worldPos.x) + 
                    (posB.y - worldPos.y) * (posB.y - worldPos.y);
      return distA.compareTo(distB);
    });
    
    return results;
  }
  
  /// Find game objects within the given rectangle
  List<GameObject> _findObjectsInRect(Rect rect) {
    final results = <GameObject>[];
    
    // Convert rectangle corners to world coordinates
    final topLeft = _screenToWorld(rect.topLeft);
    final bottomRight = _screenToWorld(rect.bottomRight);
    
    // Create world space rectangle
    final worldRect = Rect.fromPoints(
      Offset(topLeft.x, topLeft.y),
      Offset(bottomRight.x, bottomRight.y),
    );
    
    // Check all objects in the scene
    for (final obj in widget.engine.activeScene!.gameObjects) {
      if (!obj.isActive) continue;
      
      // Get object position
      final pos = obj.transform.worldPosition;
      final objPos = Offset(pos.x, pos.y);
      
      // Simple check if position is within rectangle
      if (worldRect.contains(objPos)) {
        results.add(obj);
      }
    }
    
    return results;
  }
  
  // Gesture handlers
  
  /// Handle tap down event
  void _handleTapDown(TapDownDetails details) {
    // Get hit objects
    final hits = _findObjectsAtPosition(details.localPosition);
    
    // Notify callback
    widget.onTap?.call(details.localPosition, hits);
  }
  
  /// Handle scale start event
  void _handleScaleStart(ScaleStartDetails details) {
    final position = details.focalPoint;
    _lastPanPosition = position;
    
    // In edit mode with selection tool, check if we're dragging selected objects
    if (widget.isEditMode && widget.editorMode == EditorMode.selection) {
      final hits = _findObjectsAtPosition(position);
      
      // Check if clicked on a selected object
      bool hitSelectedObject = false;
      for (final obj in hits) {
        if (widget.selectedObjects.contains(obj)) {
          hitSelectedObject = true;
          break;
        }
      }
      
      if (hitSelectedObject) {
        // Start dragging selected objects
        _isDragging = true;
        _dragStart = position;
        _initialPositions = widget.selectedObjects
            .map((obj) => Vector2.copy(obj.transform.position))
            .toList();
      } else {
        // Start selection rectangle
        _isSelecting = true;
        _selectionStart = position;
        _selectionEnd = position;
      }
    } else {
      // Normal panning
      _isPanning = true;
      _lastPanPosition = position;
    }
  }
  
  /// Handle scale update event
  void _handleScaleUpdate(ScaleUpdateDetails details) {
    final position = details.focalPoint;
    
    // Check if this is a pinch zoom (scale != 1.0)
    if (details.scale != 1.0) {
      // Update zoom level - limitar cambios para mejor rendimiento
      final previousZoom = widget.engine.zoom;
      final targetZoom = (previousZoom * details.scale).clamp(0.1, 5.0);
      
      // Suavizar cambio de zoom para mejor rendimiento
      final newZoom = previousZoom + (targetZoom - previousZoom) * 0.3;
      widget.engine.setZoom(newZoom);
      
      // Update last focal point to maintain context
      _lastPanPosition = position;
      return;
    } 
    
    // Regular dragging (not pinch-zoom) - limitar frecuencia de actualización
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_lastPanPosition != null && (now - _lastFrameTimeMs < 16)) {
      return; // Limitar a ~60fps para mejorar rendimiento
    }
    _lastFrameTimeMs = now;
    
    if (_isDragging && widget.isEditMode) {
      // Calculate drag delta in world space directly - implementación optimizada
      final invZoom = 1.0 / widget.engine.zoom; // Pre-calcular inversa
      final dx = (position.dx - _lastPanPosition!.dx) * invZoom;
      final dy = (position.dy - _lastPanPosition!.dy) * invZoom;
      
      if (dx.abs() < 0.1 && dy.abs() < 0.1) return; // Ignorar movimientos muy pequeños
      
      // Apply direct delta for smoother dragging
      for (final obj in widget.selectedObjects) {
        obj.transform.position = Vector2(
          obj.transform.position.x + dx,
          obj.transform.position.y + dy,
        );
      }
      
      // Update last position
      _lastPanPosition = position;
    } else if (_isSelecting && widget.isEditMode) {
      // Update selection rectangle
      _selectionEnd = position;
    } else if (_isPanning) {
      // Use delta directly to avoid cumulative errors
      final dx = position.dx - _lastPanPosition!.dx;
      final dy = position.dy - _lastPanPosition!.dy;
      
      // Ignorar movimientos muy pequeños
      if (dx.abs() < 0.5 && dy.abs() < 0.5) return;
      
      // Get current camera position and apply delta - optimizado
      final invZoom = 1.0 / widget.engine.zoom; // Pre-calcular inversa
      final currentPos = widget.engine.cameraPosition;
      widget.engine.setCameraPosition(Vector2(
        currentPos.x - dx * invZoom,
        currentPos.y - dy * invZoom,
      ));
      
      // Update last position
      _lastPanPosition = position;
    }
  }
  
  /// Handle scale end event
  void _handleScaleEnd(ScaleEndDetails details) {
    if (_isDragging) {
      // Finalize drag
      _isDragging = false;
      
      // Calculate final drag vector
      final dragVector = Vector2(
        (_lastPanPosition.dx - _dragStart.dx) / widget.engine.zoom,
        (_lastPanPosition.dy - _dragStart.dy) / widget.engine.zoom,
      );
      
      // Notify callback of the drag
      widget.onDragEnd?.call(widget.selectedObjects, dragVector);
    } else if (_isSelecting) {
      // Finalize selection rectangle
      _isSelecting = false;
      
      // Create selection rectangle
      final rect = Rect.fromPoints(_selectionStart, _selectionEnd);
      
      // Only process if rectangle is big enough (not just a tap)
      if (rect.width > 5 && rect.height > 5) {
        // Find objects in the selection rectangle
        final selectedObjects = _findObjectsInRect(rect);
        
        // Notify via tap callback
        widget.onTap?.call(_selectionStart, selectedObjects);
      }
      
      setState(() {});
    }
    
    _isPanning = false;
  }
}

/// Custom painter for the parking canvas
class _ParkingCanvasPainter extends CustomPainter {
  final Engine engine;
  final List<GameObject> selectedObjects;
  final bool isEditMode;
  final bool isSelecting;
  final Rect? selectionRect;
  
  _ParkingCanvasPainter({
    required this.engine,
    required this.selectedObjects,
    required this.isEditMode,
    this.isSelecting = false,
    this.selectionRect,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Save the canvas state
    canvas.save();
    
    // Apply camera transformation
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Translate to center of screen
    canvas.translate(centerX, centerY);
    
    // Scale by the zoom factor
    canvas.scale(engine.zoom);
    
    // Translate by the camera position (inverted since we're moving the view)
    canvas.translate(-engine.cameraPosition.x, -engine.cameraPosition.y);
    
    // Let the engine render the scene
    if (engine.activeScene != null) {
      engine.render(canvas, size);
    }
    
    // Draw selection indicators
    if (isEditMode && selectedObjects.isNotEmpty) {
      _drawSelectionIndicators(canvas);
    }
    
    // Restore canvas state
    canvas.restore();
    
    // Draw selection rectangle (in screen space)
    if (isSelecting && selectionRect != null) {
      _drawSelectionRectangle(canvas, selectionRect!);
    }
  }
  
  /// Draw indicators around selected objects
  void _drawSelectionIndicators(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 / engine.zoom;
    
    for (final obj in selectedObjects) {
      if (!obj.isActive) continue;
      
      // Get object position and size
      final pos = obj.transform.worldPosition;
      double width = 50.0;
      double height = 50.0;
      
      // Try to get size from collider
      final collider = obj.getComponent<ColliderComponent>();
      if (collider != null) {
        width = collider.width * obj.transform.worldScale.x;
        height = collider.height * obj.transform.worldScale.y;
      }
      
      // Draw selection rectangle
      final rect = Rect.fromCenter(
        center: Offset(pos.x, pos.y),
        width: width,
        height: height,
      );
      
      // Apply rotation if needed
      if (obj.transform.worldRotation != 0) {
        canvas.save();
        canvas.translate(pos.x, pos.y);
        canvas.rotate(obj.transform.worldRotation);
        canvas.translate(-pos.x, -pos.y);
        
        canvas.drawRect(rect, paint);
        
        // Draw selection handles
        _drawSelectionHandles(canvas, rect, paint);
        
        canvas.restore();
      } else {
        canvas.drawRect(rect, paint);
        _drawSelectionHandles(canvas, rect, paint);
      }
    }
  }
  
  /// Draw the selection handles
  void _drawSelectionHandles(Canvas canvas, Rect rect, Paint paint) {
    final handleSize = 5.0 / engine.zoom;
    
    // Draw the eight handles
    final handlePositions = [
      rect.topLeft,
      Offset(rect.center.dx, rect.top),
      rect.topRight,
      Offset(rect.right, rect.center.dy),
      rect.bottomRight,
      Offset(rect.center.dx, rect.bottom),
      rect.bottomLeft,
      Offset(rect.left, rect.center.dy),
    ];
    
    for (final pos in handlePositions) {
      canvas.drawRect(
        Rect.fromCenter(
          center: pos, 
          width: handleSize, 
          height: handleSize,
        ),
        paint,
      );
    }
  }
  
  /// Draw selection rectangle
  void _drawSelectionRectangle(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(rect, paint);
    
    final borderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawRect(rect, borderPaint);
  }
  
  @override
  bool shouldRepaint(_ParkingCanvasPainter oldDelegate) {
    return oldDelegate.engine != engine ||
           oldDelegate.isEditMode != isEditMode ||
           oldDelegate.isSelecting != isSelecting ||
           oldDelegate.selectionRect != selectionRect ||
           oldDelegate.selectedObjects != selectedObjects;
  }
} 