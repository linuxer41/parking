import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../core/parking_state.dart';
import '../models/parking_elements.dart';

/// Motor de juego optimizado para sistema de parkeo
/// Inspirado en MonoGame/Godot/Unity pero simplificado para el sistema de parking
class GameEngine {
  // Estado del mundo de parkeo
  final ParkingMapState _parkingMapState;

  // Ticker para el bucle principal
  Ticker? _ticker;

  // Estado del motor
  bool _isRunning = false;
  bool _isPaused = false;

  // Control de tiempo
  Duration _lastFrameTime = Duration.zero;
  double _deltaTime = 0.0;

  // Estadísticas de rendimiento
  int _frameCount = 0;
  double _fps = 0.0;
  Duration _fpsUpdateTime = Duration.zero;

  // Callback para notificar actualizaciones
  final VoidCallback? onUpdate;

  // Constructor
  GameEngine({required ParkingMapState parkingMapState, this.onUpdate})
    : _parkingMapState = parkingMapState;

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
    _lastFrameTime = Duration(
      milliseconds: DateTime.now().millisecondsSinceEpoch,
    );

    debugPrint('ParkingEngine: Started');
  }

  /// Pausar el motor
  void pause() {
    if (!_isRunning || _isPaused) return;

    _ticker?.stop();
    _isPaused = true;

    debugPrint('ParkingEngine: Paused');
  }

  /// Reanudar el motor
  void resume() {
    if (!_isRunning || !_isPaused) return;

    _ticker?.start();
    _isPaused = false;
    _lastFrameTime = Duration(
      milliseconds: DateTime.now().millisecondsSinceEpoch,
    );

    debugPrint('ParkingEngine: Resumed');
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
        debugPrint('Error al disponer ticker: $e');
      }
      _ticker = null;
    }

    _isRunning = false;
    _isPaused = false;

    debugPrint('ParkingEngine: Stopped');
  }

  /// Método principal del bucle de juego
  void _tick(Duration elapsedTime) {
    // Calcular delta time (tiempo entre frames)
    final now = Duration(milliseconds: DateTime.now().millisecondsSinceEpoch);
    _deltaTime =
        (now - _lastFrameTime).inMicroseconds / 1000000.0; // en segundos
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

    // Forzar actualización de la interfaz en cada frame para mayor estabilidad map
    // Esto garantiza que los elementos siempre se muestren correctamente
    if (onUpdate != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isRunning && !_isPaused) {
          onUpdate!();
        }
      });
    }
  }

  /// Actualizar la lógica del juego
  void _update() {
    // Actualizar todos los elementos del parkeo
    for (final element in _parkingMapState.allElements) {
      _updateElement(element);
    }
  }

  /// Actualizar un elemento específico
  void _updateElement(ParkingElement element) {
    // Actualizar transformaciones si han cambiado
    if (element.hasTransformChanged) {
      element.updateTransform();

      // Garantizar que se notifique el cambio para que la UI se actualice
      if (onUpdate != null) {
        onUpdate!();
      }
    }
  }
}
