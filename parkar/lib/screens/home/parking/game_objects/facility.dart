import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/vector2.dart';
import 'game_object.dart';
import 'collider_component.dart';
import 'render_component.dart';

/// Enumeration for the types of facilities
enum FacilityType {
  elevator,       // Building elevator
  bathroom,       // Restroom facility
  payStation,     // Payment kiosk
  securityOffice, // Security office
  staircase,      // Staircase
  handicapAccess  // Handicap accessibility
}

/// Represents a facility in the parking scene
class Facility extends GameObject {
  // Facility properties
  FacilityType _facilityType;
  bool _isAvailable;
  String? _details;
  
  // Components
  late RenderComponent _renderer;
  late ColliderComponent _collider;
  
  // Getters
  FacilityType get facilityType => _facilityType;
  bool get isAvailable => _isAvailable;
  String? get details => _details;
  
  // Constructor
  Facility({
    required String id,
    required String label,
    required Vector2 position,
    double rotation = 0.0,
    FacilityType facilityType = FacilityType.elevator,
    bool isAvailable = true,
    String? details,
    Vector2? size,
  }) : _facilityType = facilityType,
       _isAvailable = isAvailable,
       _details = details,
       super(
         id: id,
         name: label,
         tag: 'Facility',
         position: position,
         rotation: rotation,
       ) {
    
    // Get default size based on facility type
    final defaultSize = _getDefaultSize(facilityType);
    final facilitySize = size ?? defaultSize;
    
    // Set up the transform with the right scale
    transform.scale = Vector2(
      facilitySize.x / defaultSize.x,
      facilitySize.y / defaultSize.y,
    );
    
    // Add renderer component
    _renderer = addComponent(FacilityRenderComponent(
      facilityType: facilityType,
      isAvailable: isAvailable,
    ));
    
    // Add collider component for interaction
    _collider = addComponent(ColliderComponent.box(
      width: facilitySize.x,
      height: facilitySize.y,
      isTrigger: true,
    ));
  }
  
  /// Get default size for the facility type
  Vector2 _getDefaultSize(FacilityType type) {
    switch (type) {
      case FacilityType.elevator:
        return Vector2(45.0, 45.0);
      case FacilityType.bathroom:
        return Vector2(40.0, 40.0);
      case FacilityType.payStation:
        return Vector2(35.0, 35.0);
      case FacilityType.securityOffice:
        return Vector2(50.0, 50.0);
      case FacilityType.staircase:
        return Vector2(45.0, 45.0);
      case FacilityType.handicapAccess:
        return Vector2(40.0, 40.0);
    }
  }
  
  /// Change the type of the facility
  void setType(FacilityType newType) {
    if (_facilityType != newType) {
      _facilityType = newType;
      
      // Update the renderer
      if (_renderer is FacilityRenderComponent) {
        (_renderer as FacilityRenderComponent).facilityType = newType;
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
  
  /// Set the availability status
  void setAvailability(bool available) {
    if (_isAvailable != available) {
      _isAvailable = available;
      
      // Update the renderer
      if (_renderer is FacilityRenderComponent) {
        (_renderer as FacilityRenderComponent).isAvailable = available;
      }
    }
  }
  
  /// Update facility details
  void setDetails(String? details) {
    _details = details;
  }
  
  @override
  GameObject clone() {
    return Facility(
      id: '${id}_clone',
      label: name,
      position: transform.position,
      rotation: transform.rotation,
      facilityType: _facilityType,
      isAvailable: _isAvailable,
      details: _details,
      size: Vector2(
        _collider.width,
        _collider.height,
      ),
    );
  }
}

/// Render component for facilities
class FacilityRenderComponent extends RenderComponent {
  // Properties
  FacilityType _facilityType;
  bool _isAvailable;
  
  // Getters and setters
  FacilityType get facilityType => _facilityType;
  set facilityType(FacilityType value) {
    if (_facilityType != value) {
      _facilityType = value;
      markDirty();
    }
  }
  
  bool get isAvailable => _isAvailable;
  set isAvailable(bool value) {
    if (_isAvailable != value) {
      _isAvailable = value;
      markDirty();
    }
  }
  
  // Constructor
  FacilityRenderComponent({
    required FacilityType facilityType,
    bool isAvailable = true,
  }) : _facilityType = facilityType,
       _isAvailable = isAvailable;
  
  @override
  void render(Canvas canvas, Offset position, Size size, double rotation, double zoom) {
    // Save canvas state
    canvas.save();
    
    // Apply rotation from the GameObject
    canvas.translate(position.dx, position.dy);
    canvas.rotate(rotation);
    canvas.translate(-position.dx, -position.dy);
    
    // Get colors and icon data
    final colors = _getColors();
    
    // Draw the facility icon
    final rect = Rect.fromCenter(
      center: position,
      width: size.width * zoom,
      height: size.height * zoom,
    );
    
    // Draw background
    _drawBackground(canvas, rect, colors, zoom);
    
    // Draw facility icon
    _drawIcon(canvas, position, colors.iconColor, zoom);
    
    // Draw label if needed
    final label = gameObject?.name ?? '';
    if (label.isNotEmpty) {
      _drawLabel(canvas, position, rect, label, colors.textColor, zoom);
    }
    
    // Draw availability indicator if not available
    if (!_isAvailable) {
      _drawNotAvailableIndicator(canvas, rect, colors, zoom);
    }
    
    // Restore canvas state
    canvas.restore();
  }
  
  /// Draw the background shape
  void _drawBackground(Canvas canvas, Rect rect, _FacilityColors colors, double zoom) {
    // Draw background shape based on facility type (all are rounded rectangles with different corner radii)
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = colors.fillColor;
    
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * zoom
      ..color = colors.borderColor;
    
    // Get corner radius based on type
    double cornerRadius = 4.0;
    switch (_facilityType) {
      case FacilityType.elevator:
      case FacilityType.staircase:
        cornerRadius = 2.0;
        break;
      case FacilityType.bathroom:
      case FacilityType.payStation:
        cornerRadius = 4.0;
        break;
      case FacilityType.securityOffice:
      case FacilityType.handicapAccess:
        cornerRadius = 6.0;
        break;
    }
    
    // Draw rounded rectangle
    final rRect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(cornerRadius * zoom),
    );
    
    canvas.drawRRect(rRect, fillPaint);
    canvas.drawRRect(rRect, strokePaint);
  }
  
  /// Draw the icon for the facility type
  void _drawIcon(Canvas canvas, Offset position, Color color, double zoom) {
    final iconData = _getIconData();
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontSize: 24.0 * zoom,
          fontFamily: iconData.fontFamily,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    final iconX = position.dx - textPainter.width / 2;
    final iconY = position.dy - textPainter.height / 2;
    
    textPainter.paint(
      canvas,
      Offset(iconX, iconY),
    );
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
    
    // Draw text at the bottom of the facility
    final textY = rect.bottom + 4 * zoom;
    
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
  
  /// Draw not available indicator
  void _drawNotAvailableIndicator(Canvas canvas, Rect rect, _FacilityColors colors, double zoom) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * zoom
      ..color = Colors.red.withOpacity(0.7);
    
    // Draw an X across the facility
    canvas.drawLine(
      Offset(rect.left + 5 * zoom, rect.top + 5 * zoom),
      Offset(rect.right - 5 * zoom, rect.bottom - 5 * zoom),
      paint,
    );
    
    canvas.drawLine(
      Offset(rect.right - 5 * zoom, rect.top + 5 * zoom),
      Offset(rect.left + 5 * zoom, rect.bottom - 5 * zoom),
      paint,
    );
  }
  
  /// Get icon data for the facility type
  IconData _getIconData() {
    switch (_facilityType) {
      case FacilityType.elevator:
        return Icons.elevator;
      case FacilityType.bathroom:
        return Icons.wc;
      case FacilityType.payStation:
        return Icons.payment;
      case FacilityType.securityOffice:
        return Icons.security;
      case FacilityType.staircase:
        return Icons.stairs;
      case FacilityType.handicapAccess:
        return Icons.accessible;
    }
  }
  
  /// Get colors based on facility type and availability
  _FacilityColors _getColors() {
    // Base colors for different facility types
    Color mainColor;
    double opacity = _isAvailable ? 1.0 : 0.5;
    
    switch (_facilityType) {
      case FacilityType.elevator:
        mainColor = Colors.blue;
        break;
      case FacilityType.bathroom:
        mainColor = Colors.teal;
        break;
      case FacilityType.payStation:
        mainColor = Colors.green;
        break;
      case FacilityType.securityOffice:
        mainColor = Colors.purple;
        break;
      case FacilityType.staircase:
        mainColor = Colors.orange;
        break;
      case FacilityType.handicapAccess:
        mainColor = Colors.blue;
        break;
    }
    
    return _FacilityColors(
      fillColor: mainColor.withOpacity(0.1 * opacity),
      borderColor: mainColor.withOpacity(0.6 * opacity),
      iconColor: mainColor.withOpacity(opacity),
      textColor: mainColor.withOpacity(opacity),
    );
  }
  
  @override
  Component clone() {
    return FacilityRenderComponent(
      facilityType: _facilityType,
      isAvailable: _isAvailable,
    );
  }
}

/// Helper class for facility colors
class _FacilityColors {
  final Color fillColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  
  _FacilityColors({
    required this.fillColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
  });
} 