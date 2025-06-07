import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/vector2.dart';
import 'game_object.dart';
import 'collider_component.dart';
import 'render_component.dart';

/// Enumeration for the types of parking spots
enum SpotType {
  vehicle,   // Regular car spot
  motorcycle, // Motorcycle spot
  truck       // Large truck or bus spot
}

/// Enumeration for the categories of parking spots
enum SpotCategory {
  normal,    // Regular spot
  disabled,  // Accessibility spot
  reserved,  // Reserved for specific people
  vip        // VIP parking
}

/// Represents a parking spot in the scene
class ParkingSpot extends GameObject {
  // Spot properties
  SpotType _spotType;
  SpotCategory _category;
  bool _isOccupied;
  String? _vehiclePlate;
  
  // Components
  late RenderComponent _renderer;
  late ColliderComponent _collider;
  
  // Getters
  SpotType get spotType => _spotType;
  SpotCategory get category => _category;
  bool get isOccupied => _isOccupied;
  String? get vehiclePlate => _vehiclePlate;
  
  // Constructor
  ParkingSpot({
    required String id,
    required String label,
    required Vector2 position,
    double rotation = 0.0,
    SpotType spotType = SpotType.vehicle,
    SpotCategory category = SpotCategory.normal,
    bool isOccupied = false,
    String? vehiclePlate,
    Vector2? size,
  }) : _spotType = spotType,
       _category = category,
       _isOccupied = isOccupied,
       _vehiclePlate = vehiclePlate,
       super(
         id: id,
         name: label,
         tag: 'ParkingSpot',
         position: position,
         rotation: rotation,
       ) {
    
    // Get default size based on spot type
    final defaultSize = _getDefaultSize(spotType);
    final spotSize = size ?? defaultSize;
    
    // Set up the transform with the right scale
    transform.scale = Vector2(spotSize.x / defaultSize.x, spotSize.y / defaultSize.y);
    
    // Add renderer component
    _renderer = addComponent(SpotRenderComponent(
      spotType: spotType,
      category: category,
      isOccupied: isOccupied,
    ));
    
    // Add collider component for interaction
    _collider = addComponent(ColliderComponent.box(
      width: spotSize.x,
      height: spotSize.y,
      isTrigger: true,
    ));
  }
  
  /// Get default size for the spot type
  Vector2 _getDefaultSize(SpotType type) {
    switch (type) {
      case SpotType.vehicle:
        return Vector2(80.0, 160.0);
      case SpotType.motorcycle:
        return Vector2(50.0, 100.0);
      case SpotType.truck:
        return Vector2(100.0, 220.0);
    }
  }
  
  /// Change the type of the parking spot
  void setType(SpotType newType) {
    if (_spotType != newType) {
      _spotType = newType;
      
      // Update the renderer
      if (_renderer is SpotRenderComponent) {
        (_renderer as SpotRenderComponent).spotType = newType;
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
  
  /// Change the category of the parking spot
  void setCategory(SpotCategory newCategory) {
    if (_category != newCategory) {
      _category = newCategory;
      
      // Update the renderer
      if (_renderer is SpotRenderComponent) {
        (_renderer as SpotRenderComponent).category = newCategory;
      }
    }
  }
  
  /// Set the occupied state and optionally the vehicle plate
  void setOccupied(bool occupied, {String? plate}) {
    _isOccupied = occupied;
    _vehiclePlate = occupied ? (plate ?? _vehiclePlate) : null;
    
    // Update the renderer
    if (_renderer is SpotRenderComponent) {
      (_renderer as SpotRenderComponent).isOccupied = occupied;
    }
  }
  
  @override
  GameObject clone() {
    return ParkingSpot(
      id: '${id}_clone',
      label: name,
      position: transform.position,
      rotation: transform.rotation,
      spotType: _spotType,
      category: _category,
      isOccupied: _isOccupied,
      vehiclePlate: _vehiclePlate,
      size: Vector2(
        _collider.width,
        _collider.height,
      ),
    );
  }
}

/// Render component for parking spots
class SpotRenderComponent extends RenderComponent {
  // Properties
  SpotType _spotType;
  SpotCategory _category;
  bool _isOccupied;
  
  // Getters and setters
  SpotType get spotType => _spotType;
  set spotType(SpotType value) {
    if (_spotType != value) {
      _spotType = value;
      markDirty();
    }
  }
  
  SpotCategory get category => _category;
  set category(SpotCategory value) {
    if (_category != value) {
      _category = value;
      markDirty();
    }
  }
  
  bool get isOccupied => _isOccupied;
  set isOccupied(bool value) {
    if (_isOccupied != value) {
      _isOccupied = value;
      markDirty();
    }
  }
  
  // Constructor
  SpotRenderComponent({
    required SpotType spotType,
    required SpotCategory category,
    bool isOccupied = false,
  }) : _spotType = spotType,
       _category = category,
       _isOccupied = isOccupied;
  
  @override
  void render(Canvas canvas, Offset position, Size size, double rotation, double zoom) {
    // Save canvas state
    canvas.save();
    
    // Apply rotation from the GameObject
    canvas.translate(position.dx, position.dy);
    canvas.rotate(rotation);
    canvas.translate(-position.dx, -position.dy);
    
    // Get colors based on state
    final colors = _getColors();
    
    // Draw the parking spot
    final rect = Rect.fromCenter(
      center: position,
      width: size.width * zoom,
      height: size.height * zoom,
    );

    // Draw background with minimal opacity
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = colors.fillColor;
    canvas.drawRect(rect, fillPaint);
    
    // Draw border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 * zoom
      ..color = colors.borderColor;
    canvas.drawRect(rect, borderPaint);
    
    // Draw spot type icon
    _drawIcon(canvas, position, colors.iconColor, zoom);
    
    // Draw category indicator
    _drawCategoryIndicator(canvas, rect, zoom);
    
    // Draw occupied indicator if needed
    if (_isOccupied) {
      _drawOccupiedIndicator(canvas, rect, zoom);
    }
    
    // Draw label
    final label = gameObject?.name ?? '';
    if (label.isNotEmpty) {
      _drawLabel(canvas, position, rect, label, colors.textColor, zoom);
    }
    
    // Restore canvas state
    canvas.restore();
  }
  
  /// Draw the spot type icon
  void _drawIcon(Canvas canvas, Offset position, Color color, double zoom) {
    // Icon to use based on spot type
    IconData icon;
    double iconSize;
    
    switch (_spotType) {
      case SpotType.vehicle:
        icon = Icons.directions_car;
        iconSize = 14.0 * zoom;
        break;
      case SpotType.motorcycle:
        icon = Icons.motorcycle;
        iconSize = 12.0 * zoom;
        break;
      case SpotType.truck:
        icon = Icons.local_shipping;
        iconSize = 16.0 * zoom;
        break;
    }
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          color: color,
          fontFamily: icon.fontFamily,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    final offsetY = _isOccupied ? -textPainter.height : 0.0;
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2 + offsetY,
      ),
    );
  }
  
  /// Draw category indicator
  void _drawCategoryIndicator(Canvas canvas, Rect rect, double zoom) {
    final dotColor = _getCategoryColor();
    final dotRadius = 3.0 * zoom;
    
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = dotColor;
    
    // Draw the dot in the corner
    canvas.drawCircle(
      Offset(rect.left + dotRadius + 2 * zoom, rect.top + dotRadius + 2 * zoom),
      dotRadius,
      dotPaint,
    );
  }
  
  /// Draw occupied indicator
  void _drawOccupiedIndicator(Canvas canvas, Rect rect, double zoom) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 * zoom
      ..color = Colors.red.withOpacity(0.8);
    
    // Draw an X
    final margin = 0.2 * rect.width;
    
    canvas.drawLine(
      Offset(rect.left + margin, rect.top + margin),
      Offset(rect.right - margin, rect.bottom - margin),
      paint,
    );
    
    canvas.drawLine(
      Offset(rect.right - margin, rect.top + margin),
      Offset(rect.left + margin, rect.bottom - margin),
      paint,
    );
  }
  
  /// Draw the label text
  void _drawLabel(Canvas canvas, Offset position, Rect rect, String label, Color color, double zoom) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 8 * zoom,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    textPainter.layout();
    
    // Draw text at the bottom of the spot
    final textY = rect.bottom - textPainter.height - 5 * zoom;
    
    // Draw background
    final bgPaint = Paint()..color = Colors.white.withOpacity(0.7);
    canvas.drawRect(
      Rect.fromLTWH(
        position.dx - textPainter.width / 2 - 2 * zoom,
        textY - 1 * zoom,
        textPainter.width + 4 * zoom,
        textPainter.height + 2 * zoom,
      ),
      bgPaint,
    );
    
    // Draw text
    textPainter.paint(
      canvas,
      Offset(position.dx - textPainter.width / 2, textY),
    );
  }
  
  /// Get category color
  Color _getCategoryColor() {
    switch (_category) {
      case SpotCategory.normal:
        return Colors.green;
      case SpotCategory.disabled:
        return Colors.blue;
      case SpotCategory.reserved:
        return Colors.orange;
      case SpotCategory.vip:
        return Colors.purple;
    }
  }
  
  /// Get colors based on the current state
  _SpotColors _getColors() {
    Color fillColor, borderColor, iconColor, textColor;
    
    // Base colors on state
    if (_isOccupied) {
      fillColor = Colors.red.withOpacity(0.05);
      borderColor = Colors.red.withOpacity(0.8);
      iconColor = Colors.red;
      textColor = Colors.red;
    } else {
      final baseColor = _getBaseColor();
      fillColor = baseColor.withOpacity(0.05);
      borderColor = baseColor.withOpacity(0.6);
      iconColor = baseColor;
      textColor = baseColor;
    }
    
    return _SpotColors(
      fillColor: fillColor,
      borderColor: borderColor,
      iconColor: iconColor,
      textColor: textColor,
    );
  }
  
  /// Get base color for the spot type
  Color _getBaseColor() {
    switch (_spotType) {
      case SpotType.vehicle:
        return Colors.blue;
      case SpotType.motorcycle:
        return Colors.green;
      case SpotType.truck:
        return Colors.orange;
    }
  }
  
  @override
  Component clone() {
    return SpotRenderComponent(
      spotType: _spotType,
      category: _category,
      isOccupied: _isOccupied,
    );
  }
}

/// Helper class for spot colors
class _SpotColors {
  final Color fillColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  
  _SpotColors({
    required this.fillColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
  });
} 