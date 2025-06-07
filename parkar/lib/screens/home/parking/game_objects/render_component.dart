import 'dart:ui';
import 'package:flutter/material.dart';
import 'game_object.dart';
import 'collider_component.dart';

/// Base class for renderable components
abstract class RenderComponent extends Component {
  bool _isDirty = true;
  bool _isVisible = true;
  int _renderOrder = 0;
  
  // Getters and setters
  bool get isDirty => _isDirty;
  bool get isVisible => _isVisible;
  int get renderOrder => _renderOrder;
  
  set isVisible(bool value) {
    if (_isVisible != value) {
      _isVisible = value;
      markDirty();
    }
  }
  
  set renderOrder(int value) {
    if (_renderOrder != value) {
      _renderOrder = value;
      markDirty();
    }
  }
  
  // Constructor
  RenderComponent({
    bool isVisible = true,
    int renderOrder = 0,
  }) : _isVisible = isVisible,
       _renderOrder = renderOrder;
  
  @override
  void onRender(Canvas canvas, Offset position, double zoom) {
    if (!_isVisible) return;
    
    // Get size from collider if available, or use default size
    Size size = Size(50.0, 50.0);
    final gameObj = gameObject;
    
    if (gameObj != null) {
      final worldScale = gameObj.transform.worldScale;
      size = Size(50.0 * worldScale.x, 50.0 * worldScale.y);
      
      // Try to get size from collider
      final collider = gameObj.getComponent<ColliderComponent>();
      if (collider != null) {
        size = Size(collider.width, collider.height);
      }
      
      // Get rotation
      final rotation = gameObj.transform.worldRotation;
      
      // Call the render method
      render(canvas, position, size, rotation, zoom);
      
      // Reset dirty flag
      _isDirty = false;
    }
  }
  
  /// Mark the component as dirty (needs redraw)
  void markDirty() {
    _isDirty = true;
  }
  
  /// Main render method to implement by subclasses
  void render(Canvas canvas, Offset position, Size size, double rotation, double zoom);
}

/// Basic shape renderer
class ShapeRenderer extends RenderComponent {
  Color _color;
  PaintingStyle _style;
  double _strokeWidth;
  ShapeType _shapeType;
  double _cornerRadius;
  
  // Getters and setters
  Color get color => _color;
  set color(Color value) {
    if (_color != value) {
      _color = value;
      markDirty();
    }
  }
  
  PaintingStyle get style => _style;
  set style(PaintingStyle value) {
    if (_style != value) {
      _style = value;
      markDirty();
    }
  }
  
  double get strokeWidth => _strokeWidth;
  set strokeWidth(double value) {
    if (_strokeWidth != value) {
      _strokeWidth = value;
      markDirty();
    }
  }
  
  ShapeType get shapeType => _shapeType;
  set shapeType(ShapeType value) {
    if (_shapeType != value) {
      _shapeType = value;
      markDirty();
    }
  }
  
  double get cornerRadius => _cornerRadius;
  set cornerRadius(double value) {
    if (_cornerRadius != value) {
      _cornerRadius = value;
      markDirty();
    }
  }
  
  // Constructor
  ShapeRenderer({
    Color color = Colors.blue,
    PaintingStyle style = PaintingStyle.stroke,
    double strokeWidth = 2.0,
    ShapeType shapeType = ShapeType.rectangle,
    double cornerRadius = 0.0,
    bool isVisible = true,
    int renderOrder = 0,
  }) : _color = color,
       _style = style,
       _strokeWidth = strokeWidth,
       _shapeType = shapeType,
       _cornerRadius = cornerRadius,
       super(
         isVisible: isVisible,
         renderOrder: renderOrder,
       );
  
  @override
  void render(Canvas canvas, Offset position, Size size, double rotation, double zoom) {
    final paint = Paint()
      ..color = _color
      ..style = _style
      ..strokeWidth = _strokeWidth * zoom;
    
    final rect = Rect.fromCenter(
      center: position,
      width: size.width * zoom,
      height: size.height * zoom,
    );
    
    switch (_shapeType) {
      case ShapeType.rectangle:
        canvas.drawRect(rect, paint);
        break;
      case ShapeType.roundedRectangle:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            rect,
            Radius.circular(_cornerRadius * zoom),
          ),
          paint,
        );
        break;
      case ShapeType.circle:
        final radius = (size.width < size.height ? size.width : size.height) / 2 * zoom;
        canvas.drawCircle(position, radius, paint);
        break;
      case ShapeType.oval:
        canvas.drawOval(rect, paint);
        break;
    }
  }
  
  @override
  Component clone() {
    return ShapeRenderer(
      color: _color,
      style: _style,
      strokeWidth: _strokeWidth,
      shapeType: _shapeType,
      cornerRadius: _cornerRadius,
      isVisible: isVisible,
      renderOrder: renderOrder,
    );
  }
}

/// Text renderer component
class TextRenderer extends RenderComponent {
  String _text;
  TextStyle _textStyle;
  TextAlign _textAlign;
  bool _withBackground;
  Color _backgroundColor;
  double _backgroundOpacity;
  double _paddingX;
  double _paddingY;
  
  // Getters and setters
  String get text => _text;
  set text(String value) {
    if (_text != value) {
      _text = value;
      markDirty();
    }
  }
  
  TextStyle get textStyle => _textStyle;
  set textStyle(TextStyle value) {
    _textStyle = value;
    markDirty();
  }
  
  TextAlign get textAlign => _textAlign;
  set textAlign(TextAlign value) {
    if (_textAlign != value) {
      _textAlign = value;
      markDirty();
    }
  }
  
  bool get withBackground => _withBackground;
  set withBackground(bool value) {
    if (_withBackground != value) {
      _withBackground = value;
      markDirty();
    }
  }
  
  // Constructor
  TextRenderer({
    required String text,
    TextStyle? textStyle,
    TextAlign textAlign = TextAlign.center,
    bool withBackground = false,
    Color backgroundColor = Colors.white,
    double backgroundOpacity = 0.7,
    double paddingX = 4.0,
    double paddingY = 2.0,
    bool isVisible = true,
    int renderOrder = 0,
  }) : _text = text,
       _textStyle = textStyle ?? TextStyle(fontSize: 12.0, color: Colors.black),
       _textAlign = textAlign,
       _withBackground = withBackground,
       _backgroundColor = backgroundColor,
       _backgroundOpacity = backgroundOpacity,
       _paddingX = paddingX,
       _paddingY = paddingY,
       super(
         isVisible: isVisible,
         renderOrder: renderOrder,
       );
  
  @override
  void render(Canvas canvas, Offset position, Size size, double rotation, double zoom) {
    if (_text.isEmpty) return;
    
    // Scale the text style
    final scaledTextStyle = _textStyle.copyWith(
      fontSize: (_textStyle.fontSize ?? 12) * zoom,
    );
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: _text,
        style: scaledTextStyle,
      ),
      textDirection: TextDirection.ltr,
      textAlign: _textAlign,
    );
    
    textPainter.layout();
    
    // Calculate text position
    final textX = position.dx - textPainter.width / 2;
    final textY = position.dy - textPainter.height / 2;
    final textOffset = Offset(textX, textY);
    
    // Draw background if enabled
    if (_withBackground) {
      final bgPaint = Paint()
        ..color = _backgroundColor.withOpacity(_backgroundOpacity);
        
      canvas.drawRect(
        Rect.fromLTWH(
          textX - _paddingX * zoom,
          textY - _paddingY * zoom,
          textPainter.width + _paddingX * 2 * zoom,
          textPainter.height + _paddingY * 2 * zoom,
        ),
        bgPaint,
      );
    }
    
    // Draw text
    textPainter.paint(canvas, textOffset);
  }
  
  @override
  Component clone() {
    return TextRenderer(
      text: _text,
      textStyle: _textStyle,
      textAlign: _textAlign,
      withBackground: _withBackground,
      backgroundColor: _backgroundColor,
      backgroundOpacity: _backgroundOpacity,
      paddingX: _paddingX,
      paddingY: _paddingY,
      isVisible: isVisible,
      renderOrder: renderOrder,
    );
  }
}

/// Icon renderer component
class IconRenderer extends RenderComponent {
  IconData _icon;
  Color _color;
  double _size;
  
  // Getters and setters
  IconData get icon => _icon;
  set icon(IconData value) {
    if (_icon != value) {
      _icon = value;
      markDirty();
    }
  }
  
  Color get color => _color;
  set color(Color value) {
    if (_color != value) {
      _color = value;
      markDirty();
    }
  }
  
  double get size => _size;
  set size(double value) {
    if (_size != value) {
      _size = value;
      markDirty();
    }
  }
  
  // Constructor
  IconRenderer({
    required IconData icon,
    Color color = Colors.black,
    double size = 24.0,
    bool isVisible = true,
    int renderOrder = 0,
  }) : _icon = icon,
       _color = color,
       _size = size,
       super(
         isVisible: isVisible,
         renderOrder: renderOrder,
       );
  
  @override
  void render(Canvas canvas, Offset position, Size size, double rotation, double zoom) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(_icon.codePoint),
        style: TextStyle(
          fontSize: _size * zoom,
          fontFamily: _icon.fontFamily,
          color: _color,
          package: _icon.fontPackage,
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
  
  @override
  Component clone() {
    return IconRenderer(
      icon: _icon,
      color: _color,
      size: _size,
      isVisible: isVisible,
      renderOrder: renderOrder,
    );
  }
}

/// Shape types for the shape renderer
enum ShapeType {
  rectangle,
  roundedRectangle,
  circle,
  oval,
} 