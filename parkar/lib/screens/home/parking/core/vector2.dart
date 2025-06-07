import 'dart:math' as math;

/// 2D Vector class for position, direction and velocity, inspired by Unity's Vector2
class Vector2 {
  double x;
  double y;

  // Constructors
  Vector2(this.x, this.y);
  Vector2.zero() : x = 0, y = 0;
  Vector2.one() : x = 1, y = 1;
  Vector2.up() : x = 0, y = -1;
  Vector2.down() : x = 0, y = 1;
  Vector2.left() : x = -1, y = 0;
  Vector2.right() : x = 1, y = 0;
  
  // Copy constructor
  Vector2.copy(Vector2 other) : x = other.x, y = other.y;

  /// Calculate the magnitude (length) of the vector
  double get magnitude => math.sqrt(x * x + y * y);
  
  /// Calculate the squared magnitude of the vector (more efficient when comparing distances)
  double get sqrMagnitude => x * x + y * y;

  /// Get a normalized version of this vector (same direction but length of 1)
  Vector2 get normalized {
    final mag = magnitude;
    if (mag > 1e-6) { // Avoid division by zero
      return Vector2(x / mag, y / mag);
    }
    return Vector2.zero();
  }
  
  /// Normalize this vector in place
  void normalize() {
    final mag = magnitude;
    if (mag > 1e-6) { // Avoid division by zero
      x /= mag;
      y /= mag;
    } else {
      x = 0;
      y = 0;
    }
  }

  /// Add another vector to this one
  Vector2 operator +(Vector2 other) => Vector2(x + other.x, y + other.y);

  /// Subtract another vector from this one
  Vector2 operator -(Vector2 other) => Vector2(x - other.x, y - other.y);

  /// Scale this vector by a scalar
  Vector2 operator *(double scalar) => Vector2(x * scalar, y * scalar);

  /// Divide this vector by a scalar
  Vector2 operator /(double scalar) {
    if (scalar == 0) {
      throw ArgumentError('Division by zero');
    }
    return Vector2(x / scalar, y / scalar);
  }

  /// Calculate the dot product with another vector
  double dot(Vector2 other) => x * other.x + y * other.y;

  /// Calculate the cross product with another vector (returns scalar in 2D)
  double cross(Vector2 other) => x * other.y - y * other.x;

  /// Calculate the distance to another vector
  double distanceTo(Vector2 other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Calculate the squared distance to another vector (more efficient)
  double sqrDistanceTo(Vector2 other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return dx * dx + dy * dy;
  }

  /// Linearly interpolate to another vector by t (0 to 1)
  Vector2 lerp(Vector2 other, double t) {
    final clampedT = t.clamp(0.0, 1.0);
    return Vector2(
      x + (other.x - x) * clampedT,
      y + (other.y - y) * clampedT,
    );
  }

  /// Reflect this vector off a surface with the given normal
  Vector2 reflect(Vector2 normal) {
    final n = normal.normalized;
    return this - n * (2 * dot(n));
  }

  /// Rotate this vector by an angle in radians
  Vector2 rotate(double radians) {
    final cos = math.cos(radians);
    final sin = math.sin(radians);
    return Vector2(
      x * cos - y * sin,
      x * sin + y * cos,
    );
  }
  
  /// Get the angle in radians of this vector (clockwise from up/north)
  double get angle => math.atan2(y, x);
  
  /// Snap this vector to a grid of the given size
  Vector2 snapToGrid(double gridSize) {
    return Vector2(
      (x / gridSize).round() * gridSize,
      (y / gridSize).round() * gridSize,
    );
  }

  @override
  String toString() => 'Vector2($x, $y)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vector2 && other.x == x && other.y == y;
  }
  
  @override
  int get hashCode => x.hashCode ^ y.hashCode;
  
  /// Create a vector from angle and magnitude
  static Vector2 fromAngle(double angle, [double magnitude = 1.0]) {
    return Vector2(
      math.cos(angle) * magnitude,
      math.sin(angle) * magnitude,
    );
  }
  
  /// Get a random vector with the given magnitude
  static Vector2 random([double magnitude = 1.0]) {
    final angle = math.Random().nextDouble() * math.pi * 2;
    return fromAngle(angle, magnitude);
  }
} 