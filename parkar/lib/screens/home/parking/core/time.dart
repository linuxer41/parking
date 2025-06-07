/// Manages time-related values for game updates
class Time {
  // Time since startup
  Duration _totalTime = Duration.zero;
  
  // Previous frame time
  Duration _lastFrameTime = Duration.zero;
  
  // Time between frames
  double _deltaTime = 0.0;
  
  // Time scale (for slow motion effects)
  double _timeScale = 1.0;
  
  // Frame counting
  int _frameCount = 0;
  Duration _fpsUpdateTime = Duration.zero;
  double _fps = 0.0;
  
  // Getters
  /// Total time since engine start in seconds
  double get time => _totalTime.inMicroseconds / 1000000.0;
  
  /// Time between frames in seconds (typically 0.016s for 60fps)
  double get deltaTime => _deltaTime * _timeScale;
  
  /// Unscaled delta time (not affected by timeScale)
  double get unscaledDeltaTime => _deltaTime;
  
  /// Time scale factor (1.0 is normal speed)
  double get timeScale => _timeScale;
  set timeScale(double value) => _timeScale = value.clamp(0.0, 10.0);
  
  /// Current frames per second
  double get fps => _fps;
  
  /// Current frame count since engine start
  int get frameCount => _frameCount;

  /// Update time values with the current timestamp
  void update(Duration currentTime) {
    // First frame special case
    if (_lastFrameTime == Duration.zero) {
      _lastFrameTime = currentTime;
      _fpsUpdateTime = currentTime;
      return;
    }
    
    // Update total time
    _totalTime = currentTime;
    
    // Calculate delta time in seconds
    final frameDuration = currentTime - _lastFrameTime;
    _deltaTime = frameDuration.inMicroseconds / 1000000.0;
    
    // Clamp delta time to reasonable values to prevent large jumps
    _deltaTime = _deltaTime.clamp(0.0, 0.2); // Max 200ms delta time
    
    // Update frame counter
    _frameCount++;
    
    // Update FPS calculation (every 0.5 seconds)
    final timeSinceFpsUpdate = currentTime - _fpsUpdateTime;
    if (timeSinceFpsUpdate.inMilliseconds >= 500) {
      _fps = (_frameCount * 1000) / timeSinceFpsUpdate.inMilliseconds;
      _fpsUpdateTime = currentTime;
      _frameCount = 0;
    }
    
    // Store current time for next frame
    _lastFrameTime = currentTime;
  }
  
  /// Reset time tracking
  void reset() {
    _totalTime = Duration.zero;
    _lastFrameTime = Duration.zero;
    _deltaTime = 0.0;
    _frameCount = 0;
    _fpsUpdateTime = Duration.zero;
    _fps = 0.0;
  }
} 