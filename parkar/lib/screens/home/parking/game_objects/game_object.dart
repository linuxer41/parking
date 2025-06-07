import 'dart:ui';
import 'package:flutter/foundation.dart';
import '../core/transform.dart';
import '../core/scene.dart';
import '../core/vector2.dart';

/// Base component class for the component system
abstract class Component {
  GameObject? _gameObject;
  
  GameObject? get gameObject => _gameObject;
  bool get enabled => _enabled;
  
  bool _enabled = true;
  
  /// Called when the component is first initialized
  void awake() {}
  
  /// Called when the component is enabled
  void onEnable() {}
  
  /// Called when the component is disabled
  void onDisable() {}
  
  /// Called every frame
  void update(double deltaTime) {}
  
  /// Called after update (useful for camera following)
  void lateUpdate(double deltaTime) {}
  
  /// Called when rendering
  void onRender(Canvas canvas, Offset position, double zoom) {}
  
  /// Called when the component is destroyed
  void onDestroy() {}
  
  /// Enable the component
  void enable() {
    if (!_enabled) {
      _enabled = true;
      onEnable();
    }
  }
  
  /// Disable the component
  void disable() {
    if (_enabled) {
      _enabled = false;
      onDisable();
    }
  }
  
  /// Set the game object reference
  void _setGameObject(GameObject? gameObject) {
    _gameObject = gameObject;
    if (_gameObject != null) {
      awake();
    }
  }
  
  /// Create a deep copy of this component
  Component clone();
}

/// Base class for all game objects in the scene, inspired by Unity's GameObject
class GameObject extends ChangeNotifier {
  // Core properties
  final String _id;
  String _name;
  String _tag;
  bool _isActive;
  int _layer;
  
  // Component system
  final List<Component> _components = [];
  
  // Transform component (every GameObject has one)
  final Transform _transform;
  
  // Scene reference
  Scene? _scene;
  
  // Getters
  String get id => _id;
  String get name => _name;
  String get tag => _tag;
  bool get isActive => _isActive;
  int get layer => _layer;
  Transform get transform => _transform;
  Scene? get scene => _scene;
  
  // Setters
  set name(String value) {
    if (_name != value) {
      _name = value;
      notifyListeners();
    }
  }
  
  set tag(String value) {
    if (_tag != value) {
      _tag = value;
      notifyListeners();
    }
  }
  
  set layer(int value) {
    if (_layer != value) {
      _layer = value;
      notifyListeners();
    }
  }
  
  // Constructor
  GameObject({
    required String id,
    required String name,
    String tag = 'Untagged',
    bool isActive = true,
    int layer = 0,
    Vector2? position,
    double rotation = 0.0,
    Vector2? scale,
  }) : _id = id,
       _name = name,
       _tag = tag,
       _isActive = isActive,
       _layer = layer,
       _transform = Transform(
         position: position,
         rotation: rotation,
         scale: scale,
       );
       
  // Set scene reference (internal use)
  set scene(Scene? value) {
    _scene = value;
  }
  
  /// Activate the game object
  void activate() {
    if (!_isActive) {
      _isActive = true;
      for (final component in _components) {
        if (component.enabled) {
          component.onEnable();
        }
      }
      notifyListeners();
    }
  }
  
  /// Deactivate the game object
  void deactivate() {
    if (_isActive) {
      _isActive = false;
      for (final component in _components) {
        if (component.enabled) {
          component.onDisable();
        }
      }
      notifyListeners();
    }
  }
  
  /// Add a component to the game object
  T addComponent<T extends Component>(T component) {
    _components.add(component);
    component._setGameObject(this);
    if (_isActive && component.enabled) {
      component.onEnable();
    }
    notifyListeners();
    return component;
  }
  
  /// Remove a component from the game object
  bool removeComponent(Component component) {
    if (_components.remove(component)) {
      if (_isActive && component.enabled) {
        component.onDisable();
      }
      component.onDestroy();
      component._setGameObject(null);
      notifyListeners();
      return true;
    }
    return false;
  }
  
  /// Get a component by type
  T? getComponent<T extends Component>() {
    for (final component in _components) {
      if (component is T) {
        return component as T;
      }
    }
    return null;
  }
  
  /// Get all components of a specific type
  List<T> getComponents<T extends Component>() {
    return _components.whereType<T>().toList();
  }
  
  /// Check if the game object has a specific component type
  bool hasComponent<T extends Component>() {
    return getComponent<T>() != null;
  }
  
  /// Update all components
  void update(double deltaTime) {
    if (!_isActive) return;
    
    for (final component in _components) {
      if (component.enabled) {
        component.update(deltaTime);
      }
    }
  }
  
  /// Late update (called after regular update)
  void lateUpdate(double deltaTime) {
    if (!_isActive) return;
    
    for (final component in _components) {
      if (component.enabled) {
        component.lateUpdate(deltaTime);
      }
    }
  }
  
  /// Render the game object and its components
  void render(Canvas canvas, double zoom) {
    if (!_isActive) return;
    
    final worldPos = _transform.worldPosition;
    final screenPos = Offset(worldPos.x, worldPos.y);
    
    // Let components render themselves
    for (final component in _components) {
      if (component.enabled) {
        component.onRender(canvas, screenPos, zoom);
      }
    }
  }
  
  /// Destroy the game object
  void destroy() {
    // Remove from scene
    _scene?.removeGameObject(this);
    
    // Clean up components
    for (final component in _components) {
      if (_isActive && component.enabled) {
        component.onDisable();
      }
      component.onDestroy();
      component._setGameObject(null);
    }
    _components.clear();
  }
  
  /// Create a deep copy of this game object
  GameObject clone() {
    final newObj = GameObject(
      id: '${_id}_clone',
      name: '${_name}_clone',
      tag: _tag,
      isActive: _isActive,
      layer: _layer,
    );
    
    // Clone transform
    newObj._transform.copyFrom(_transform);
    
    // Clone all components
    for (final component in _components) {
      final clonedComponent = component.clone();
      newObj.addComponent(clonedComponent);
    }
    
    return newObj;
  }
} 