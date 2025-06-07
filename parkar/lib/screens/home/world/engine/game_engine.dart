import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../core/world_state.dart';
import '../models/world_elements.dart';

/// Motor de juego inspirado en Unity/MonoGame para gestionar el bucle principal
/// de actualización y renderizado del mundo.
class GameEngine {
  // Estado del mundo
  final WorldState _worldState;
  
  // Ticker para el bucle de juego
  Ticker? _ticker;
  
  // Estado del motor
  bool _isRunning = false;
  bool _isPaused = false;
  
  // Tiempo
  Duration _lastFrameTime = Duration.zero;
  double _deltaTime = 0.0;
  
  // Estadísticas de rendimiento
  int _frameCount = 0;
  double _fps = 0.0;
  Duration _fpsUpdateTime = Duration.zero;
  
  // Callback para notificar actualizaciones
  final VoidCallback? onUpdate;
  
  // Constructor
  GameEngine({
    required WorldState worldState,
    this.onUpdate,
  }) : _worldState = worldState;
  
  // Getters
  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
  double get deltaTime => _deltaTime;
  double get fps => _fps;
  
  /// Iniciar el motor
  void start(TickerProvider vsync) {
    if (_isRunning) return;
    
    _ticker = vsync.createTicker(_tick);
    _ticker!.start();
    _isRunning = true;
    _lastFrameTime = Duration(milliseconds: DateTime.now().millisecondsSinceEpoch);
    
    print('GameEngine: Started');
  }
  
  /// Pausar el motor
  void pause() {
    if (!_isRunning || _isPaused) return;
    
    _ticker?.stop();
    _isPaused = true;
    
    print('GameEngine: Paused');
  }
  
  /// Reanudar el motor
  void resume() {
    if (!_isRunning || !_isPaused) return;
    
    _ticker?.start();
    _isPaused = false;
    _lastFrameTime = Duration(milliseconds: DateTime.now().millisecondsSinceEpoch);
    
    print('GameEngine: Resumed');
  }
  
  /// Detener el motor
  void stop() {
    if (!_isRunning) return;
    
    if (_ticker != null) {
      _ticker!.stop();
      // Asegurarnos que el ticker es dispuesto correctamente
      try {
        _ticker!.dispose();
      } catch (e) {
        print('Error al disponer ticker: $e');
      }
      _ticker = null;
    }
    
    _isRunning = false;
    _isPaused = false;
    
    print('GameEngine: Stopped');
  }
  
  /// Método principal del bucle de juego
  void _tick(Duration elapsedTime) {
    // Calcular delta time (tiempo entre frames)
    final now = Duration(milliseconds: DateTime.now().millisecondsSinceEpoch);
    _deltaTime = (now - _lastFrameTime).inMicroseconds / 1000000.0; // en segundos
    _lastFrameTime = now;
    
    // Limitar delta time para evitar problemas con pausas largas
    if (_deltaTime > 0.1) _deltaTime = 0.1;
    
    // Actualizar FPS cada segundo
    _frameCount++;
    if ((now - _fpsUpdateTime).inMilliseconds > 1000) {
      _fps = _frameCount / ((now - _fpsUpdateTime).inMilliseconds / 1000.0);
      _frameCount = 0;
      _fpsUpdateTime = now;
    }
    
    // Ejecutar el ciclo de actualización
    _update();
    
    // Notificar a los observadores
    if (onUpdate != null) {
      onUpdate!();
    }
  }
  
  /// Actualizar la lógica del juego
  void _update() {
    // Actualizar todos los elementos del mundo
    for (final element in _worldState.allElements) {
      _updateElement(element);
    }
  }
  
  /// Actualizar un elemento específico
  void _updateElement(WorldElement element) {
    // Aquí se implementaría la lógica de actualización específica
    // para cada tipo de elemento, similar a Unity/MonoGame
    
    // Por ejemplo, animaciones, físicas, etc.
    
    // Por ahora, solo actualizamos las transformaciones si han cambiado
    if (element.hasTransformChanged) {
      element.updateTransform();
    }
  }
} 