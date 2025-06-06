import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

import '../utils/drawing_utils.dart';
import 'enums.dart';

/// Archivo unificado que contiene todas las clases base para elementos del mundo
/// Incluye: Size3D, ElementVisuals, ElementProperties, WorldElement, RenderableElement

//------------------------------------------------------------------------------
// PARTE 1: PROPIEDADES VISUALES Y DIMENSIONES
//------------------------------------------------------------------------------

/// Clase para manejar dimensiones en 3D (ancho, alto y profundidad)
class Size3D {
  double width;
  double height;
  double depth;

  Size3D({
    required this.width,
    required this.height,
    this.depth = 0.0,
  });

  // Constructor de copia
  Size3D.copy(Size3D other)
      : width = other.width,
        height = other.height,
        depth = other.depth;

  // Método para escalar las dimensiones
  Size3D scaled(double factor) {
    return Size3D(
      width: width * factor,
      height: height * factor,
      depth: depth * factor,
    );
  }

  @override
  String toString() {
    return 'Size3D(width: $width, height: $height, depth: $depth)';
  }
}

/// Clase para almacenar propiedades visuales de un elemento
class ElementVisuals {
  final Color color;
  final IconData icon;
  final String label;
  final double width;
  final double height;
  final double size;

  const ElementVisuals({
    required this.color,
    required this.icon,
    required this.label,
    this.width = 0.0,
    this.height = 0.0,
    this.size = 0.0,
  });
}

/// Propiedades visuales de los elementos
class ElementProperties {
  // Colores principales
  static const Color blue = Color(0xFF2196F3);
  static const Color green = Color(0xFF4CAF50);
  static const Color red = Color(0xFFE53935);
  static const Color orange = Color(0xFFFF9800);
  static const Color purple = Color(0xFF9C27B0);
  static const Color gold = Color(0xFFFFD700);
  static const Color gray = Color(0xFF9E9E9E);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF333333);

  // Mapeo directo entre tipos de elementos y sus propiedades visuales
  static final Map<SignageType, ElementVisuals> signageVisuals = {
    SignageType.entrance: const ElementVisuals(
      color: green,
      icon: Icons.login,
      label: 'Entrada',
      width: 60.0,
      height: 30.0,
    ),
    SignageType.exit: const ElementVisuals(
      color: red,
      icon: Icons.logout,
      label: 'Salida',
      width: 60.0,
      height: 30.0,
    ),
    SignageType.path: const ElementVisuals(
      color: blue,
      icon: Icons.trending_flat,
      label: 'Vía',
      width: 60.0,
      height: 30.0,
    ),
    SignageType.info: const ElementVisuals(
      color: blue,
      icon: Icons.info_outline,
      label: 'Info',
      width: 60.0,
      height: 30.0,
    ),
    SignageType.noParking: const ElementVisuals(
      color: red,
      icon: Icons.do_not_disturb,
      label: 'No Est',
      width: 60.0,
      height: 30.0,
    ),
    SignageType.oneWay: const ElementVisuals(
      color: blue,
      icon: Icons.trending_flat,
      label: 'Vía',
      width: 60.0,
      height: 30.0,
    ),
    SignageType.twoWay: const ElementVisuals(
      color: blue,
      icon: Icons.sync_alt,
      label: 'Doble Vía',
      width: 60.0,
      height: 30.0,
    ),
  };

  static final Map<SpotType, ElementVisuals> spotVisuals = {
    SpotType.vehicle: const ElementVisuals(
      color: blue,
      icon: Icons.directions_car,
      label: 'Vehículo',
      width: 80.0,
      height: 160.0,
    ),
    SpotType.motorcycle: const ElementVisuals(
      color: green,
      icon: Icons.motorcycle,
      label: 'Moto',
      width: 50.0,
      height: 100.0,
    ),
    SpotType.truck: const ElementVisuals(
      color: orange,
      icon: Icons.local_shipping,
      label: 'Camión',
      width: 100.0,
      height: 200.0,
    ),
  };

  static final Map<SpotCategory, ElementVisuals> spotCategoryVisuals = {
    SpotCategory.normal: const ElementVisuals(
      color: green,
      icon: Icons.check_circle_outline,
      label: 'Normal',
    ),
    SpotCategory.disabled: const ElementVisuals(
      color: purple,
      icon: Icons.accessible,
      label: 'Discapacitado',
    ),
    SpotCategory.reserved: const ElementVisuals(
      color: orange,
      icon: Icons.bookmark_border,
      label: 'Reservado',
    ),
    SpotCategory.vip: const ElementVisuals(
      color: gold,
      icon: Icons.star_border,
      label: 'VIP',
    ),
  };

  static final Map<FacilityType, ElementVisuals> facilityVisuals = {
    FacilityType.elevator: const ElementVisuals(
      color: purple,
      icon: Icons.elevator,
      label: 'Ascensor',
      width: 80.0,
      height: 80.0,
    ),
    FacilityType.stairs: const ElementVisuals(
      color: purple,
      icon: Icons.stairs,
      label: 'Escalera',
      width: 60.0,
      height: 40.0,
    ),
    FacilityType.bathroom: const ElementVisuals(
      color: blue,
      icon: Icons.wc,
      label: 'Baño',
      width: 100.0,
      height: 80.0,
    ),
    FacilityType.office: const ElementVisuals(
      color: orange,
      icon: Icons.business,
      label: 'Oficina',
      width: 100.0,
      height: 80.0,
    ),
    FacilityType.payStation: const ElementVisuals(
      color: green,
      icon: Icons.point_of_sale,
      label: 'Caja',
      width: 80.0,
      height: 80.0,
    ),
    FacilityType.securityOffice: const ElementVisuals(
      color: orange,
      icon: Icons.security,
      label: 'Seguridad',
      width: 100.0,
      height: 80.0,
    ),
  };

  // Constantes para tamaños y estilos
  static const double strokeWidthNormal = 2.0;
  static const double strokeWidthSelected = 3.0;
  static const double textSizeLabel = 10.0;
  static const double opacitySelected = 0.2;
  static const double opacityTextBackground = 0.8;
  static const double borderRadius = 8.0;
  static const Color selectedColor = Colors.blue;
  static const Color occupiedColor = red;
  static const Color textColor = darkText;
  static const Color textLightColor = white;

  // Métodos de utilidad
  static ElementVisuals getSpotVisuals(SpotType type) {
    return spotVisuals[type] ?? spotVisuals[SpotType.vehicle]!;
  }

  static ElementVisuals getSignageVisuals(SignageType type) {
    return signageVisuals[type] ?? signageVisuals[SignageType.info]!;
  }

  static ElementVisuals getFacilityVisuals(FacilityType type) {
    return facilityVisuals[type] ?? facilityVisuals[FacilityType.office]!;
  }

  static ElementVisuals getSpotCategoryVisuals(SpotCategory category) {
    return spotCategoryVisuals[category] ??
        spotCategoryVisuals[SpotCategory.normal]!;
  }

  static Color getSpotColor({
    required bool isSelected,
    required bool isOccupied,
    required SpotCategory category,
  }) {
    if (isSelected) return selectedColor;
    if (isOccupied) return occupiedColor;
    
    // Obtener el color según el tipo de spot, no la categoría
    switch (category) {
      case SpotCategory.normal:
        return blue;
      case SpotCategory.disabled:
        return purple;
      case SpotCategory.reserved:
        return orange;
      case SpotCategory.vip:
        return gold;
      default:
        return blue;
    }
  }

  // Colores para las pestañas de categorías
  static Color get spacesTabColor => blue;
  static Color get signsTabColor => red;
  static Color get facilitiesTabColor => purple;

  // Iconos para las pestañas de categorías
  static IconData get spacesTabIcon => Icons.directions_car;
  static IconData get signsTabIcon => Icons.sign_language;
  static IconData get facilitiesTabIcon => Icons.elevator;
}

//------------------------------------------------------------------------------
// PARTE 2: CLASES BASE PARA ELEMENTOS
//------------------------------------------------------------------------------

/// Clase base para todos los elementos del mundo
abstract class WorldElement {
  // Identificador único
  final String id;

  // Posición en el mundo
  final vector_math.Vector2 position;

  // Dimensiones
  Size3D size;

  // Rotación (en radianes)
  double rotation;

  // Propiedades visuales
  Color color;
  double opacity;
  bool isVisible;
  IconData? icon;
  String? label;

  // Estado de selección
  bool isSelected;

  // Capacidades
  final bool isDraggable;
  final bool isResizable;
  final bool isRotatable;

  // Constructor
  WorldElement({
    required this.id,
    required this.position,
    required this.size,
    this.rotation = 0.0,
    required this.color,
    this.opacity = 1.0,
    this.isVisible = true,
    this.icon,
    this.label,
    this.isSelected = false,
    this.isDraggable = true,
    this.isResizable = true,
    this.isRotatable = true,
  });

  /// Método para dibujar el elemento
  void render(
      Canvas canvas, Size size, double zoom, vector_math.Vector2 cameraOffset);

  /// Método para verificar si un punto está dentro del elemento
  bool containsPoint(vector_math.Vector2 point) {
    // Convertir el punto a coordenadas locales (considerando rotación)
    final dx = point.x - position.x;
    final dy = point.y - position.y;

    // Aplicar rotación inversa
    final cosR = cos(-rotation);
    final sinR = sin(-rotation);
    final localX = dx * cosR - dy * sinR;
    final localY = dx * sinR + dy * cosR;

    // Verificar si está dentro del rectángulo
    return localX >= -size.width / 2 &&
        localX <= size.width / 2 &&
        localY >= -size.height / 2 &&
        localY <= size.height / 2;
  }

  /// Método para mover el elemento
  void move(vector_math.Vector2 newPosition) {
    position.x = newPosition.x;
    position.y = newPosition.y;
  }

  /// Método para rotar el elemento
  void rotate(double angle) {
    rotation = angle;
  }

  /// Método para cambiar el tamaño del elemento
  void resize(double newWidth, double newHeight) {
    size.width = newWidth;
    size.height = newHeight;
  }

  /// Método para cambiar el color del elemento
  void setColor(Color newColor) {
    color = newColor;
  }

  /// Método para cambiar la visibilidad del elemento
  void setVisibility(bool visible) {
    isVisible = visible;
  }

  /// Convertir a JSON para guardar
  Map<String, dynamic> toJson();

  /// Cargar desde JSON
  static WorldElement? fromJson(Map<String, dynamic> json) {
    // Esta implementación debe ser proporcionada por las subclases
    return null;
  }

  /// Método para calcular la posición en pantalla
  vector_math.Vector2 getScreenPosition(
      double zoom, vector_math.Vector2 cameraOffset) {
    return DrawingUtils.worldToScreenPosition(position, zoom, cameraOffset);
  }

  /// Método para dibujar el indicador de selección
  void drawSelectionIndicator(
      Canvas canvas, Offset center, double width, double height, Color color) {
    if (isSelected) {
      DrawingUtils.drawSelectionIndicator(canvas, center, width, height, color);
    }
  }

  /// Método para dibujar una etiqueta de texto
  void drawLabel(Canvas canvas, String? text, Offset position, double zoom,
      {Color? textColor, bool withBackground = true}) {
    DrawingUtils.drawLabel(canvas, text, position, zoom,
        textColor: textColor, withBackground: withBackground);
  }

  /// Método para aplicar propiedades visuales desde ElementVisuals
  void applyVisuals(ElementVisuals visuals) {
    color = visuals.color;
    icon = visuals.icon;
    if (visuals.width > 0) size.width = visuals.width;
    if (visuals.height > 0) size.height = visuals.height;
    if (visuals.size > 0) {
      size.width = visuals.size;
      size.height = visuals.size;
    }
  }

  /// Método para obtener una copia del elemento
  WorldElement copy();
  
  /// Método para dibujar un rectángulo con líneas discontinuas
  void drawDashedRect(Canvas canvas, Rect rect, Paint paint, 
      {required double dashLength, required double dashSpace}) {
    DrawingUtils.drawDashedRect(canvas, rect, paint, 
        dashLength: dashLength, dashSpace: dashSpace);
  }
  
  /// Método para dibujar una etiqueta con alineación personalizada
  void drawLabelWithAlign(
    Canvas canvas,
    String text,
    Offset position,
    double zoom, {
    Color? textColor,
    bool withBackground = false,
    TextAlign textAlign = TextAlign.center,
  }) {
    DrawingUtils.drawLabelWithAlign(
      canvas, 
      text, 
      position, 
      zoom,
      textColor: textColor,
      withBackground: withBackground,
      textAlign: textAlign
    );
  }
  
  /// Método para dibujar un punto de color
  void drawColorDot(
    Canvas canvas,
    Offset position,
    double zoom, {
    required Color dotColor,
    double radius = 4.0,
  }) {
    DrawingUtils.drawColorDot(
      canvas, 
      position, 
      zoom,
      dotColor: dotColor,
      radius: radius
    );
  }
  
  /// Método para preparar el renderizado (configuración común)
  void prepareRender(Canvas canvas, Offset center) {
    // Guardar el estado actual del canvas
    canvas.save();
    
    // Aplicar rotación si es necesario
    if (rotation != 0) {
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation);
      canvas.translate(-center.dx, -center.dy);
    }
  }
  
  /// Método para finalizar el renderizado
  void finishRender(Canvas canvas) {
    // Restaurar el estado del canvas
    canvas.restore();
  }
  
  /// Método para dibujar un icono
  void drawIcon(
    Canvas canvas, 
    Offset center, 
    double zoom, {
    Color? iconColor,
    double scaleFactor = 0.4
  }) {
    if (icon == null) return;
    
    final effectiveColor = iconColor ?? color;
    final iconSize = min(size.width, size.height) * scaleFactor * zoom;
    
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon!.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          color: effectiveColor.withOpacity(0.9),
          fontFamily: icon!.fontFamily,
          package: icon!.fontPackage,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        center.dx - iconPainter.width / 2,
        center.dy - iconPainter.height / 2,
      ),
    );
  }
}

/// Extensión para alinear a una cuadrícula
extension Vector2Extensions on vector_math.Vector2 {
  vector_math.Vector2 snapToGrid(double gridSize) {
    return vector_math.Vector2(
      (x / gridSize).round() * gridSize,
      (y / gridSize).round() * gridSize,
    );
  }
}

/// Clase intermedia que implementa la lógica común de renderizado para todos los elementos
abstract class RenderableElement extends WorldElement {
  RenderableElement({
    required super.id,
    required super.position,
    required super.size,
    super.rotation = 0.0,
    required super.color,
    super.opacity = 1.0,
    super.isVisible = true,
    super.icon,
    super.label,
    super.isSelected = false,
    super.isDraggable = true,
    super.isResizable = true,
    super.isRotatable = true,
  });

  /// Método base para renderizar un elemento rectangular
  @override
  void render(
      Canvas canvas, Size canvasSize, double zoom, vector_math.Vector2 cameraOffset) {
    if (!isVisible) return;

    // Calcular posición en pantalla
    final screenPos = getScreenPosition(zoom, cameraOffset);
    final center = Offset(screenPos.x, screenPos.y);

    // Preparar renderizado (guardar estado y aplicar rotación)
    prepareRender(canvas, center);

    // Dibujar el contenido específico del elemento
    renderContent(canvas, center, zoom);

    // Dibujar indicador de selección si está seleccionado
    if (isSelected) {
      renderSelectionIndicator(canvas, center, zoom);
    }

    // Dibujar etiqueta si existe
    if (label != null && label!.isNotEmpty) {
      renderLabel(canvas, center, zoom);
    }

    // Finalizar renderizado (restaurar estado del canvas)
    finishRender(canvas);
  }
  
  /// Método para renderizar el contenido específico del elemento
  /// Este método debe ser implementado por las subclases
  void renderContent(Canvas canvas, Offset center, double zoom);
  
  /// Método para renderizar el indicador de selección
  void renderSelectionIndicator(Canvas canvas, Offset center, double zoom) {
    final selectionPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 * zoom
      ..color = ElementProperties.selectedColor.withOpacity(0.8);
    
    // Crear un rectángulo ligeramente más grande
    final selectionRect = Rect.fromCenter(
      center: center,
      width: size.width * zoom + 4 * zoom,
      height: size.height * zoom + 4 * zoom,
    );
    
    // Dibujar línea discontinua
    drawDashedRect(canvas, selectionRect, selectionPaint, 
        dashLength: 3 * zoom, dashSpace: 2 * zoom);
  }
  
  /// Método para renderizar la etiqueta
  void renderLabel(Canvas canvas, Offset center, double zoom) {
    drawLabelWithAlign(
      canvas, 
      label!,
      Offset(center.dx, center.dy + size.height * zoom / 4), 
      zoom,
      textAlign: TextAlign.center,
      withBackground: true
    );
  }
} 