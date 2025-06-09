import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

import 'world_elements.dart';

/// Clase base para componentes que se pueden añadir a elementos del mundo
abstract class Component {
  /// Elemento al que pertenece este componente
  WorldElement owner;
  
  /// Indica si el componente está activo
  bool isEnabled = true;
  
  /// Constructor
  Component({required this.owner});
  
  /// Método llamado cuando se inicia el componente
  void start() {}
  
  /// Método llamado en cada actualización
  void update(double deltaTime) {}
  
  /// Método llamado cuando se renderiza el elemento
  void render(Canvas canvas, Size canvasSize, double zoom, vector_math.Vector2 cameraOffset) {}
  
  /// Método llamado cuando se destruye el componente
  void dispose() {}
}

/// Sistema de gestión de componentes para elementos del mundo
class ComponentSystem {
  /// Mapa de componentes por elemento
  final Map<String, List<Component>> _componentsByElement = {};
  
  /// Añadir un componente a un elemento
  void addComponent(WorldElement element, Component component) {
    if (!_componentsByElement.containsKey(element.id)) {
      _componentsByElement[element.id] = [];
    }
    
    _componentsByElement[element.id]!.add(component);
    component.start();
  }
  
  /// Obtener todos los componentes de un elemento
  List<Component> getComponents(WorldElement element) {
    return _componentsByElement[element.id] ?? [];
  }
  
  /// Obtener un componente específico de un elemento
  T? getComponent<T extends Component>(WorldElement element) {
    final components = _componentsByElement[element.id];
    if (components == null) return null;
    
    for (final component in components) {
      if (component is T) {
        return component;
      }
    }
    
    return null;
  }
  
  /// Eliminar un componente específico de un elemento
  void removeComponent<T extends Component>(WorldElement element) {
    final components = _componentsByElement[element.id];
    if (components == null) return;
    
    components.removeWhere((component) {
      if (component is T) {
        component.dispose();
        return true;
      }
      return false;
    });
  }
  
  /// Eliminar todos los componentes de un elemento
  void removeAllComponents(WorldElement element) {
    final components = _componentsByElement[element.id];
    if (components == null) return;
    
    for (final component in components) {
      component.dispose();
    }
    
    _componentsByElement.remove(element.id);
  }
  
  /// Actualizar todos los componentes
  void updateAll(double deltaTime) {
    for (final components in _componentsByElement.values) {
      for (final component in components) {
        if (component.isEnabled && component.owner.isVisible) {
          component.update(deltaTime);
        }
      }
    }
  }
  
  /// Renderizar todos los componentes
  void renderAll(Canvas canvas, Size canvasSize, double zoom, vector_math.Vector2 cameraOffset) {
    for (final components in _componentsByElement.values) {
      for (final component in components) {
        if (component.isEnabled && component.owner.isVisible) {
          component.render(canvas, canvasSize, zoom, cameraOffset);
        }
      }
    }
  }
  
  /// Limpiar todos los componentes
  void clear() {
    for (final components in _componentsByElement.values) {
      for (final component in components) {
        component.dispose();
      }
    }
    
    _componentsByElement.clear();
  }
}

/// Componente para animación de elementos
class AnimationComponent extends Component {
  /// Frames de la animación
  final List<Frame> frames;
  
  /// Duración de cada frame en segundos
  final double frameDuration;
  
  /// Frame actual
  int _currentFrameIndex = 0;
  
  /// Tiempo transcurrido en el frame actual
  double _frameTime = 0.0;
  
  /// Indica si la animación está en bucle
  final bool loop;
  
  /// Constructor
  AnimationComponent({
    required WorldElement owner,
    required this.frames,
    this.frameDuration = 0.1,
    this.loop = true,
  }) : super(owner: owner);
  
  @override
  void update(double deltaTime) {
    _frameTime += deltaTime;
    
    if (_frameTime >= frameDuration) {
      _frameTime = 0.0;
      _currentFrameIndex++;
      
      if (_currentFrameIndex >= frames.length) {
        if (loop) {
          _currentFrameIndex = 0;
        } else {
          _currentFrameIndex = frames.length - 1;
          isEnabled = false;
        }
      }
    }
    
    // Aplicar el frame actual al elemento
    final frame = frames[_currentFrameIndex];
    if (frame.color != null) {
      owner.color = frame.color!;
    }
    if (frame.icon != null) {
      owner.icon = frame.icon;
    }
    if (frame.opacity != null) {
      owner.opacity = frame.opacity!;
    }
  }
}

/// Clase para representar un frame de animación
class Frame {
  final Color? color;
  final IconData? icon;
  final double? opacity;
  
  Frame({this.color, this.icon, this.opacity});
}

/// Componente para efectos visuales
class VisualEffectComponent extends Component {
  /// Tipo de efecto visual
  final VisualEffectType effectType;
  
  /// Duración del efecto en segundos
  final double duration;
  
  /// Intensidad del efecto
  final double intensity;
  
  /// Tiempo transcurrido
  double _elapsedTime = 0.0;
  
  /// Constructor
  VisualEffectComponent({
    required WorldElement owner,
    required this.effectType,
    this.duration = 1.0,
    this.intensity = 1.0,
  }) : super(owner: owner);
  
  @override
  void update(double deltaTime) {
    _elapsedTime += deltaTime;
    
    // Calcular progreso del efecto (0.0 a 1.0)
    final progress = (_elapsedTime / duration).clamp(0.0, 1.0);
    
    // Aplicar efecto según el tipo
    switch (effectType) {
      case VisualEffectType.pulse:
        _applyPulseEffect(progress);
        break;
      case VisualEffectType.fade:
        _applyFadeEffect(progress);
        break;
      case VisualEffectType.shake:
        _applyShakeEffect(progress);
        break;
    }
    
    // Desactivar el componente cuando termina
    if (_elapsedTime >= duration) {
      isEnabled = false;
    }
  }
  
  /// Aplicar efecto de pulso
  void _applyPulseEffect(double progress) {
    // Calcular escala basada en una función sinusoidal
    final scale = 1.0 + intensity * 0.2 * math.sin(progress * 2 * math.pi);
    
    // Aplicar escala manteniendo el centro del elemento
    owner.resize(owner.size.width * scale, owner.size.height * scale);
  }
  
  /// Aplicar efecto de desvanecimiento
  void _applyFadeEffect(double progress) {
    // Calcular opacidad basada en el progreso
    owner.opacity = 1.0 - progress;
  }
  
  /// Aplicar efecto de temblor
  void _applyShakeEffect(double progress) {
    // Solo aplicar si no ha terminado
    if (progress < 1.0) {
      // Calcular desplazamiento aleatorio basado en la intensidad
      final dx = (math.Random().nextDouble() - 0.5) * intensity * 5.0;
      final dy = (math.Random().nextDouble() - 0.5) * intensity * 5.0;
      
      // Aplicar desplazamiento temporal
      owner.position.x += dx;
      owner.position.y += dy;
    } else {
      // Restaurar posición original al finalizar
      owner.updateTransform();
    }
  }
}

/// Tipos de efectos visuales
enum VisualEffectType {
  pulse,
  fade,
  shake,
}

/// Componente para movimiento automático
class MovementComponent extends Component {
  /// Posición objetivo
  final vector_math.Vector2 targetPosition;
  
  /// Velocidad de movimiento en unidades por segundo
  final double speed;
  
  /// Indica si el movimiento debe detenerse al llegar al objetivo
  final bool stopAtTarget;
  
  /// Constructor
  MovementComponent({
    required WorldElement owner,
    required this.targetPosition,
    this.speed = 50.0,
    this.stopAtTarget = true,
  }) : super(owner: owner);
  
  @override
  void update(double deltaTime) {
    // Calcular dirección hacia el objetivo
    final direction = vector_math.Vector2(
      targetPosition.x - owner.position.x,
      targetPosition.y - owner.position.y,
    );
    
    // Calcular distancia al objetivo
    final distance = direction.length;
    
    // Si estamos cerca del objetivo, detenerse o llegar exactamente
    if (distance < speed * deltaTime) {
      if (stopAtTarget) {
        owner.position.x = targetPosition.x;
        owner.position.y = targetPosition.y;
        isEnabled = false;
      }
      return;
    }
    
    // Normalizar dirección y aplicar velocidad
    direction.normalize();
    direction.scale(speed * deltaTime);
    
    // Mover el elemento
    owner.position.x += direction.x;
    owner.position.y += direction.y;
  }
} 