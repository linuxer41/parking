import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

import '../core/world_state.dart';
import '../models/component_system.dart';
import '../models/world_elements.dart';
import '../models/element_factory.dart';
import '../models/index.dart';

/// Clase con ejemplos de uso del sistema de componentes
class ComponentExamples {
  /// Añadir un efecto de pulso a un elemento
  static void addPulseEffect(WorldState worldState, WorldElement element) {
    final effect = VisualEffectComponent(
      owner: element,
      effectType: VisualEffectType.pulse,
      duration: 2.0,
      intensity: 1.0,
    );
    
    worldState.addComponent(element, effect);
  }
  
  /// Añadir un efecto de desvanecimiento a un elemento
  static void addFadeEffect(WorldState worldState, WorldElement element) {
    final effect = VisualEffectComponent(
      owner: element,
      effectType: VisualEffectType.fade,
      duration: 1.5,
      intensity: 1.0,
    );
    
    worldState.addComponent(element, effect);
  }
  
  /// Añadir un efecto de temblor a un elemento
  static void addShakeEffect(WorldState worldState, WorldElement element) {
    final effect = VisualEffectComponent(
      owner: element,
      effectType: VisualEffectType.shake,
      duration: 0.5,
      intensity: 2.0,
    );
    
    worldState.addComponent(element, effect);
  }
  
  /// Añadir un movimiento automático a un elemento
  static void addMovement(
    WorldState worldState, 
    WorldElement element, 
    vector_math.Vector2 targetPosition,
  ) {
    final movement = MovementComponent(
      owner: element,
      targetPosition: targetPosition,
      speed: 100.0, // unidades por segundo
    );
    
    worldState.addComponent(element, movement);
  }
  
  /// Añadir una animación de cambio de color a un elemento
  static void addColorAnimation(WorldState worldState, WorldElement element) {
    final frames = [
      Frame(color: Colors.blue),
      Frame(color: Colors.green),
      Frame(color: Colors.red),
      Frame(color: Colors.orange),
      Frame(color: Colors.purple),
    ];
    
    final animation = AnimationComponent(
      owner: element,
      frames: frames,
      frameDuration: 0.2, // segundos por frame
      loop: true,
    );
    
    worldState.addComponent(element, animation);
  }
  
  /// Crear un espacio de estacionamiento animado
  static ParkingSpot createAnimatedParkingSpot(
    WorldState worldState,
    vector_math.Vector2 position,
    {SpotType type = SpotType.vehicle}
  ) {
    // Crear el espacio
    final spot = WorldElementFactory.createSpot(
      position: position,
      type: type,
      label: 'Animado',
    );
    
    // Añadir al mundo
    worldState.addSpot(spot);
    
    // Añadir efecto de pulso
    addPulseEffect(worldState, spot);
    
    return spot;
  }
  
  /// Demostración de efectos visuales
  static void demonstrateVisualEffects(WorldState worldState) {
    // Crear espacios con diferentes efectos
    final positions = [
      vector_math.Vector2(100, 100),
      vector_math.Vector2(200, 100),
      vector_math.Vector2(300, 100),
    ];
    
    // Espacio con efecto de pulso
    final spot1 = createAnimatedParkingSpot(worldState, positions[0]);
    
    // Espacio con efecto de desvanecimiento
    final spot2 = WorldElementFactory.createSpot(
      position: positions[1],
      type: SpotType.motorcycle,
      label: 'Fade',
    );
    worldState.addSpot(spot2);
    addFadeEffect(worldState, spot2);
    
    // Espacio con efecto de temblor
    final spot3 = WorldElementFactory.createSpot(
      position: positions[2],
      type: SpotType.truck,
      label: 'Shake',
    );
    worldState.addSpot(spot3);
    addShakeEffect(worldState, spot3);
  }
  
  /// Demostración de movimiento automático
  static void demonstrateMovement(WorldState worldState) {
    // Crear una señal que se mueve automáticamente
    final signage = WorldElementFactory.createSignage(
      position: vector_math.Vector2(100, 200),
      type: SignageType.entrance,
      label: 'Movimiento',
    );
    
    worldState.addSignage(signage);
    
    // Añadir movimiento hacia un punto específico
    addMovement(
      worldState, 
      signage, 
      vector_math.Vector2(300, 300),
    );
  }
  
  /// Demostración completa
  static void runFullDemo(WorldState worldState) {
    demonstrateVisualEffects(worldState);
    demonstrateMovement(worldState);
  }
} 