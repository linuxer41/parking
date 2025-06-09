import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

/// Clase que gestiona una cámara 2D para sistemas de visualización
/// Inspirada en cámaras de motores de videojuegos como Unity/Unreal/Godot
class Camera with ChangeNotifier {
  // Posición de la cámara en el mundo
  vector_math.Vector2 _position = vector_math.Vector2(0, 0);
  
  // Nivel de zoom (escala)
  double _zoom = 1.0;
  
  // Límites de la cámara (opcionales)
  Rect? _bounds;
  
  // Tamaño del viewport (pantalla)
  Size _viewportSize = Size.zero;
  
  // Velocidad de movimiento y zoom para animaciones
  double _moveSpeed = 5.0;
  double _zoomSpeed = 0.1;
  
  // Constructor
  Camera({
    vector_math.Vector2? initialPosition,
    double initialZoom = 1.0,
    Size viewportSize = Size.zero,
    Rect? bounds,
  }) {
    _position = initialPosition ?? vector_math.Vector2(0, 0);
    _zoom = initialZoom.clamp(0.1, 10.0);
    _viewportSize = viewportSize;
    _bounds = bounds;
  }
  
  // Getters
  vector_math.Vector2 get position => _position;
  double get zoom => _zoom;
  Size get viewportSize => _viewportSize;
  Rect? get bounds => _bounds;
  
  // Setters
  set position(vector_math.Vector2 newPosition) {
    if (_position != newPosition) {
      _position = _applyBoundsToPosition(newPosition);
      notifyListeners();
    }
  }
  
  set zoom(double newZoom) {
    // Limitar el zoom a un rango razonable
    newZoom = newZoom.clamp(0.1, 10.0);
    
    if (_zoom != newZoom) {
      _zoom = newZoom;
      notifyListeners();
    }
  }
  
  set viewportSize(Size newSize) {
    if (_viewportSize != newSize) {
      _viewportSize = newSize;
      notifyListeners();
    }
  }
  
  set bounds(Rect? newBounds) {
    if (_bounds != newBounds) {
      _bounds = newBounds;
      // Asegurar que la posición actual esté dentro de los límites
      if (_bounds != null) {
        position = _applyBoundsToPosition(_position);
      }
      notifyListeners();
    }
  }
  
  // Aplicar límites a la posición
  vector_math.Vector2 _applyBoundsToPosition(vector_math.Vector2 pos) {
    if (_bounds == null) return pos;
    
    // Calcular el área visible basado en el zoom y el tamaño del viewport
    final visibleWidth = _viewportSize.width / _zoom;
    final visibleHeight = _viewportSize.height / _zoom;
    
    // Asegurar que la cámara no se salga de los límites
    double x = pos.x;
    double y = pos.y;
    
    if (visibleWidth < _bounds!.width) {
      x = x.clamp(_bounds!.left + visibleWidth / 2, _bounds!.right - visibleWidth / 2);
    } else {
      x = _bounds!.center.dx;
    }
    
    if (visibleHeight < _bounds!.height) {
      y = y.clamp(_bounds!.top + visibleHeight / 2, _bounds!.bottom - visibleHeight / 2);
    } else {
      y = _bounds!.center.dy;
    }
    
    return vector_math.Vector2(x, y);
  }
  
  /// Mover la cámara a una posición específica inmediatamente
  void moveTo(vector_math.Vector2 newPosition) {
    position = newPosition;
  }
  
  /// Aplicar zoom a un nivel específico inmediatamente
  void zoomTo(double newZoom) {
    zoom = newZoom;
  }
  
  /// Centrar la cámara en un punto específico
  void centerOn(vector_math.Vector2 target) {
    position = target;
  }
  
  /// Centrar la cámara en el origen (0,0)
  void centerOnOrigin() {
    position = vector_math.Vector2(0, 0);
  }
  
  /// Centrar la cámara para mostrar un rectángulo específico
  void frameRect(Rect rect, {double padding = 1.1}) {
    // Calcular el zoom necesario para mostrar el rectángulo completo
    final horizontalZoom = _viewportSize.width / (rect.width * padding);
    final verticalZoom = _viewportSize.height / (rect.height * padding);
    
    // Usar el zoom más pequeño para asegurar que todo el rectángulo sea visible
    final newZoom = [horizontalZoom, verticalZoom, 10.0].reduce((a, b) => a < b ? a : b);
    
    // Aplicar el nuevo zoom
    zoom = newZoom;
    
    // Centrar en el centro del rectángulo
    centerOn(vector_math.Vector2(rect.center.dx, rect.center.dy));
  }
  
  /// Centrar la vista en el origen con el zoom adecuado
  void centerViewOnOrigin(Size screenSize) {
    viewportSize = screenSize;
    centerOnOrigin();
    zoom = 1.0;
  }
  
  /// Convertir coordenadas del mundo a coordenadas de pantalla
  /// Asegura que el origen (0,0) del mundo esté en el centro de la pantalla
  Offset worldToScreen(vector_math.Vector2 worldPos) {
    final viewportCenter = Offset(_viewportSize.width / 2, _viewportSize.height / 2);
    final relativeToCamera = vector_math.Vector2(
      worldPos.x - _position.x,
      worldPos.y - _position.y
    );
    
    return viewportCenter + Offset(
      relativeToCamera.x * _zoom,
      relativeToCamera.y * _zoom,
    );
  }
  
  /// Convertir coordenadas de pantalla a coordenadas del mundo
  /// Asegura que el centro de la pantalla corresponda al origen (0,0) del mundo
  vector_math.Vector2 screenToWorld(Offset screenPos) {
    final viewportCenter = Offset(_viewportSize.width / 2, _viewportSize.height / 2);
    final relativeToCenter = Offset(
      (screenPos.dx - viewportCenter.dx) / _zoom,
      (screenPos.dy - viewportCenter.dy) / _zoom,
    );
    
    return vector_math.Vector2(
      _position.x + relativeToCenter.dx,
      _position.y + relativeToCenter.dy,
    );
  }
  
  /// Obtener la matriz de transformación para dibujar en el canvas
  /// Asegura que el origen (0,0) esté centrado en la pantalla
  Matrix4 get viewMatrix {
    final result = Matrix4.identity();
    
    // Traducir al centro del viewport (esto pone el origen del mundo en el centro visual)
    result.translate(_viewportSize.width / 2, _viewportSize.height / 2, 0);
    
    // Aplicar zoom
    result.scale(_zoom, _zoom, 1);
    
    // Traducir para compensar la posición de la cámara
    result.translate(-_position.x, -_position.y, 0);
    
    return result;
  }
  
  /// Calcular el rectángulo visible en coordenadas del mundo
  Rect getVisibleRect() {
    final topLeft = screenToWorld(Offset.zero);
    final bottomRight = screenToWorld(Offset(_viewportSize.width, _viewportSize.height));
    
    return Rect.fromPoints(
      Offset(topLeft.x, topLeft.y),
      Offset(bottomRight.x, bottomRight.y),
    );
  }
  
  /// Verificar si un punto del mundo es visible en la pantalla
  bool isWorldPointVisible(vector_math.Vector2 worldPoint) {
    return getVisibleRect().contains(Offset(worldPoint.x, worldPoint.y));
  }
  
  /// Verificar si un rectángulo del mundo es visible en la pantalla
  bool isWorldRectVisible(Rect worldRect) {
    return getVisibleRect().overlaps(worldRect);
  }
  
  /// Aplicar movimiento a la cámara (para animaciones o controles)
  void pan(Offset delta) {
    final worldDelta = vector_math.Vector2(
      -delta.dx / _zoom,
      -delta.dy / _zoom,
    );
    position = vector_math.Vector2(
      _position.x + worldDelta.x,
      _position.y + worldDelta.y,
    );
  }
  
  /// Aplicar zoom en un punto específico de la pantalla
  void zoomAtPoint(double zoomFactor, Offset screenPoint) {
    // Convertir el punto de pantalla a mundo antes del zoom
    final worldPointBefore = screenToWorld(screenPoint);
    
    // Aplicar el nuevo zoom
    zoom = _zoom * zoomFactor;
    
    // Convertir el mismo punto del mundo a pantalla después del zoom
    final screenPointAfter = worldToScreen(worldPointBefore);
    
    // Calcular la diferencia y ajustar la posición de la cámara
    final screenDelta = screenPoint - screenPointAfter;
    pan(screenDelta);
  }
  
  /// Reiniciar la cámara a su estado inicial
  void reset() {
    position = vector_math.Vector2(0, 0);
    zoom = 1.0;
  }
  
  /// Método para hacer zoom con animación
  Future<void> zoomToWithAnimation(double targetZoom, TickerProvider vsync) async {
    if (targetZoom == zoom) return;
    
    // Crear el controlador de animación
    final controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: vsync,
    );
    
    // Crear la curva de animación
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );
    
    // Valores inicial y final
    final startZoom = zoom;
    final endZoom = targetZoom.clamp(0.1, 10.0);
    
    // Agregar listener para actualizar el zoom durante la animación
    controller.addListener(() {
      final progress = animation.value;
      zoom = startZoom + (endZoom - startZoom) * progress;
    });
    
    // Limpiar después de completar
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      }
    });
    
    // Iniciar la animación
    await controller.forward();
  }
  
  /// Método para centrar la vista en un punto específico con animación
  Future<void> centerOnPointWithAnimation(
    vector_math.Vector2 point, 
    TickerProvider vsync, {
    double? targetZoom,
  }) async {
    // Calcular la posición objetivo de la cámara
    final double newZoom = targetZoom ?? zoom;
    
    // Animar el zoom primero si es necesario
    if (targetZoom != null && targetZoom != zoom) {
      await zoomToWithAnimation(targetZoom, vsync);
    }
    
    // Crear el controlador de animación
    final controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: vsync,
    );
    
    // Crear la curva de animación
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );
    
    // Posición inicial y final
    final startPosition = vector_math.Vector2(_position.x, _position.y);
    final targetPosition = point;
    
    // Agregar listener para actualizar la posición durante la animación
    controller.addListener(() {
      final progress = animation.value;
      position = vector_math.Vector2(
        startPosition.x + (targetPosition.x - startPosition.x) * progress,
        startPosition.y + (targetPosition.y - startPosition.y) * progress,
      );
    });
    
    // Limpiar después de completar
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      }
    });
    
    // Iniciar la animación
    await controller.forward();
  }
} 