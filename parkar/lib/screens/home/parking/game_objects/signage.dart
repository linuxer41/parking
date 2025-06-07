import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/vector2.dart';
import 'game_object.dart';
import 'collider_component.dart';
import 'render_component.dart';

/// Enumeration for the types of signage
enum SignageType {
  info,       // General information
  entrance,   // Entrance sign
  exit,       // Exit sign
  noParking,  // No parking zone
  oneWay,     // One-way traffic
  twoWay,     // Two-way traffic
}

/// Represents a signage element in the parking scene
class Signage extends GameObject {
  // Signage properties
  SignageType _signageType;
  int _direction; // 0: up, 1: right, 2: down, 3: left
  
  // Components
  late RenderComponent _renderer;
  late ColliderComponent _collider;
  
  // Getters
  SignageType get signageType => _signageType;
  int get direction => _direction;
  
  // Constructor
  Signage({
    required String id,
    required String label,
    required Vector2 position,
    double rotation = 0.0,
    SignageType signageType = SignageType.info,
    int direction = 0,
    Vector2? size,
  }) : _signageType = signageType,
       _direction = direction % 4, // Ensure it's in the 0-3 range
       super(
         id: id,
         name: label,
         tag: 'Signage',
         position: position,
         rotation: rotation,
       ) {
    
    // Get default size based on signage type
    final defaultSize = _getDefaultSize(signageType);
    final signageSize = size ?? defaultSize;
    
    // Set up the transform with the right scale
    transform.scale = Vector2(signageSize.x / defaultSize.x, signageSize.y / defaultSize.y);
    
    // Add renderer component
    _renderer = addComponent(SignageRenderComponent(
      signageType: signageType,
      direction: _direction,
    ));
    
    // Add collider component for interaction
    _collider = addComponent(ColliderComponent.box(
      width: signageSize.x,
      height: signageSize.y,
      isTrigger: true,
    ));
    
    // Apply rotation based on direction
    _applyDirectionRotation();
  }
  
  /// Get default size for the signage type
  Vector2 _getDefaultSize(SignageType type) {
    switch (type) {
      case SignageType.info:
        return Vector2(40.0, 40.0);
      case SignageType.entrance:
        return Vector2(50.0, 50.0);
      case SignageType.exit:
        return Vector2(50.0, 50.0);
      case SignageType.noParking:
        return Vector2(40.0, 40.0);
      case SignageType.oneWay:
        return Vector2(40.0, 60.0);
      case SignageType.twoWay:
        return Vector2(40.0, 60.0);
    }
  }
  
  /// Change the type of the signage
  void setType(SignageType newType) {
    if (_signageType != newType) {
      _signageType = newType;
      
      // Update the renderer
      if (_renderer is SignageRenderComponent) {
        (_renderer as SignageRenderComponent).signageType = newType;
      }
      
      // Update size based on type
      final newSize = _getDefaultSize(newType);
      if (_collider is ColliderComponent) {
        // Remove old collider
        removeComponent(_collider);
        
        // Add new collider with new size
        _collider = addComponent(ColliderComponent.box(
          width: newSize.x,
          height: newSize.y,
          isTrigger: true,
        ));
      }
      
      // Update scale
      transform.scale = Vector2(1.0, 1.0);
    }
  }
  
  /// Set the direction of the signage
  void setDirection(int newDirection) {
    final normalized = newDirection % 4; // Ensure it's in the 0-3 range
    if (_direction != normalized) {
      _direction = normalized;
      
      // Update the renderer
      if (_renderer is SignageRenderComponent) {
        (_renderer as SignageRenderComponent).direction = normalized;
      }
      
      // Update rotation
      _applyDirectionRotation();
    }
  }
  
  /// Apply rotation based on direction
  void _applyDirectionRotation() {
    // Calculate rotation in radians
    final rotationAngle = _direction * (3.14159 / 2); // 90 degrees per direction
    transform.rotation = rotationAngle;
  }
  
  /// Rotate signage to next direction (clockwise)
  void rotateClockwise() {
    setDirection((_direction + 1) % 4);
  }
  
  /// Rotate signage to previous direction (counter-clockwise)
  void rotateCounterClockwise() {
    setDirection((_direction + 3) % 4);
  }
  
  @override
  GameObject clone() {
    return Signage(
      id: '${id}_clone',
      label: name,
      position: transform.position,
      rotation: transform.rotation,
      signageType: _signageType,
      direction: _direction,
      size: Vector2(
        _collider.width,
        _collider.height,
      ),
    );
  }
}

/// Render component for signage elements
class SignageRenderComponent extends RenderComponent {
  // Properties
  SignageType _signageType;
  int _direction;
  
  // Getters and setters
  SignageType get signageType => _signageType;
  set signageType(SignageType value) {
    if (_signageType != value) {
      _signageType = value;
      markDirty();
    }
  }
  
  int get direction => _direction;
  set direction(int value) {
    final normalized = value % 4; // Ensure it's in the 0-3 range
    if (_direction != normalized) {
      _direction = normalized;
      markDirty();
    }
  }
  
  // Constructor
  SignageRenderComponent({
    required SignageType signageType,
    int direction = 0,
  }) : _signageType = signageType,
       _direction = direction % 4;
  
  @override
  void render(Canvas canvas, Offset position, Size size, double rotation, double zoom) {
    // Save canvas state
    canvas.save();
    
    // Get colors and icon data
    final colors = _getColors();
    final iconData = _getIconData();
    
    // Draw the signage
    final rect = Rect.fromCenter(
      center: position,
      width: size.width * zoom,
      height: size.height * zoom,
    );
    
    // Draw background shape based on signage type
    _drawBackground(canvas, rect, colors);
    
    // Draw signage icon
    _drawIcon(canvas, position, rect, iconData, colors, zoom);
    
    // Draw label if needed
    final label = gameObject?.name ?? '';
    if (label.isNotEmpty) {
      _drawLabel(canvas, position, rect, label, colors.textColor, zoom);
    }
    
    // Restore canvas state
    canvas.restore();
  }
  
  /// Draw the background shape
  void _drawBackground(Canvas canvas, Rect rect, _SignageColors colors) {
    switch (_signageType) {
      case SignageType.info:
        _drawInfoBackground(canvas, rect, colors);
        break;
      case SignageType.entrance:
        _drawEntranceBackground(canvas, rect, colors);
        break;
      case SignageType.exit:
        _drawExitBackground(canvas, rect, colors);
        break;
      case SignageType.noParking:
        _drawNoParking(canvas, rect, colors);
        break;
      case SignageType.oneWay:
      case SignageType.twoWay:
        _drawDirectionBackground(canvas, rect, colors);
        break;
    }
  }
  
  /// Draw info sign background (circle)
  void _drawInfoBackground(Canvas canvas, Rect rect, _SignageColors colors) {
    final radius = rect.width < rect.height ? rect.width / 2 : rect.height / 2;
    
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = colors.fillColor;
    
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = colors.borderColor;
      
    // Draw circle
    canvas.drawCircle(rect.center, radius, fillPaint);
    canvas.drawCircle(rect.center, radius, strokePaint);
  }
  
  /// Draw entrance sign background (circle with arrow)
  void _drawEntranceBackground(Canvas canvas, Rect rect, _SignageColors colors) {
    final radius = rect.width < rect.height ? rect.width / 2 : rect.height / 2;
    
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = colors.fillColor;
    
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = colors.borderColor;
      
    // Draw circle
    canvas.drawCircle(rect.center, radius, fillPaint);
    canvas.drawCircle(rect.center, radius, strokePaint);
  }
  
  /// Draw exit sign background
  void _drawExitBackground(Canvas canvas, Rect rect, _SignageColors colors) {
    final radius = rect.width < rect.height ? rect.width / 2 : rect.height / 2;
    
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = colors.fillColor;
    
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = colors.borderColor;
      
    // Draw circle
    canvas.drawCircle(rect.center, radius, fillPaint);
    canvas.drawCircle(rect.center, radius, strokePaint);
  }
  
  /// Draw no parking sign
  void _drawNoParking(Canvas canvas, Rect rect, _SignageColors colors) {
    final radius = rect.width < rect.height ? rect.width / 2 : rect.height / 2;
    
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = colors.fillColor;
    
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = colors.borderColor;
    
    // Draw circle
    canvas.drawCircle(rect.center, radius, fillPaint);
    canvas.drawCircle(rect.center, radius, strokePaint);
    
    // Draw diagonal line for "no"
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = colors.borderColor;
      
    canvas.drawLine(
      Offset(rect.left + rect.width * 0.2, rect.top + rect.height * 0.2),
      Offset(rect.right - rect.width * 0.2, rect.bottom - rect.height * 0.2),
      linePaint,
    );
  }
  
  /// Draw directional sign background (rectangle)
  void _drawDirectionBackground(Canvas canvas, Rect rect, _SignageColors colors) {
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = colors.fillColor;
    
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = colors.borderColor;
      
    // Draw rectangle
    canvas.drawRect(rect, fillPaint);
    canvas.drawRect(rect, strokePaint);
  }
  
  /// Draw the icon for the signage type
  void _drawIcon(Canvas canvas, Offset position, Rect rect, IconData icon, _SignageColors colors, double zoom) {
    final iconSize = _getIconSize() * zoom;
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          fontFamily: icon.fontFamily,
          color: colors.iconColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    final iconX = position.dx - textPainter.width / 2;
    final iconY = position.dy - textPainter.height / 2;
    
    textPainter.paint(canvas, Offset(iconX, iconY));
    
    // If directional, add extra arrows for two-way
    if (_signageType == SignageType.twoWay) {
      final oppositeDirection = (_direction + 2) % 4;
      final secondArrow = _getDirectionalIcon(oppositeDirection);
      
      final secondPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(secondArrow.codePoint),
          style: TextStyle(
            fontSize: iconSize * 0.7, // Smaller for second arrow
            fontFamily: secondArrow.fontFamily,
            color: colors.iconColor.withOpacity(0.8),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      secondPainter.layout();
      
      // Position the second arrow opposite to the first
      final secondX = position.dx - secondPainter.width / 2;
      final secondY = position.dy - secondPainter.height / 2;
      final offset = rect.height * 0.25;
      
      double offsetX = 0;
      double offsetY = 0;
      
      // Adjust offset based on direction
      switch (_direction) {
        case 0: // Up
        case 2: // Down
          offsetY = oppositeDirection == 0 ? -offset : offset;
          break;
        case 1: // Right
        case 3: // Left
          offsetX = oppositeDirection == 1 ? offset : -offset;
          break;
      }
      
      secondPainter.paint(
        canvas,
        Offset(secondX + offsetX, secondY + offsetY),
      );
    }
  }
  
  /// Draw the label text
  void _drawLabel(Canvas canvas, Offset position, Rect rect, String label, Color color, double zoom) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 7 * zoom,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    textPainter.layout();
    
    // Draw text at the bottom of the signage
    canvas.drawRect(
      Rect.fromLTWH(
        rect.center.dx - textPainter.width / 2 - 2 * zoom,
        rect.bottom + 2 * zoom,
        textPainter.width + 4 * zoom,
        textPainter.height + 2 * zoom,
      ),
      Paint()..color = Colors.white.withOpacity(0.7),
    );
    
    textPainter.paint(
      canvas,
      Offset(
        rect.center.dx - textPainter.width / 2,
        rect.bottom + 3 * zoom,
      ),
    );
  }
  
  /// Get icon data for the signage type
  IconData _getIconData() {
    switch (_signageType) {
      case SignageType.info:
        return Icons.info;
      case SignageType.entrance:
        return Icons.input;
      case SignageType.exit:
        return Icons.logout;
      case SignageType.noParking:
        return Icons.local_parking;
      case SignageType.oneWay:
      case SignageType.twoWay:
        return _getDirectionalIcon(_direction);
    }
  }
  
  /// Get directional icon based on direction value
  IconData _getDirectionalIcon(int dir) {
    switch (dir) {
      case 0: // Up
        return Icons.arrow_upward;
      case 1: // Right
        return Icons.arrow_forward;
      case 2: // Down
        return Icons.arrow_downward;
      case 3: // Left
        return Icons.arrow_back;
      default:
        return Icons.arrow_forward;
    }
  }
  
  /// Get appropriate icon size for the signage type
  double _getIconSize() {
    switch (_signageType) {
      case SignageType.info:
        return 20.0;
      case SignageType.entrance:
      case SignageType.exit:
        return 22.0;
      case SignageType.noParking:
        return 18.0;
      case SignageType.oneWay:
      case SignageType.twoWay:
        return 24.0;
    }
  }
  
  /// Get colors based on signage type
  _SignageColors _getColors() {
    switch (_signageType) {
      case SignageType.info:
        return _SignageColors(
          fillColor: Colors.blue.withOpacity(0.1),
          borderColor: Colors.blue,
          iconColor: Colors.blue,
          textColor: Colors.blue,
        );
      
      case SignageType.entrance:
        return _SignageColors(
          fillColor: Colors.green.withOpacity(0.1),
          borderColor: Colors.green,
          iconColor: Colors.green,
          textColor: Colors.green,
        );
      
      case SignageType.exit:
        return _SignageColors(
          fillColor: Colors.red.withOpacity(0.1),
          borderColor: Colors.red,
          iconColor: Colors.red,
          textColor: Colors.red,
        );
      
      case SignageType.noParking:
        return _SignageColors(
          fillColor: Colors.red.withOpacity(0.1),
          borderColor: Colors.red,
          iconColor: Colors.red,
          textColor: Colors.red,
        );
      
      case SignageType.oneWay:
      case SignageType.twoWay:
        return _SignageColors(
          fillColor: Colors.blue.withOpacity(0.1),
          borderColor: Colors.blue,
          iconColor: Colors.blue,
          textColor: Colors.blue,
        );
    }
  }
  
  @override
  Component clone() {
    return SignageRenderComponent(
      signageType: _signageType,
      direction: _direction,
    );
  }
}

/// Helper class for signage colors
class _SignageColors {
  final Color fillColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  
  _SignageColors({
    required this.fillColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
  });
} 