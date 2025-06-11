import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;
import 'dart:ui' as ui;

import '../models/parking_elements.dart';

/// Clase que gestiona las animaciones del sistema de parkeo
class AnimationManager {
  // Duración predeterminada para las animaciones
  final Duration defaultDuration;
  
  // Curva de animación predeterminada
  final Curve defaultCurve;
  
  // Controladores de animación activos
  final Map<String, AnimationController> _controllers = {};
  
  // Animaciones para elementos específicos
  final Map<String, Animation<double>> _animations = {};
  
  // Propiedades para configurar animaciones
  final bool enableSelectionAnimation;
  final bool enableMovementAnimation;
  final bool enableZoomAnimation;
  final bool enableCreateDeleteAnimation;
  
  AnimationManager({
    this.defaultDuration = const Duration(milliseconds: 300),
    this.defaultCurve = Curves.easeInOut,
    this.enableSelectionAnimation = true,
    this.enableMovementAnimation = true,
    this.enableZoomAnimation = true,
    this.enableCreateDeleteAnimation = true,
  });
  
  /// Registra un controlador de animación para un elemento específico
  void registerController(String elementId, AnimationController controller) {
    if (_controllers.containsKey(elementId)) {
      // Descartar controlador anterior
      _controllers[elementId]?.dispose();
    }
    
    _controllers[elementId] = controller;
  }
  
  /// Crea una animación de selección para un elemento
  Animation<double> createSelectionAnimation(
    String elementId, 
    AnimationController controller,
  ) {
    if (!enableSelectionAnimation) {
      // Devolver una animación nula si las animaciones están desactivadas
      return const AlwaysStoppedAnimation<double>(1.0);
    }
    
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: defaultCurve,
      ),
    );
    
    _animations[elementId] = animation;
    return animation;
  }
  
  /// Anima la transición de posición de un elemento
  Future<void> animatePosition(
    ParkingElement element,
    vector_math.Vector2 targetPosition,
    TickerProvider vsync, {
    Duration? duration,
    Curve? curve,
    VoidCallback? onComplete,
  }) async {
    if (!enableMovementAnimation) {
      // Actualizar directamente sin animación
      element.position = targetPosition;
      onComplete?.call();
      return;
    }
    
    final elementId = element.id;
    final startPosition = vector_math.Vector2(element.position.x, element.position.y);
    
    // Crear controlador si no existe
    final controller = AnimationController(
      duration: duration ?? defaultDuration,
      vsync: vsync,
    );
    
    registerController(elementId, controller);
    
    // Crear la animación
    final animation = CurvedAnimation(
      parent: controller,
      curve: curve ?? defaultCurve,
    );
    
    // Escuchar la animación y actualizar la posición
    controller.addListener(() {
      final progress = animation.value;
      element.position = vector_math.Vector2(
        startPosition.x + (targetPosition.x - startPosition.x) * progress,
        startPosition.y + (targetPosition.y - startPosition.y) * progress,
      );
    });
    
    // Configurar el callback al finalizar
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        element.position = targetPosition;
        onComplete?.call();
      }
    });
    
    // Iniciar la animación
    await controller.forward();
  }
  
  /// Anima el zoom de la cámara
  Future<void> animateZoom(
    double startZoom,
    double targetZoom,
    TickerProvider vsync,
    Function(double) onUpdate, {
    Duration? duration,
    Curve? curve,
    VoidCallback? onComplete,
  }) async {
    if (!enableZoomAnimation) {
      // Actualizar directamente sin animación
      onUpdate(targetZoom);
      onComplete?.call();
      return;
    }
    
    // Crear controlador para la animación de zoom
    final controller = AnimationController(
      duration: duration ?? defaultDuration,
      vsync: vsync,
    );
    
    registerController('zoom', controller);
    
    // Crear la animación
    final animation = CurvedAnimation(
      parent: controller,
      curve: curve ?? defaultCurve,
    );
    
    // Escuchar la animación y actualizar el zoom
    controller.addListener(() {
      final progress = animation.value;
      final currentZoom = startZoom + (targetZoom - startZoom) * progress;
      onUpdate(currentZoom);
    });
    
    // Configurar el callback al finalizar
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onUpdate(targetZoom);
        onComplete?.call();
      }
    });
    
    // Iniciar la animación
    await controller.forward();
  }
  
  /// Anima la aparición o desaparición de un elemento
  Future<void> animateFade(
    ParkingElement element,
    bool fadeIn,
    TickerProvider vsync, {
    Duration? duration,
    Curve? curve,
    VoidCallback? onComplete,
  }) async {
    if (!enableCreateDeleteAnimation) {
      // Actualizar directamente sin animación
      ElementOpacity.setOpacity(element.id, fadeIn ? 1.0 : 0.0);
      element.notifyListeners();
      onComplete?.call();
      return;
    }
    
    final elementId = element.id;
    
    // Crear controlador si no existe
    final controller = AnimationController(
      duration: duration ?? defaultDuration,
      vsync: vsync,
    );
    
    registerController(elementId, controller);
    
    // Crear la animación
    final animation = CurvedAnimation(
      parent: controller,
      curve: curve ?? defaultCurve,
    );
    
    // Configurar el valor inicial
    if (fadeIn) {
      ElementOpacity.setOpacity(element.id, 0.0);
      element.notifyListeners();
      controller.reset();
    } else {
      ElementOpacity.setOpacity(element.id, 1.0);
      element.notifyListeners();
      controller.value = 1.0;
    }
    
    // Escuchar la animación y actualizar la opacidad
    controller.addListener(() {
      final progress = fadeIn ? animation.value : 1.0 - animation.value;
      ElementOpacity.setOpacity(element.id, progress);
      element.notifyListeners();
    });
    
    // Configurar el callback al finalizar
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        ElementOpacity.setOpacity(element.id, fadeIn ? 1.0 : 0.0);
        element.notifyListeners();
        onComplete?.call();
      }
    });
    
    // Iniciar la animación en la dirección correcta
    if (fadeIn) {
      await controller.forward();
    } else {
      await controller.reverse();
    }
  }
  
  /// Anima la rotación de un elemento
  Future<void> animateRotation(
    ParkingElement element,
    double targetRotation,
    TickerProvider vsync, {
    Duration? duration,
    Curve? curve,
    VoidCallback? onComplete,
  }) async {
    if (!enableMovementAnimation) {
      // Actualizar directamente sin animación
      element.rotation = targetRotation;
      onComplete?.call();
      return;
    }
    
    final elementId = element.id;
    final startRotation = element.rotation;
    
    // Crear controlador si no existe
    final controller = AnimationController(
      duration: duration ?? defaultDuration,
      vsync: vsync,
    );
    
    registerController(elementId, controller);
    
    // Crear la animación
    final animation = CurvedAnimation(
      parent: controller,
      curve: curve ?? defaultCurve,
    );
    
    // Escuchar la animación y actualizar la rotación
    controller.addListener(() {
      final progress = animation.value;
      element.rotation = startRotation + (targetRotation - startRotation) * progress;
    });
    
    // Configurar el callback al finalizar
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        element.rotation = targetRotation;
        onComplete?.call();
      }
    });
    
    // Iniciar la animación
    await controller.forward();
  }
  
  /// Anima varios elementos de forma sincronizada
  Future<void> animateMultipleElements(
    List<ParkingElement> elements,
    List<vector_math.Vector2> targetPositions,
    TickerProvider vsync, {
    Duration? duration,
    Curve? curve,
    VoidCallback? onComplete,
  }) async {
    if (!enableMovementAnimation || elements.length != targetPositions.length) {
      // Actualizar directamente sin animación
      for (int i = 0; i < elements.length; i++) {
        if (i < targetPositions.length) {
          elements[i].position = targetPositions[i];
        }
      }
      onComplete?.call();
      return;
    }
    
    // Crear controlador único para todos los elementos
    final controller = AnimationController(
      duration: duration ?? defaultDuration,
      vsync: vsync,
    );
    
    registerController('multi_move', controller);
    
    // Crear la animación
    final animation = CurvedAnimation(
      parent: controller,
      curve: curve ?? defaultCurve,
    );
    
    // Guardar posiciones iniciales
    final startPositions = elements.map((element) => 
      vector_math.Vector2(element.position.x, element.position.y)
    ).toList();
    
    // Escuchar la animación y actualizar todas las posiciones
    controller.addListener(() {
      final progress = animation.value;
      
      for (int i = 0; i < elements.length; i++) {
        final startPos = startPositions[i];
        final targetPos = targetPositions[i];
        
        elements[i].position = vector_math.Vector2(
          startPos.x + (targetPos.x - startPos.x) * progress,
          startPos.y + (targetPos.y - startPos.y) * progress,
        );
      }
    });
    
    // Configurar el callback al finalizar
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        for (int i = 0; i < elements.length; i++) {
          elements[i].position = targetPositions[i];
        }
        onComplete?.call();
      }
    });
    
    // Iniciar la animación
    await controller.forward();
  }
  
  /// Libera los recursos utilizados por todas las animaciones
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    
    _controllers.clear();
    _animations.clear();
  }
}

/// Clase auxiliar para manejar opacidad de elementos
class ElementOpacity {
  // Mapa estático para almacenar opacidades por ID de elemento
  static final Map<String, double> _opacities = {};
  
  // Establecer opacidad para un elemento
  static void setOpacity(String elementId, double value) {
    _opacities[elementId] = value.clamp(0.0, 1.0);
  }
  
  // Obtener opacidad para un elemento
  static double getOpacity(String elementId) {
    return _opacities[elementId] ?? 1.0;
  }
  
  // Limpiar todas las opacidades
  static void clear() {
    _opacities.clear();
  }
}

/// Extensión de ParkingElement para añadir soporte de animación
extension AnimatableParkingElement on ParkingElement {
  // Getter para opacidad
  double get opacity => ElementOpacity.getOpacity(id);
  
  // Setter para opacidad
  set opacity(double value) {
    ElementOpacity.setOpacity(id, value);
    notifyListeners();
  }
} 