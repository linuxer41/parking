import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

import '../utils/drawing_utils.dart';
import 'enums.dart';

/// Archivo unificado que contiene todas las clases base para elementos del sistema de parkeo
/// Incluye: Size3D, ElementVisuals, ElementProperties, ParkingElement

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

  // Colores para los tabs de categorías
  static const Color spacesTabColor = blue;
  static const Color signsTabColor = orange;
  static const Color facilitiesTabColor = purple;

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
      width: 70.0,
      height: 70.0,
    ),
    FacilityType.paymentStation: const ElementVisuals(
      color: green,
      icon: Icons.payments_outlined,
      label: 'Pago',
      width: 60.0,
      height: 60.0,
    ),
    FacilityType.chargingStation: const ElementVisuals(
      color: green,
      icon: Icons.electric_car,
      label: 'Carga',
      width: 70.0,
      height: 70.0,
    ),
    FacilityType.securityPost: const ElementVisuals(
      color: red,
      icon: Icons.security,
      label: 'Seguridad',
      width: 70.0,
      height: 70.0,
    ),
  };
}

//------------------------------------------------------------------------------
// PARTE 2: ELEMENTOS BASE DEL SISTEMA DE PARKEO
//------------------------------------------------------------------------------

/// Clase auxiliar para representar la proyección de un polígono sobre un eje
class _Projection {
  final double min;
  final double max;

  _Projection(this.min, this.max);
}

/// Clase para almacenar opacidades de elementos (para animaciones)
class ElementOpacityHelper {
  static final Map<String, double> _opacities = {};

  static double getOpacity(String elementId) {
    return _opacities[elementId] ?? 1.0;
  }

  static void setOpacity(String elementId, double opacity) {
    _opacities[elementId] = opacity;
  }
}

/// Clase para gestionar las animaciones de selección
class ElementAnimation {
  static final Map<String, double> _selectionAnimations = {};

  static double getSelectionScale(String elementId) {
    return _selectionAnimations[elementId] ?? 1.0;
  }

  static void setSelectionScale(String elementId, double scale) {
    _selectionAnimations[elementId] = scale;
  }
}

/// Base para todos los elementos del sistema de parkeo
abstract class ParkingElement with ChangeNotifier {
  // Identificador único
  final String id;

  // Posición en el mundo
  vector_math.Vector2 _position;

  // Rotación en grados
  double _rotation;

  // Escala
  double _scale;

  // Visibilidad
  bool isVisible;

  // Bloqueo para edición
  bool isLocked;

  // Estado de selección
  bool _isSelected;

  // Valores de animación
  double _selectionAnimationValue = 0.0;
  double _hoverAnimationValue = 0.0;

  // Constructor
  ParkingElement({
    required this.id,
    required vector_math.Vector2 position,
    double rotation = 0.0,
    double scale = 1.0,
    this.isVisible = true,
    this.isLocked = false,
    bool isSelected = false,
  })  : _position = position,
        _rotation = rotation,
        _scale = scale,
        _isSelected = isSelected;

  // Getters y setters
  vector_math.Vector2 get position => _position;
  set position(vector_math.Vector2 value) {
    if (_position != value) {
      _position = value;
      notifyListeners();
    }
  }

  double get rotation => _rotation;
  set rotation(double value) {
    if (_rotation != value) {
      _rotation = value;
      notifyListeners();
    }
  }

  double get scale => _scale;
  set scale(double value) {
    if (_scale != value) {
      _scale = value;
      notifyListeners();
    }
  }

  bool get isSelected => _isSelected;
  set isSelected(bool value) {
    if (_isSelected != value) {
      _isSelected = value;

      // Animar la selección/deselección
      if (_isSelected) {
        _animateSelection(1.0);
      } else {
        _animateSelection(0.0);
      }

      notifyListeners();
    }
  }

  // Valores de animación
  double get selectionAnimationValue => _selectionAnimationValue;
  set selectionAnimationValue(double value) {
    if (_selectionAnimationValue != value) {
      _selectionAnimationValue = value;

      // Almacenar el valor de escala para la animación
      ElementAnimation.setSelectionScale(
          id, 1.0 + (_selectionAnimationValue * 0.05));

      notifyListeners();
    }
  }

  double get hoverAnimationValue => _hoverAnimationValue;
  set hoverAnimationValue(double value) {
    if (_hoverAnimationValue != value) {
      _hoverAnimationValue = value;
      notifyListeners();
    }
  }

  // Animación de selección
  void _animateSelection(double targetValue) {
    // Esta función es llamada por los gestores de animación externos
    // que interactúan con selectionAnimationValue
  }

  // Método para animar la opacidad del elemento
  void fadeIn(Duration duration) {
    // Implementado por el AnimationManager
  }

  void fadeOut(Duration duration) {
    // Implementado por el AnimationManager
  }

  // Método para obtener la escala actual con animaciones
  double getAnimatedScale() {
    final selectionScale = ElementAnimation.getSelectionScale(id);
    return scale * selectionScale;
  }

  // Etiqueta descriptiva
  String? _label;

  String? get label => _label;
  set label(String? value) {
    if (_label != value) {
      _label = value;
      notifyListeners();
    }
  }

  // Flag para indicar cambios en la transformación
  bool _transformChanged = true;

  /// Flag para indicar cambios en la transformación
  bool get hasTransformChanged => _transformChanged;
  set hasTransformChanged(bool value) {
    _transformChanged = value;
  }

  // Flag para indicar colisión
  bool _isColliding = false;
  final List<ParkingElement> _collidingWith = [];

  // Matriz de transformación cacheada
  final vector_math.Matrix3 _transformMatrix = vector_math.Matrix3.identity();

  /// Limpia la lista de colisiones
  void clearCollisions() {
    if (_collidingWith.isNotEmpty || _isColliding) {
      _isColliding = false;
      _collidingWith.clear();
      notifyListeners();
    }
  }

  /// Añade un elemento a la lista de colisiones
  void addCollision(ParkingElement element) {
    if (!_collidingWith.contains(element)) {
      _collidingWith.add(element);
      _isColliding = true;
      notifyListeners();
    }
  }

  /// Devuelve una representación precisa del área ocupada por este elemento
  Rect getOccupiedArea() {
    final size = getSize();
    final scaledWidth = size.width * _scale;
    final scaledHeight = size.height * _scale;

    return Rect.fromCenter(
      center: Offset(_position.x, _position.y),
      width: scaledWidth,
      height: scaledHeight,
    );
  }

  /// Detecta colisión con otro elemento considerando rotación
  bool collidesWithElement(ParkingElement other) {
    // Si alguno de los elementos no es visible, no hay colisión
    if (!isVisible || !other.isVisible) {
      return false;
    }

    // Obtener tamaños y rectángulos de colisión
    final thisSize = getSize();
    final otherSize = other.getSize();

    final thisWidth = thisSize.width * scale;
    final thisHeight = thisSize.height * scale;
    final otherWidth = otherSize.width * other.scale;
    final otherHeight = otherSize.height * other.scale;

    // Si no hay rotación en ninguno de los elementos, usar detección de colisión simple con rectángulos
    if (rotation == 0 && other.rotation == 0) {
      final thisRect = Rect.fromCenter(
        center: Offset(position.x, position.y),
        width: thisWidth,
        height: thisHeight,
      );

      final otherRect = Rect.fromCenter(
        center: Offset(other.position.x, other.position.y),
        width: otherWidth,
        height: otherHeight,
      );

      return thisRect.overlaps(otherRect);
    }

    // Para elementos con rotación, usar una detección más sofisticada
    // Crear puntos para las esquinas de ambos elementos
    final thisHalfWidth = thisWidth / 2;
    final thisHalfHeight = thisHeight / 2;
    final otherHalfWidth = otherWidth / 2;
    final otherHalfHeight = otherHeight / 2;

    // Vertices del primer elemento
    final thisVertices = [
      _rotatePoint(
          -thisHalfWidth, -thisHalfHeight, rotation, position.x, position.y),
      _rotatePoint(
          thisHalfWidth, -thisHalfHeight, rotation, position.x, position.y),
      _rotatePoint(
          thisHalfWidth, thisHalfHeight, rotation, position.x, position.y),
      _rotatePoint(
          -thisHalfWidth, thisHalfHeight, rotation, position.x, position.y),
    ];

    // Vertices del segundo elemento
    final otherVertices = [
      _rotatePoint(-otherHalfWidth, -otherHalfHeight, other.rotation,
          other.position.x, other.position.y),
      _rotatePoint(otherHalfWidth, -otherHalfHeight, other.rotation,
          other.position.x, other.position.y),
      _rotatePoint(otherHalfWidth, otherHalfHeight, other.rotation,
          other.position.x, other.position.y),
      _rotatePoint(-otherHalfWidth, otherHalfHeight, other.rotation,
          other.position.x, other.position.y),
    ];

    // Verificar si los polígonos se intersecan usando el Teorema de Separación de Ejes
    return _polygonsIntersect(thisVertices, otherVertices);
  }

  /// Rota un punto alrededor del origen y luego lo traslada
  Offset _rotatePoint(
      double x, double y, double angle, double centerX, double centerY) {
    final s = math.sin(angle);
    final c = math.cos(angle);

    // Rotar el punto alrededor del origen
    final xnew = x * c - y * s;
    final ynew = x * s + y * c;

    // Trasladar al centro del elemento
    return Offset(xnew + centerX, ynew + centerY);
  }

  /// Verifica si dos polígonos se intersecan usando el Teorema de Separación de Ejes
  bool _polygonsIntersect(List<Offset> polygonA, List<Offset> polygonB) {
    // Obtener ejes de proyección de ambos polígonos
    final axes = _getAxes(polygonA)..addAll(_getAxes(polygonB));

    // Verificar si hay separación en algún eje
    for (final axis in axes) {
      final projectionA = _projectPolygon(polygonA, axis);
      final projectionB = _projectPolygon(polygonB, axis);

      // Si hay separación en algún eje, no hay colisión
      if (projectionA.max < projectionB.min ||
          projectionB.max < projectionA.min) {
        return false;
      }
    }

    // Si no hay separación en ningún eje, hay colisión
    return true;
  }

  /// Obtiene los ejes de proyección de un polígono (perpendiculares a cada lado)
  List<Offset> _getAxes(List<Offset> polygon) {
    final axes = <Offset>[];

    for (int i = 0; i < polygon.length; i++) {
      final p1 = polygon[i];
      final p2 = polygon[(i + 1) % polygon.length];

      // Calcular el vector del lado
      final edge = Offset(p2.dx - p1.dx, p2.dy - p1.dy);

      // Calcular el vector perpendicular (eje de proyección)
      final normal = Offset(-edge.dy, edge.dx);

      // Normalizar el vector
      final length = math.sqrt(normal.dx * normal.dx + normal.dy * normal.dy);
      final normalized = Offset(normal.dx / length, normal.dy / length);

      axes.add(normalized);
    }

    return axes;
  }

  /// Proyecta un polígono sobre un eje y devuelve los valores mínimo y máximo
  _Projection _projectPolygon(List<Offset> polygon, Offset axis) {
    double min = double.infinity;
    double max = double.negativeInfinity;

    for (final vertex in polygon) {
      // Calcular el producto escalar del vértice con el eje
      final projection = vertex.dx * axis.dx + vertex.dy * axis.dy;

      if (projection < min) min = projection;
      if (projection > max) max = projection;
    }

    return _Projection(min, max);
  }

  // Métodos para manipulación

  /// Actualiza la matriz de transformación
  void updateTransform() {
    // Reiniciar a matriz identidad
    _transformMatrix.setIdentity();

    // Aplicar transformaciones en orden: escala, rotación, traslación
    _transformMatrix.scale(_scale);

    // Aplicar rotación
    final double s = math.sin(_rotation);
    final double c = math.cos(_rotation);
    final double m0 = _transformMatrix[0];
    final double m1 = _transformMatrix[1];
    final double m3 = _transformMatrix[3];
    final double m4 = _transformMatrix[4];

    _transformMatrix[0] = c * m0 + s * m3;
    _transformMatrix[1] = c * m1 + s * m4;
    _transformMatrix[3] = -s * m0 + c * m3;
    _transformMatrix[4] = -s * m1 + c * m4;

    // Aplicar traslación
    _transformMatrix[6] = _position.x;
    _transformMatrix[7] = _position.y;

    _transformChanged = false;
  }

  /// Convierte la posición del mundo a posición de pantalla
  vector_math.Vector2 getScreenPosition(
      double zoom, vector_math.Vector2 cameraPosition) {
    final screenX = (_position.x * zoom) - cameraPosition.x;
    final screenY = (_position.y * zoom) - cameraPosition.y;
    return vector_math.Vector2(screenX, screenY);
  }

  /// Verifica si un punto del mundo está contenido en este elemento
  bool containsPoint(vector_math.Vector2 point, double zoom) {
    // Aquí el punto ya está en coordenadas del mundo, igual que la posición del elemento
    final size = getSize();
    final scaledWidth = size.width * _scale;
    final scaledHeight = size.height * _scale;

    // Crear un rectángulo para la detección de colisión básica
    final rect = Rect.fromCenter(
      center: Offset(_position.x, _position.y),
      width: scaledWidth,
      height: scaledHeight,
    );

    // Aplicar rotación si es necesario
    if (_rotation != 0) {
      // Para elementos con rotación, necesitamos transformar el punto para la detección
      final dx = point.x - _position.x;
      final dy = point.y - _position.y;

      // Rotar el punto en dirección opuesta a la rotación del elemento
      final rotatedX = dx * math.cos(-_rotation) - dy * math.sin(-_rotation);
      final rotatedY = dx * math.sin(-_rotation) + dy * math.cos(-_rotation);

      // Verificar si el punto rotado está dentro del rectángulo sin rotación
      return Rect.fromCenter(
        center: const Offset(0, 0),
        width: scaledWidth,
        height: scaledHeight,
      ).contains(Offset(rotatedX, rotatedY));
    }

    return rect.contains(Offset(point.x, point.y));
  }

  /// Obtiene el tamaño base del elemento
  Size getSize();

  /// Renderiza el elemento en el canvas
  void render(Canvas canvas, dynamic renderer);

  /// Clona este elemento
  ParkingElement clone();

  /// Método para serializar a JSON
  Map<String, dynamic> toJson();

  /// Factory method para deserializar desde JSON
  static ParkingElement fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('Subclases deben implementar fromJson');
  }

  @override
  String toString() {
    return 'ParkingElement(id: $id, position: $_position, rotation: $_rotation, scale: $_scale)';
  }

  /// Método auxiliar para renderizar la etiqueta de un elemento
  void renderLabel(Canvas canvas, Offset position, double zoom) {
    // Este método ya no se utiliza. Cada elemento dibujará su propia etiqueta internamente.
    // Se mantiene por compatibilidad pero no realiza ninguna operación.
  }

  /// Método auxiliar para dibujar iconos
  void drawIcon(Canvas canvas, IconData iconData, Size size, Color color,
      [double scale = 1.0]) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontFamily: iconData.fontFamily,
          package: iconData.fontPackage,
          fontSize: math.min(size.width, size.height) * 0.5 * scale,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        -textPainter.width / 2,
        -textPainter.height / 2,
      ),
    );
  }
}
