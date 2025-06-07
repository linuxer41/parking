import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import 'vector2.dart';

/// Represents transformation data (position, rotation, scale) for a game object
class Transform extends ChangeNotifier {
  // Properties
  Vector2 _position;
  double _rotation; // in radians
  Vector2 _scale;
  
  // Parent-child relationship
  Transform? _parent;
  final List<Transform> _children = [];
  
  // Change tracking
  bool _hasChanged = true;
  
  // Cache for local to world matrix
  Matrix4? _localToWorldMatrix;
  bool _matrixDirty = true;
  
  // Previous state values for detecting changes
  late Vector2 _previousPosition;
  late double _previousRotation;
  late Vector2 _previousScale;
  
  // Getters and setters
  Vector2 get position => _position;
  set position(Vector2 value) {
    if (_position != value) {
      _position = Vector2.copy(value);
      _markChanged();
    }
  }
  
  double get rotation => _rotation;
  set rotation(double value) {
    if (_rotation != value) {
      _rotation = value;
      _markChanged();
    }
  }
  
  Vector2 get scale => _scale;
  set scale(Vector2 value) {
    if (_scale != value) {
      _scale = Vector2.copy(value);
      _markChanged();
    }
  }
  
  Transform? get parent => _parent;
  List<Transform> get children => List.unmodifiable(_children);
  bool get hasChanged => _hasChanged;
  
  // World space values
  Vector2 get worldPosition => _parent != null 
      ? _calculateWorldPosition() 
      : _position;
      
  double get worldRotation => _parent != null
      ? _calculateWorldRotation()
      : _rotation;
      
  Vector2 get worldScale => _parent != null
      ? _calculateWorldScale()
      : _scale;
      
  // Constructor
  Transform({
    Vector2? position,
    double rotation = 0.0,
    Vector2? scale,
  }) : _position = position ?? Vector2.zero(),
       _rotation = rotation,
       _scale = scale ?? Vector2.one() {
    _previousPosition = Vector2.copy(_position);
    _previousRotation = _rotation;
    _previousScale = Vector2.copy(_scale);
  }
  
  /// Set the parent transform
  void setParent(Transform? newParent) {
    // Remove from old parent if exists
    _parent?._children.remove(this);
    
    _parent = newParent;
    
    // Add to new parent if exists
    _parent?._children.add(this);
    
    _markChanged();
  }
  
  /// Add a child transform
  void addChild(Transform child) {
    if (!_children.contains(child)) {
      _children.add(child);
      child._parent = this;
      child._markChanged();
    }
  }
  
  /// Remove a child transform
  void removeChild(Transform child) {
    if (_children.remove(child)) {
      child._parent = null;
      child._markChanged();
    }
  }
  
  /// Set the position in world space
  void setWorldPosition(Vector2 worldPosition) {
    if (_parent != null) {
      // Convert world position to local
      final parentWorldToLocalMatrix = _parent!._getWorldToLocalMatrix();
      final localPos = _applyMatrixToPoint(parentWorldToLocalMatrix, worldPosition);
      position = localPos;
    } else {
      position = worldPosition;
    }
  }
  
  /// Set the rotation in world space
  void setWorldRotation(double worldRotation) {
    if (_parent != null) {
      // Subtract parent world rotation to get local
      _rotation = worldRotation - _parent!.worldRotation;
      _markChanged();
    } else {
      rotation = worldRotation;
    }
  }
  
  /// Set the scale in world space
  void setWorldScale(Vector2 worldScale) {
    if (_parent != null) {
      // Divide by parent world scale to get local
      final parentWorldScale = _parent!.worldScale;
      _scale = Vector2(
        worldScale.x / parentWorldScale.x,
        worldScale.y / parentWorldScale.y,
      );
      _markChanged();
    } else {
      scale = worldScale;
    }
  }
  
  /// Translate the transform by an offset
  void translate(Vector2 offset) {
    position = _position + offset;
  }
  
  /// Rotate the transform by an angle in radians
  void rotate(double angle) {
    rotation = _rotation + angle;
  }
  
  /// Scale the transform by a factor
  void scaleBy(Vector2 factor) {
    _scale = Vector2(_scale.x * factor.x, _scale.y * factor.y);
    _markChanged();
  }
  
  /// Get the forward direction vector
  Vector2 get forward {
    return Vector2(math.cos(_rotation), math.sin(_rotation));
  }
  
  /// Get the right direction vector
  Vector2 get right {
    return Vector2(-math.sin(_rotation), math.cos(_rotation));
  }
  
  /// Reset the transform to default values
  void reset() {
    _position = Vector2.zero();
    _rotation = 0.0;
    _scale = Vector2.one();
    _markChanged();
  }
  
  /// Mark the transform as changed
  void _markChanged() {
    _hasChanged = true;
    _matrixDirty = true;
    
    // Mark all children as changed
    for (final child in _children) {
      child._markChanged();
    }
    
    notifyListeners();
  }
  
  /// Calculate the world position
  Vector2 _calculateWorldPosition() {
    if (_parent == null) return _position;
    
    final parentRotation = _parent!.worldRotation;
    final parentPos = _parent!.worldPosition;
    final parentScale = _parent!.worldScale;
    
    // First scale, then rotate, then translate
    final scaledX = _position.x * parentScale.x;
    final scaledY = _position.y * parentScale.y;
    
    // Rotate around parent
    final cos = math.cos(parentRotation);
    final sin = math.sin(parentRotation);
    final rotatedX = cos * scaledX - sin * scaledY;
    final rotatedY = sin * scaledX + cos * scaledY;
    
    // Translate by parent position
    return Vector2(
      parentPos.x + rotatedX,
      parentPos.y + rotatedY,
    );
  }
  
  /// Calculate the world rotation
  double _calculateWorldRotation() {
    if (_parent == null) return _rotation;
    
    // Add parent rotation to get world rotation
    return _parent!.worldRotation + _rotation;
  }
  
  /// Calculate the world scale
  Vector2 _calculateWorldScale() {
    if (_parent == null) return _scale;
    
    // Multiply by parent scale to get world scale
    final parentScale = _parent!.worldScale;
    return Vector2(
      _scale.x * parentScale.x,
      _scale.y * parentScale.y,
    );
  }
  
  /// Get the local to world transformation matrix
  Matrix4 getLocalToWorldMatrix() {
    if (!_matrixDirty && _localToWorldMatrix != null) {
      return _localToWorldMatrix!;
    }
    
    // Calculate matrix
    // Order: scale, then rotate, then translate
    final worldPos = worldPosition;
    final worldRot = worldRotation;
    final worldSca = worldScale;
    
    // Create transformation matrix
    _localToWorldMatrix = Matrix4.identity()
      ..translate(worldPos.x, worldPos.y)
      ..rotateZ(worldRot)
      ..scale(worldSca.x, worldSca.y);
    
    _matrixDirty = false;
    return _localToWorldMatrix!;
  }
  
  /// Get the world to local transformation matrix
  Matrix4 _getWorldToLocalMatrix() {
    // Invert the local to world matrix
    return Matrix4.inverted(getLocalToWorldMatrix());
  }
  
  /// Apply matrix to a point
  Vector2 _applyMatrixToPoint(Matrix4 matrix, Vector2 point) {
    // Create homogeneous coordinates
    final vec = Vector3(point.x, point.y, 1);
    
    // Apply matrix transformation
    final transformed = matrix.transform3(vec);
    
    // Return to 2D space
    return Vector2(transformed.x, transformed.y);
  }
  
  /// Mark that all transformations have been applied
  void clearChanged() {
    _hasChanged = false;
    _previousPosition = Vector2.copy(_position);
    _previousRotation = _rotation;
    _previousScale = Vector2.copy(_scale);
  }
  
  /// Copy transforms from another transform
  void copyFrom(Transform other) {
    _position = Vector2.copy(other._position);
    _rotation = other._rotation;
    _scale = Vector2.copy(other._scale);
    _markChanged();
  }
  
  /// Create a deep copy of this transform (without parents/children)
  Transform clone() {
    return Transform(
      position: Vector2.copy(_position),
      rotation: _rotation,
      scale: Vector2.copy(_scale),
    );
  }
}

// Vector3 helper class
class Vector3 {
  final double x;
  final double y;
  final double z;
  
  Vector3(this.x, this.y, this.z);
  
  @override
  String toString() => 'Vector3($x, $y, $z)';
}

// Matrix4 helper class
class Matrix4 {
  final List<double> values;
  
  Matrix4(this.values);
  
  static Matrix4 identity() {
    return Matrix4([
      1, 0, 0, 0,
      0, 1, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1,
    ]);
  }
  
  Matrix4 translate(double x, double y) {
    final m = List<double>.from(values);
    m[12] += x;
    m[13] += y;
    return Matrix4(m);
  }
  
  Matrix4 rotateZ(double radians) {
    final c = math.cos(radians);
    final s = math.sin(radians);
    final m = List<double>.from(values);
    
    final m00 = m[0] * c + m[4] * s;
    final m01 = m[1] * c + m[5] * s;
    final m02 = m[2] * c + m[6] * s;
    final m03 = m[3] * c + m[7] * s;
    
    final m10 = m[0] * -s + m[4] * c;
    final m11 = m[1] * -s + m[5] * c;
    final m12 = m[2] * -s + m[6] * c;
    final m13 = m[3] * -s + m[7] * c;
    
    m[0] = m00;
    m[1] = m01;
    m[2] = m02;
    m[3] = m03;
    
    m[4] = m10;
    m[5] = m11;
    m[6] = m12;
    m[7] = m13;
    
    return Matrix4(m);
  }
  
  Matrix4 scale(double x, double y) {
    final m = List<double>.from(values);
    m[0] *= x;
    m[1] *= x;
    m[2] *= x;
    m[3] *= x;
    
    m[4] *= y;
    m[5] *= y;
    m[6] *= y;
    m[7] *= y;
    
    return Matrix4(m);
  }
  
  Vector3 transform3(Vector3 vector) {
    final x = vector.x * values[0] + vector.y * values[4] + vector.z * values[8] + values[12];
    final y = vector.x * values[1] + vector.y * values[5] + vector.z * values[9] + values[13];
    final z = vector.x * values[2] + vector.y * values[6] + vector.z * values[10] + values[14];
    
    return Vector3(x, y, z);
  }
  
  static Matrix4 inverted(Matrix4 matrix) {
    // Simple 2D inversion for our purposes
    // For a full 4x4 inversion, more complex math would be needed
    final m = matrix.values;
    
    // Extract components from the original matrix
    final a = m[0];  // scale x
    final b = m[4];  // rotation
    final c = m[1];  // rotation
    final d = m[5];  // scale y
    final tx = m[12]; // translation x
    final ty = m[13]; // translation y
    
    // Calculate determinant
    final det = a * d - b * c;
    if (det == 0) {
      return Matrix4.identity(); // Cannot invert
    }
    
    // Calculate inverse
    final invDet = 1.0 / det;
    
    final result = Matrix4.identity();
    final r = result.values;
    
    r[0] = d * invDet;
    r[1] = -c * invDet;
    r[4] = -b * invDet;
    r[5] = a * invDet;
    
    // Calculate new translation
    r[12] = (b * ty - d * tx) * invDet;
    r[13] = (c * tx - a * ty) * invDet;
    
    return result;
  }
} 