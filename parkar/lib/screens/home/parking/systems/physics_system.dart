import '../core/scene.dart';
import '../core/vector2.dart';
import '../game_objects/game_object.dart';
import '../game_objects/collider_component.dart';

/// System responsible for physics simulation including collision detection
class PhysicsSystem {
  // Physics settings
  bool _enabled = true;
  double _gravity = 0.0; // No gravity by default for top-down view
  double _collisionPrecision = 3;
  
  // Getters and setters
  bool get enabled => _enabled;
  set enabled(bool value) => _enabled = value;
  
  double get gravity => _gravity;
  set gravity(double value) => _gravity = value;
  
  /// Get all colliders in the scene
  List<ColliderComponent> _getSceneColliders(Scene scene) {
    final colliders = <ColliderComponent>[];
    
    for (final gameObject in scene.gameObjects) {
      if (!gameObject.isActive) continue;
      
      final objectColliders = gameObject.getComponents<ColliderComponent>();
      for (final collider in objectColliders) {
        if (collider.enabled) {
          colliders.add(collider);
        }
      }
    }
    
    return colliders;
  }
  
  /// Update physics simulation
  void update(Scene scene, double deltaTime) {
    if (!_enabled) return;
    
    final colliders = _getSceneColliders(scene);
    
    // Check for collisions
    _checkCollisions(colliders);
    
    // Apply gravity and other physics forces
    _applyPhysics(colliders, deltaTime);
  }
  
  /// Check for collisions between all colliders
  void _checkCollisions(List<ColliderComponent> colliders) {
    // Use spatial subdivision optimization for larger scenes
    if (colliders.length > 100) {
      _checkCollisionsWithSpatialHashing(colliders);
      return;
    }
    
    // Basic O(n²) collision check for smaller scenes
    for (int i = 0; i < colliders.length; i++) {
      final colliderA = colliders[i];
      
      for (int j = i + 1; j < colliders.length; j++) {
        final colliderB = colliders[j];
        
        // Check collision
        if (_detectCollision(colliderA, colliderB)) {
          // Handle the collision
          _handleCollision(colliderA, colliderB);
        }
      }
    }
  }
  
  /// Optimize collision detection with spatial hashing
  void _checkCollisionsWithSpatialHashing(List<ColliderComponent> colliders) {
    // Create a spatial hash grid (simplified implementation)
    const cellSize = 50.0;
    final grid = <String, List<ColliderComponent>>{};
    
    // Add colliders to spatial grid
    for (final collider in colliders) {
      final bounds = collider.bounds;
      final minX = (bounds.left / cellSize).floor();
      final minY = (bounds.top / cellSize).floor();
      final maxX = (bounds.right / cellSize).ceil();
      final maxY = (bounds.bottom / cellSize).ceil();
      
      // Add to relevant grid cells
      for (int x = minX; x <= maxX; x++) {
        for (int y = minY; y <= maxY; y++) {
          final key = '$x:$y';
          grid.putIfAbsent(key, () => []).add(collider);
        }
      }
    }
    
    // Check collisions only within the same grid cell
    for (final cellColliders in grid.values) {
      for (int i = 0; i < cellColliders.length; i++) {
        final colliderA = cellColliders[i];
        
        for (int j = i + 1; j < cellColliders.length; j++) {
          final colliderB = cellColliders[j];
          
          // Check collision
          if (_detectCollision(colliderA, colliderB)) {
            // Handle the collision
            _handleCollision(colliderA, colliderB);
          }
        }
      }
    }
  }
  
  /// Detect collision between two colliders using a simplified approach
  bool _detectCollision(ColliderComponent a, ColliderComponent b) {
    // Skip if either is disabled
    if (!a.enabled || !b.enabled) {
      return false;
    }
    
    // Get the bounds of each collider
    final boundsA = a.bounds;
    final boundsB = b.bounds;
    
    // Basic AABB (Axis-Aligned Bounding Box) collision check
    if (boundsA.overlaps(boundsB)) {
      // For circle colliders, do additional distance check
      if (a.shape == ColliderShape.circle && b.shape == ColliderShape.circle) {
        final posA = a.gameObject!.transform.worldPosition;
        final posB = b.gameObject!.transform.worldPosition;
        
        final distance = posA.distanceTo(posB);
        final minDistance = a.radius + b.radius;
        
        return distance <= minDistance;
      }
      
      return true; // Rectangles overlap
    }
    
    return false;
  }
  
  /// Handle collision between two colliders
  void _handleCollision(ColliderComponent a, ColliderComponent b) {
    // Notify colliders of collision
    a.onCollision(b);
    b.onCollision(a);
    
    // Apply collision response if neither is a trigger
    if (!a.isTrigger && !b.isTrigger) {
      _resolveCollision(a, b);
    }
  }
  
  /// Resolve the collision by adjusting positions
  void _resolveCollision(ColliderComponent a, ColliderComponent b) {
    // Only resolve for rigidbodies
    final rigidbodyA = a.gameObject?.getComponent<RigidbodyComponent>();
    final rigidbodyB = b.gameObject?.getComponent<RigidbodyComponent>();
    
    if (rigidbodyA == null && rigidbodyB == null) return;
    
    // Position correction
    final posA = a.gameObject!.transform.worldPosition;
    final posB = b.gameObject!.transform.worldPosition;
    
    // Calculate displacement direction
    final direction = posA - posB;
    direction.normalize();
    
    // Calculate penetration depth
    double penetration = 0.0;
    
    // For circles, simple penetration calculation
    if (a.shape == ColliderShape.circle && b.shape == ColliderShape.circle) {
      final distance = posA.distanceTo(posB);
      final minDistance = a.radius + b.radius;
      penetration = minDistance - distance;
    } else {
      // For rectangles, use a simplified approximation
      penetration = 5.0; // Fixed value for simplicity
    }
    
    // Apply correction based on mass
    if (rigidbodyA != null && rigidbodyB != null) {
      // Both are movable
      final totalMass = rigidbodyA.mass + rigidbodyB.mass;
      final ratio1 = rigidbodyB.mass / totalMass;
      final ratio2 = rigidbodyA.mass / totalMass;
      
      // Move objects away from each other
      if (!rigidbodyA.isKinematic) {
        rigidbodyA.gameObject!.transform.translate(direction * (penetration * ratio1));
      }
      
      if (!rigidbodyB.isKinematic) {
        rigidbodyB.gameObject!.transform.translate(direction * (-penetration * ratio2));
      }
    } else if (rigidbodyA != null && !rigidbodyA.isKinematic) {
      // Only A is movable
      rigidbodyA.gameObject!.transform.translate(direction * penetration);
    } else if (rigidbodyB != null && !rigidbodyB.isKinematic) {
      // Only B is movable
      rigidbodyB.gameObject!.transform.translate(direction * -penetration);
    }
  }
  
  /// Apply physics forces like gravity
  void _applyPhysics(List<ColliderComponent> colliders, double deltaTime) {
    if (_gravity == 0) return; // Skip if no gravity
    
    for (final collider in colliders) {
      final rigidbody = collider.gameObject?.getComponent<RigidbodyComponent>();
      if (rigidbody != null && !rigidbody.isKinematic) {
        // Apply gravity
        rigidbody.velocity.y += _gravity * deltaTime;
        
        // Apply velocity to position
        if (rigidbody.velocity.x != 0 || rigidbody.velocity.y != 0) {
          final delta = rigidbody.velocity * deltaTime;
          collider.gameObject!.transform.translate(delta);
        }
        
        // Apply drag
        if (rigidbody.drag > 0) {
          final dragFactor = 1.0 - (rigidbody.drag * deltaTime).clamp(0.0, 1.0);
          rigidbody.velocity.x *= dragFactor;
          rigidbody.velocity.y *= dragFactor;
        }
      }
    }
  }
}

/// Collider shapes
enum ColliderShape {
  box,
  circle
}

/// Rigidbody component for physics simulation
class RigidbodyComponent extends Component {
  Vector2 velocity = Vector2.zero();
  double mass = 1.0;
  double drag = 0.0;
  bool isKinematic = false;
  
  RigidbodyComponent({
    this.mass = 1.0,
    this.drag = 0.05,
    this.isKinematic = false,
    Vector2? initialVelocity,
  }) {
    if (initialVelocity != null) {
      velocity = Vector2.copy(initialVelocity);
    }
  }
  
  @override
  void update(double deltaTime) {
    // Physics system handles the actual movement
  }
  
  /// Add force to the rigidbody
  void addForce(Vector2 force) {
    if (!isKinematic) {
      velocity = velocity + (force / mass);
    }
  }
  
  /// Set velocity directly
  void setVelocity(Vector2 newVelocity) {
    velocity = Vector2.copy(newVelocity);
  }
  
  @override
  Component clone() {
    return RigidbodyComponent(
      mass: mass,
      drag: drag,
      isKinematic: isKinematic,
      initialVelocity: Vector2.copy(velocity),
    );
  }
} 