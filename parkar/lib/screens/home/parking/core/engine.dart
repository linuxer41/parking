import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../core/vector2.dart';
import '../systems/physics_system.dart';
import '../systems/rendering_system.dart';
import 'scene.dart';
import 'time.dart';

/// Core game engine class for the parking system
class Engine {
  // Core components
  Scene? _activeScene;
  late Time _time;
  
  // Systems
  late RenderingSystem _renderingSystem;
  late PhysicsSystem _physicsSystem;
  
  // Engine state
  bool _isRunning = false;
  late Ticker _ticker;
  
  // Camera and viewport settings
  Vector2 _cameraPosition = Vector2(0, 0);
  double _zoom = 1.0;
  
  // Getters
  bool get isRunning => _isRunning;
  Scene? get activeScene => _activeScene;
  Vector2 get cameraPosition => _cameraPosition;
  double get zoom => _zoom;
  RenderingSystem get renderingSystem => _renderingSystem;
  
  /// Initialize the engine
  void initialize(TickerProvider tickerProvider, Scene initialScene) {
    // Initialize core components
    _time = Time();
    _renderingSystem = RenderingSystem();
    _physicsSystem = PhysicsSystem();
    
    // Activar modo de rendimiento optimizado por defecto
    _renderingSystem.simplifiedRendering = true;
    
    // Activar modo ultra rendimiento para mejor FPS
    setUltraPerformanceMode(true);
    
    // Set up ticker
    _ticker = tickerProvider.createTicker(_gameLoop);
    
    // Set initial scene
    _activeScene = initialScene;
  }
  
  /// Start the engine
  void start() {
    if (_isRunning) return;
    
    _isRunning = true;
    _ticker.start();
  }
  
  /// Stop the engine
  void stop() {
    if (!_isRunning) return;
    
    _isRunning = false;
    _ticker.stop();
  }
  
  /// Dispose of engine resources
  void dispose() {
    stop();
    _ticker.dispose();
  }
  
  /// Main game loop
  void _gameLoop(Duration elapsedTime) {
    // Update time
    _time.update(elapsedTime);
    
    // Skip if no active scene
    if (_activeScene == null) return;
    
    // Update all game objects
    for (final gameObject in _activeScene!.gameObjects) {
      if (gameObject.isActive) {
        gameObject.update(_time.deltaTime);
      }
    }
    
    // Update physics
    _physicsSystem.update(_activeScene!, _time.deltaTime);
  }
  
  /// Render the active scene
  void render(Canvas canvas, Size size) {
    if (_activeScene == null) return;
    _renderingSystem.render(canvas, size, _activeScene!, _zoom, _cameraPosition);
  }
  
  /// Set camera position
  void setCameraPosition(Vector2 position) {
    _cameraPosition = position;
  }
  
  /// Set zoom level
  void setZoom(double zoom) {
    _zoom = zoom;
  }
  
  /// Toggle simplified rendering mode for better performance
  void toggleSimplifiedRendering() {
    _renderingSystem.simplifiedRendering = !_renderingSystem.simplifiedRendering;
  }
  
  /// Set ultra performance mode
  void setUltraPerformanceMode(bool enabled) {
    // Aplicar configuración al sistema de renderizado
    _renderingSystem.setUltraPerformanceMode(enabled);
  }
} 