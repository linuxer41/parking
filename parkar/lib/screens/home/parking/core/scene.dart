import 'package:flutter/foundation.dart';

import '../game_objects/game_object.dart';

/// Represents a scene containing game objects, similar to Unity's scene concept
class Scene extends ChangeNotifier {
  // Scene properties
  final String _name;
  final List<GameObject> _gameObjects = [];
  bool _isActive = true;
  
  // Getters
  String get name => _name;
  bool get isActive => _isActive;
  List<GameObject> get gameObjects => _gameObjects;
  
  // Constructor
  Scene({required String name}) : _name = name;
  
  /// Add a game object to the scene
  void addGameObject(GameObject gameObject) {
    _gameObjects.add(gameObject);
    gameObject.scene = this;
    notifyListeners();
  }
  
  /// Remove a game object from the scene
  void removeGameObject(GameObject gameObject) {
    if (_gameObjects.remove(gameObject)) {
      gameObject.scene = null;
      notifyListeners();
    }
  }
  
  /// Find a game object by its ID
  GameObject? findGameObjectById(String id) {
    try {
      return _gameObjects.firstWhere((obj) => obj.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Find game objects by tag
  List<GameObject> findGameObjectsByTag(String tag) {
    return _gameObjects.where((obj) => obj.tag == tag).toList();
  }
  
  /// Find game objects by type
  List<T> findGameObjectsByType<T extends GameObject>() {
    return _gameObjects.whereType<T>().toList();
  }
  
  /// Activate the scene
  void activate() {
    _isActive = true;
    notifyListeners();
  }
  
  /// Deactivate the scene
  void deactivate() {
    _isActive = false;
    notifyListeners();
  }
  
  /// Called by the engine when the scene updates
  void notifyUpdate() {
    notifyListeners();
  }
  
  /// Clear all game objects from the scene
  void clear() {
    for (final gameObject in _gameObjects) {
      gameObject.scene = null;
    }
    _gameObjects.clear();
    notifyListeners();
  }
  
  /// Create a deep copy of the scene
  Scene clone() {
    final newScene = Scene(name: '${_name}_copy');
    
    for (final gameObject in _gameObjects) {
      final clonedObject = gameObject.clone();
      newScene.addGameObject(clonedObject);
    }
    
    return newScene;
  }
} 