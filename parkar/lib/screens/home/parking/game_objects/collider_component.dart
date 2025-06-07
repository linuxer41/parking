import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/vector2.dart';
import 'game_object.dart';
import '../systems/physics_system.dart';

/// Collider component for collision detection
class ColliderComponent extends Component {
  // Collider properties
  ColliderShape _shape;
  bool _isTrigger;
  double _width;
  double _height;
  double _radius;
  Vector2 _offset;
  Color _debugColor;
  
  // Collision callback
  Function(ColliderComponent)? onCollisionEnter;
  Function(ColliderComponent)? onCollisionExit;
  Function(ColliderComponent)? onTriggerEnter;
  Function(ColliderComponent)? onTriggerExit;
  
  // Last collisions for tracking enter/exit events
  final Set<String> _currentCollisions = {};
  
  // Getters
  ColliderShape get shape => _shape;
  bool get isTrigger => _isTrigger;
  double get width => _width;
  double get height => _height;
  double get radius => _radius;
  Vector2 get offset => _offset;
  
  /// Get the bounds of the collider in world space
  Rect get bounds {
    final transform = gameObject!.transform;
    final worldPos = transform.worldPosition;
    final worldScale = transform.worldScale;
    
    // Apply offset to position
    final offsetX = _offset.x * worldScale.x;
    final offsetY = _offset.y * worldScale.y;
    final posX = worldPos.x + offsetX;
    final posY = worldPos.y + offsetY;
    
    switch (_shape) {
      case ColliderShape.box:
        final scaledWidth = _width * worldScale.x;
        final scaledHeight = _height * worldScale.y;
        return Rect.fromCenter(
          center: Offset(posX, posY),
          width: scaledWidth,
          height: scaledHeight,
        );
      case ColliderShape.circle:
        final scaledRadius = _radius * (worldScale.x + worldScale.y) / 2;
        return Rect.fromCenter(
          center: Offset(posX, posY),
          width: scaledRadius * 2,
          height: scaledRadius * 2,
        );
    }
  }
  
  // Box collider constructor
  ColliderComponent.box({
    double width = 50.0,
    double height = 50.0,
    Vector2? offset,
    bool isTrigger = false,
    Color debugColor = Colors.green,
  }) : _shape = ColliderShape.box,
       _width = width,
       _height = height,
       _radius = 0.0,
       _isTrigger = isTrigger,
       _offset = offset ?? Vector2.zero(),
       _debugColor = debugColor;
  
  // Circle collider constructor
  ColliderComponent.circle({
    double radius = 25.0,
    Vector2? offset,
    bool isTrigger = false,
    Color debugColor = Colors.green,
  }) : _shape = ColliderShape.circle,
       _width = radius * 2,
       _height = radius * 2,
       _radius = radius,
       _isTrigger = isTrigger,
       _offset = offset ?? Vector2.zero(),
       _debugColor = debugColor;
  
  @override
  void onRender(Canvas canvas, Offset position, double zoom) {
    // Only render in debug mode
    if (!_shouldRenderDebug()) return;
    
    final paint = Paint()
      ..color = _debugColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    final worldPos = gameObject!.transform.worldPosition;
    final worldScale = gameObject!.transform.worldScale;
    
    // Apply offset to position
    final offsetX = _offset.x * worldScale.x * zoom;
    final offsetY = _offset.y * worldScale.y * zoom;
    final posX = position.dx + offsetX;
    final posY = position.dy + offsetY;
    
    switch (_shape) {
      case ColliderShape.box:
        final scaledWidth = _width * worldScale.x * zoom;
        final scaledHeight = _height * worldScale.y * zoom;
        final rect = Rect.fromCenter(
          center: Offset(posX, posY),
          width: scaledWidth,
          height: scaledHeight,
        );
        canvas.drawRect(rect, paint);
        break;
        
      case ColliderShape.circle:
        final scaledRadius = _radius * (worldScale.x + worldScale.y) / 2 * zoom;
        canvas.drawCircle(Offset(posX, posY), scaledRadius, paint);
        break;
    }
    
    // Draw 'T' for trigger
    if (_isTrigger) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'T',
          style: TextStyle(
            color: _debugColor,
            fontSize: 10.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas, 
        Offset(
          posX - textPainter.width / 2, 
          posY - textPainter.height / 2
        ),
      );
    }
  }
  
  /// Check if debug rendering should be shown
  bool _shouldRenderDebug() {
    return true; // Could be controlled by a global debug setting
  }
  
  /// Handle collision with another collider
  void onCollision(ColliderComponent other) {
    final otherId = other.gameObject!.id;
    
    // Track collisions for enter/exit events
    if (!_currentCollisions.contains(otherId)) {
      _currentCollisions.add(otherId);
      
      // Fire appropriate event
      if (_isTrigger) {
        onTriggerEnter?.call(other);
      } else {
        onCollisionEnter?.call(other);
      }
    }
  }
  
  /// Handle end of collision
  void endCollision(ColliderComponent other) {
    final otherId = other.gameObject!.id;
    
    if (_currentCollisions.remove(otherId)) {
      // Fire appropriate event
      if (_isTrigger) {
        onTriggerExit?.call(other);
      } else {
        onCollisionExit?.call(other);
      }
    }
  }
  
  /// Clear all current collisions (useful when destroying the collider)
  void clearCollisions() {
    _currentCollisions.clear();
  }
  
  @override
  void onDestroy() {
    clearCollisions();
  }
  
  @override
  Component clone() {
    switch (_shape) {
      case ColliderShape.box:
        return ColliderComponent.box(
          width: _width,
          height: _height,
          offset: Vector2.copy(_offset),
          isTrigger: _isTrigger,
          debugColor: _debugColor,
        );
      case ColliderShape.circle:
        return ColliderComponent.circle(
          radius: _radius,
          offset: Vector2.copy(_offset),
          isTrigger: _isTrigger,
          debugColor: _debugColor,
        );
    }
  }
} 