import 'package:flutter/material.dart';
import '../core/engine.dart';
import '../systems/rendering_system.dart';

/// Clase estática que gestiona la configuración de rendimiento global
class PerformanceManager {
  // Singleton
  static final PerformanceManager _instance = PerformanceManager._internal();
  
  // Motor principal de la aplicación
  Engine? _engine;
  
  // Nivel de rendimiento
  PerformanceLevel _level = PerformanceLevel.ultra;
  
  // Getters
  PerformanceLevel get level => _level;
  
  // Constructor privado
  PerformanceManager._internal();
  
  // Método para obtener la instancia
  factory PerformanceManager() {
    return _instance;
  }
  
  /// Configurar el motor
  void configureEngine(Engine engine) {
    _engine = engine;
    _applyPerformanceSettings();
  }
  
  /// Establecer nivel de rendimiento
  void setPerformanceLevel(PerformanceLevel level) {
    _level = level;
    _applyPerformanceSettings();
  }
  
  /// Aplicar configuración de rendimiento
  void _applyPerformanceSettings() {
    if (_engine == null) return;
    
    switch (_level) {
      case PerformanceLevel.low:
        _engine!.renderingSystem.simplifiedRendering = false;
        _engine!.renderingSystem.useLowDetailMode = false;
        _engine!.renderingSystem.drawGrid = true;
        break;
        
      case PerformanceLevel.medium:
        _engine!.renderingSystem.simplifiedRendering = true;
        _engine!.renderingSystem.useLowDetailMode = false;
        _engine!.renderingSystem.drawGrid = true;
        break;
        
      case PerformanceLevel.high:
        _engine!.renderingSystem.simplifiedRendering = true;
        _engine!.renderingSystem.useLowDetailMode = false;
        _engine!.renderingSystem.drawGrid = false;
        break;
        
      case PerformanceLevel.ultra:
        _engine!.setUltraPerformanceMode(true);
        break;
    }
  }
}

/// Niveles de rendimiento
enum PerformanceLevel {
  low,      // Calidad visual máxima
  medium,   // Balance entre calidad y rendimiento
  high,     // Rendimiento prioritario
  ultra     // Rendimiento máximo (120fps+)
} 