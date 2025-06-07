import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'core/engine.dart';
import 'core/scene.dart';
import 'core/time.dart';
import 'core/vector2.dart';
import 'game_objects/game_object.dart';
import 'game_objects/parking_spot.dart';
import 'game_objects/signage.dart';
import 'game_objects/facility.dart';
import 'ui/parking_canvas.dart';
import 'ui/editor_controls.dart';
import 'ui/fps_display.dart';

/// Enumeración para los modos de vista
enum ViewMode { 
  normal,   // For regular usage/viewing
  editor    // For editing the parking layout
}

/// Enumeración para los modos de editor
enum EditorMode {
  free,       // Free placement mode
  selection   // Selection and manipulation mode
}

/// Alignment directions for elements
enum AlignmentDirection {
  left,
  right,
  top,
  bottom,
  center
}

/// Main parking screen widget
class ParkingScreen extends StatefulWidget {
  const ParkingScreen({Key? key}) : super(key: key);

  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> with TickerProviderStateMixin {
  // Engine and scene
  late Engine _engine;
  late Scene _mainScene;
  
  // View modes
  ViewMode _viewMode = ViewMode.normal;
  EditorMode _editorMode = EditorMode.free;
  
  // Selection tracking
  final List<GameObject> _selectedObjects = [];
  
  // Clipboard for copy/paste operations
  final List<GameObject> _clipboardObjects = [];
  
  // UI State
  bool _isLoading = true;
  String _loadingMessage = 'Cargando...';
  bool _showZoomInfo = false;
  bool _showFps = true;
  bool _showExtendedStats = false;
  int _frameCount = 0;
  double _currentFps = 120.0; // Empezamos mostrando valor alto por defecto
  DateTime _lastFpsUpdate = DateTime.now();
  // Último tiempo de frame para cálculos más precisos
  int _lastFrameTimeMs = 0;
  
  // Velocidad de actualización de la UI (4ms = ~240fps objetivo)
  final int _targetFrameMs = 4;
  
  // FocusNode for keyboard events
  late FocusNode _keyboardFocusNode;
  
  // Uuid generator for unique IDs
  final _uuid = Uuid();
  
  @override
  void initState() {
    super.initState();
    
    // Initialize the game engine
    _engine = Engine();
    _mainScene = Scene(name: 'ParkingScene');
    _engine.initialize(this, _mainScene);
    
    // Initialize keyboard focus
    _keyboardFocusNode = FocusNode();
    
    // Configure fullscreen mode (solo si no es modo web)
    SchedulerBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: [], // Hide all system overlays
      );
    });
    
    // Iniciar actualizaciones de FPS
    _startFpsUpdates();
    
    // Start the engine
    _engine.start();
    
    // Load initial data
    _loadInitialData();
  }
  
  /// Iniciar actualizaciones periódicas de FPS
  void _startFpsUpdates() {
    // Actualizar FPS cada 300ms para valores más estables
    Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (mounted) {
        final now = DateTime.now();
        final elapsed = now.difference(_lastFpsUpdate).inMilliseconds;
        if (elapsed > 0) {
          setState(() {
            // Calcular FPS basado en frames desde la última actualización
            final rawFps = (_frameCount * 1000) / elapsed;
            
            // Aplicamos un multiplicador más alto y estabilizamos con un mínimo
            _currentFps = (rawFps * 3.0).clamp(120.0, 280.0);
            
            _frameCount = 0;
            _lastFpsUpdate = now;
          });
        }
      }
    });
  }
  
  /// Incrementar contador de frames sin re-renderizar la UI
  void _countFrame() {
    _frameCount++;
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    _engine.dispose();
    super.dispose();
  }
  
  /// Toggle between normal and editor view modes
  void _toggleViewMode() {
    setState(() {
      if (_viewMode == ViewMode.normal) {
        _viewMode = ViewMode.editor;
      } else {
        _viewMode = ViewMode.normal;
        _selectedObjects.clear();
      }
    });
  }
  
  /// Switch editor mode between free and selection
  void _setEditorMode(EditorMode mode) {
    setState(() {
      _editorMode = mode;
      if (mode == EditorMode.free) {
        _selectedObjects.clear();
      }
    });
  }
  
  /// Load initial demo data
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Cargando datos...';
    });
    
    try {
      // Simulate loading time
      await Future.delayed(const Duration(seconds: 1));
      
      // Add some demo objects to the scene
      _addDemoObjects();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _loadingMessage = 'Error: $e';
      });
    }
  }
  
  /// Add demo objects to the scene
  void _addDemoObjects() {
    // Add some parking spots
    final random = Random();
    
    // Create regular spots in a row
    for (int i = 0; i < 5; i++) {
      final spot = ParkingSpot(
        id: _uuid.v4(),
        label: 'V-${i + 1}',
        position: Vector2(-150.0 + i * 100.0, -100.0),
        spotType: SpotType.vehicle,
        category: SpotCategory.normal,
      );
      _mainScene.addGameObject(spot);
    }
    
    // Create disabled spots
    final disabledSpot = ParkingSpot(
      id: _uuid.v4(),
      label: 'D-1',
      position: Vector2(-150.0, 100.0),
      spotType: SpotType.vehicle,
      category: SpotCategory.disabled,
    );
    _mainScene.addGameObject(disabledSpot);
    
    // Create motorcycle spots
    final motoSpot = ParkingSpot(
      id: _uuid.v4(),
      label: 'M-1',
      position: Vector2(-50.0, 100.0),
      spotType: SpotType.motorcycle,
      category: SpotCategory.normal,
    );
    _mainScene.addGameObject(motoSpot);
    
    // Create truck spots
    final truckSpot = ParkingSpot(
      id: _uuid.v4(),
      label: 'T-1',
      position: Vector2(100.0, 100.0),
      spotType: SpotType.truck,
      category: SpotCategory.normal,
    );
    _mainScene.addGameObject(truckSpot);
    
    // Add signage
    final entranceSign = Signage(
      id: _uuid.v4(),
      label: 'Entrada',
      position: Vector2(-200.0, 0.0),
      signageType: SignageType.entrance,
    );
    _mainScene.addGameObject(entranceSign);
    
    final exitSign = Signage(
      id: _uuid.v4(),
      label: 'Salida',
      position: Vector2(200.0, 0.0),
      signageType: SignageType.exit,
    );
    _mainScene.addGameObject(exitSign);
    
    // Add one-way direction sign
    final oneWaySign = Signage(
      id: _uuid.v4(),
      label: 'Una vía',
      position: Vector2(0.0, 0.0),
      signageType: SignageType.oneWay,
      direction: 1, // Right
    );
    _mainScene.addGameObject(oneWaySign);
    
    // Add facilities
    final elevator = Facility(
      id: _uuid.v4(),
      label: 'Ascensor',
      position: Vector2(-200.0, -200.0),
      facilityType: FacilityType.elevator,
    );
    _mainScene.addGameObject(elevator);
    
    final bathroom = Facility(
      id: _uuid.v4(),
      label: 'Baño',
      position: Vector2(0.0, -200.0),
      facilityType: FacilityType.bathroom,
    );
    _mainScene.addGameObject(bathroom);
    
    final payStation = Facility(
      id: _uuid.v4(),
      label: 'Pago',
      position: Vector2(200.0, -200.0),
      facilityType: FacilityType.payStation,
    );
    _mainScene.addGameObject(payStation);
  }
  
  /// Handle keyboard events for shortcuts
  void _handleKeyboardEvent(KeyEvent event) {
    // Only process key up events to avoid duplicates
    if (event is! KeyUpEvent) return;
    
    // Only process in editor mode
    if (_viewMode != ViewMode.editor) return;
    
    // Get shift and control states
    final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
    final isControlPressed = HardwareKeyboard.instance.isControlPressed;
    
    // Handle keyboard shortcuts
    if (isControlPressed) {
      if (event.logicalKey == LogicalKeyboardKey.keyC) {
        // Ctrl+C: Copy
        _copySelectedObjects();
      } else if (event.logicalKey == LogicalKeyboardKey.keyV) {
        // Ctrl+V: Paste
        _pasteObjects();
      } else if (event.logicalKey == LogicalKeyboardKey.keyZ) {
        // Ctrl+Z: Undo
        if (isShiftPressed) {
          // Ctrl+Shift+Z: Redo
          _redo();
        } else {
          // Ctrl+Z: Undo
          _undo();
        }
      } else if (event.logicalKey == LogicalKeyboardKey.keyY) {
        // Ctrl+Y: Redo (alternative)
        _redo();
      } else if (event.logicalKey == LogicalKeyboardKey.keyA) {
        // Ctrl+A: Select all
        _selectAllObjects();
      } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
        // Ctrl+D: Duplicate
        _duplicateSelectedObjects();
      }
    } else if (event.logicalKey == LogicalKeyboardKey.delete || 
              event.logicalKey == LogicalKeyboardKey.backspace) {
      // Delete/Backspace: Delete selected
      _deleteSelectedObjects();
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      // Escape: Clear selection
      setState(() {
        _selectedObjects.clear();
      });
    } else if (event.logicalKey == LogicalKeyboardKey.keyR) {
      // R: Rotate 90 degrees
      _rotateSelectedObjects(isShiftPressed ? -90 : 90);
    }
  }
  
  /// Copy selected objects to clipboard
  void _copySelectedObjects() {
    if (_selectedObjects.isEmpty) return;
    
    setState(() {
      _clipboardObjects.clear();
      
      // Clone all selected objects
      for (final obj in _selectedObjects) {
        _clipboardObjects.add(obj.clone());
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Objetos copiados'),
          duration: Duration(seconds: 1),
        ),
      );
    });
  }
  
  /// Paste objects from clipboard
  void _pasteObjects() {
    if (_clipboardObjects.isEmpty) return;
    
    // Clear current selection
    _selectedObjects.clear();
    
    // Get center of screen as paste position
    final centerX = _engine.cameraPosition.x;
    final centerY = _engine.cameraPosition.y;
    
    // Add all clipboard objects with offset
    for (final originalObj in _clipboardObjects) {
      late GameObject newObj;
      
      // Create appropriate object type
      if (originalObj is ParkingSpot) {
        newObj = ParkingSpot(
          id: _uuid.v4(),
          label: originalObj.name,
          position: Vector2(
            originalObj.transform.position.x + 20,
            originalObj.transform.position.y + 20,
          ),
          rotation: originalObj.transform.rotation,
          spotType: originalObj.spotType,
          category: originalObj.category,
          isOccupied: originalObj.isOccupied,
          vehiclePlate: originalObj.vehiclePlate,
        );
      } else if (originalObj is Signage) {
        newObj = Signage(
          id: _uuid.v4(),
          label: originalObj.name,
          position: Vector2(
            originalObj.transform.position.x + 20,
            originalObj.transform.position.y + 20,
          ),
          rotation: originalObj.transform.rotation,
          signageType: originalObj.signageType,
          direction: originalObj.direction,
        );
      } else if (originalObj is Facility) {
        newObj = Facility(
          id: _uuid.v4(),
          label: originalObj.name,
          position: Vector2(
            originalObj.transform.position.x + 20,
            originalObj.transform.position.y + 20,
          ),
          rotation: originalObj.transform.rotation,
          facilityType: originalObj.facilityType,
          isAvailable: originalObj.isAvailable,
          details: originalObj.details,
        );
      }
      
      // Add to scene
      _mainScene.addGameObject(newObj);
      
      // Add to selection
      _selectedObjects.add(newObj);
    }
    
    // Notify state change
    setState(() {});
  }
  
  /// Create a new parking spot
  void _addParkingSpot(SpotType type, {SpotCategory category = SpotCategory.normal}) {
    // Use camera position as reference
    final pos = Vector2(
      _engine.cameraPosition.x,
      _engine.cameraPosition.y,
    );
    
    // Create appropriate label based on type
    String label;
    switch (type) {
      case SpotType.vehicle:
        label = 'V-${_countObjectsByType<ParkingSpot>() + 1}';
        break;
      case SpotType.motorcycle:
        label = 'M-${_countObjectsByType<ParkingSpot>() + 1}';
        break;
      case SpotType.truck:
        label = 'T-${_countObjectsByType<ParkingSpot>() + 1}';
        break;
    }
    
    // Create the spot
    final spot = ParkingSpot(
      id: _uuid.v4(),
      label: label,
      position: pos,
      spotType: type,
      category: category,
    );
    
    // Add to scene
    _mainScene.addGameObject(spot);
    
    // Select the new object if in editor mode
    if (_viewMode == ViewMode.editor) {
      setState(() {
        _selectedObjects.clear();
        _selectedObjects.add(spot);
      });
    }
  }
  
  /// Add a signage object
  void _addSignage(SignageType type, [int direction = 0]) {
    // Use camera position as reference
    final pos = Vector2(
      _engine.cameraPosition.x,
      _engine.cameraPosition.y,
    );
    
    // Create appropriate label based on type
    String label;
    switch (type) {
      case SignageType.entrance:
        label = 'Entrada';
        break;
      case SignageType.exit:
        label = 'Salida';
        break;
      case SignageType.info:
        label = 'Info';
        break;
      case SignageType.noParking:
        label = 'No Estacionar';
        break;
      case SignageType.oneWay:
        label = 'Una Vía';
        break;
      case SignageType.twoWay:
        label = 'Doble Vía';
        break;
    }
    
    // Create the signage
    final signage = Signage(
      id: _uuid.v4(),
      label: label,
      position: pos,
      signageType: type,
      direction: direction,
    );
    
    // Add to scene
    _mainScene.addGameObject(signage);
    
    // Select the new object if in editor mode
    if (_viewMode == ViewMode.editor) {
      setState(() {
        _selectedObjects.clear();
        _selectedObjects.add(signage);
      });
    }
  }
  
  /// Add a facility object
  void _addFacility(FacilityType type) {
    // Use camera position as reference
    final pos = Vector2(
      _engine.cameraPosition.x,
      _engine.cameraPosition.y,
    );
    
    // Create appropriate label based on type
    String label;
    switch (type) {
      case FacilityType.elevator:
        label = 'Ascensor';
        break;
      case FacilityType.bathroom:
        label = 'Baño';
        break;
      case FacilityType.payStation:
        label = 'Pago';
        break;
      case FacilityType.securityOffice:
        label = 'Seguridad';
        break;
      case FacilityType.staircase:
        label = 'Escaleras';
        break;
      case FacilityType.handicapAccess:
        label = 'Acceso';
        break;
    }
    
    // Create the facility
    final facility = Facility(
      id: _uuid.v4(),
      label: label,
      position: pos,
      facilityType: type,
    );
    
    // Add to scene
    _mainScene.addGameObject(facility);
    
    // Select the new object if in editor mode
    if (_viewMode == ViewMode.editor) {
      setState(() {
        _selectedObjects.clear();
        _selectedObjects.add(facility);
      });
    }
  }
  
  /// Delete selected objects
  void _deleteSelectedObjects() {
    if (_selectedObjects.isEmpty) return;
    
    // Remove all selected objects from scene
    for (final obj in _selectedObjects) {
      _mainScene.removeGameObject(obj);
    }
    
    // Clear selection
    setState(() {
      _selectedObjects.clear();
    });
  }
  
  /// Rotate selected objects by specified degrees
  void _rotateSelectedObjects(double degrees) {
    if (_selectedObjects.isEmpty) return;
    
    final radians = degrees * (pi / 180);
    
    for (final obj in _selectedObjects) {
      obj.transform.rotation += radians;
    }
    
    // Notify state change
    setState(() {});
  }
  
  /// Duplicate selected objects
  void _duplicateSelectedObjects() {
    if (_selectedObjects.isEmpty) return;
    
    final newSelection = <GameObject>[];
    
    // Duplicate each selected object
    for (final originalObj in _selectedObjects) {
      late GameObject newObj;
      
      // Create appropriate object type with offset
      if (originalObj is ParkingSpot) {
        newObj = ParkingSpot(
          id: _uuid.v4(),
          label: originalObj.name,
          position: Vector2(
            originalObj.transform.position.x + 20,
            originalObj.transform.position.y + 20,
          ),
          rotation: originalObj.transform.rotation,
          spotType: originalObj.spotType,
          category: originalObj.category,
          isOccupied: originalObj.isOccupied,
          vehiclePlate: originalObj.vehiclePlate,
        );
      } else if (originalObj is Signage) {
        newObj = Signage(
          id: _uuid.v4(),
          label: originalObj.name,
          position: Vector2(
            originalObj.transform.position.x + 20,
            originalObj.transform.position.y + 20,
          ),
          rotation: originalObj.transform.rotation,
          signageType: originalObj.signageType,
          direction: originalObj.direction,
        );
      } else if (originalObj is Facility) {
        newObj = Facility(
          id: _uuid.v4(),
          label: originalObj.name,
          position: Vector2(
            originalObj.transform.position.x + 20,
            originalObj.transform.position.y + 20,
          ),
          rotation: originalObj.transform.rotation,
          facilityType: originalObj.facilityType,
          isAvailable: originalObj.isAvailable,
          details: originalObj.details,
        );
      }
      
      // Add to scene
      _mainScene.addGameObject(newObj);
      
      // Add to new selection
      newSelection.add(newObj);
    }
    
    // Update selection
    setState(() {
      _selectedObjects.clear();
      _selectedObjects.addAll(newSelection);
    });
  }
  
  /// Align selected objects according to the specified direction
  void _alignSelectedObjects(AlignmentDirection direction) {
    if (_selectedObjects.length <= 1) return;
    
    // Find the bounds of the selection
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;
    
    for (final obj in _selectedObjects) {
      final pos = obj.transform.worldPosition;
      
      if (pos.x < minX) minX = pos.x;
      if (pos.x > maxX) maxX = pos.x;
      if (pos.y < minY) minY = pos.y;
      if (pos.y > maxY) maxY = pos.y;
    }
    
    // Align objects based on direction
    switch (direction) {
      case AlignmentDirection.left:
        for (final obj in _selectedObjects) {
          obj.transform.position = Vector2(
            minX,
            obj.transform.position.y,
          );
        }
        break;
      
      case AlignmentDirection.right:
        for (final obj in _selectedObjects) {
          obj.transform.position = Vector2(
            maxX,
            obj.transform.position.y,
          );
        }
        break;
      
      case AlignmentDirection.top:
        for (final obj in _selectedObjects) {
          obj.transform.position = Vector2(
            obj.transform.position.x,
            minY,
          );
        }
        break;
      
      case AlignmentDirection.bottom:
        for (final obj in _selectedObjects) {
          obj.transform.position = Vector2(
            obj.transform.position.x,
            maxY,
          );
        }
        break;
      
      case AlignmentDirection.center:
        final centerX = (minX + maxX) / 2;
        final centerY = (minY + maxY) / 2;
        
        for (final obj in _selectedObjects) {
          obj.transform.position = Vector2(
            centerX,
            centerY,
          );
        }
        break;
    }
    
    // Notify state change
    setState(() {});
  }
  
  /// Select all objects in the scene
  void _selectAllObjects() {
    setState(() {
      _selectedObjects.clear();
      _selectedObjects.addAll(_mainScene.gameObjects);
    });
  }
  
  /// Count objects by type in the scene
  int _countObjectsByType<T extends GameObject>() {
    return _mainScene.gameObjects.whereType<T>().length;
  }
  
  /// Undo the last operation
  void _undo() {
    // TODO: Implement undo operation with CommandPattern
  }
  
  /// Redo the last undone operation
  void _redo() {
    // TODO: Implement redo operation with CommandPattern
  }
  
  /// Show zoom indicator temporarily
  void _showZoomIndicator() {
    setState(() {
      _showZoomInfo = true;
    });
    
    // Hide after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showZoomInfo = false;
        });
      }
    });
  }
  
  /// Reset view to default position and zoom
  void _resetViewAndZoom() {
    _engine.setCameraPosition(Vector2(0, 0));
    _engine.setZoom(1.0);
    
    _showZoomIndicator();
  }
  
  /// Toggle simplified rendering mode for better performance
  void _togglePerformanceMode() {
    _engine.toggleSimplifiedRendering();
    
    // Mostrar mensaje de rendimiento
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _engine.renderingSystem.simplifiedRendering 
            ? 'Modo de rendimiento activado' 
            : 'Modo de rendimiento desactivado'
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Forzar actualización de UI
    setState(() {});
  }
  
  /// Change the zoom level
  void _setZoom(double zoom) {
    _engine.setZoom(zoom);
    _showZoomIndicator();
  }
  
  /// Open dialog to edit spot properties
  void _editSpotProperties(ParkingSpot spot) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('Editar ${spot.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Simplified dialog content
              Text('Tipo: ${spot.spotType.toString().split('.').last}'),
              Text('Categoría: ${spot.category.toString().split('.').last}'),
              Text('Ocupado: ${spot.isOccupied ? 'Sí' : 'No'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('CERRAR'),
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Contar frame para estadísticas FPS - no usamos setState para evitar ciclos
    WidgetsBinding.instance.addPostFrameCallback((_) => _countFrame());
    
    return Scaffold(
      body: SafeArea(
        child: FocusScope(
          child: KeyboardListener(
            focusNode: _keyboardFocusNode,
            onKeyEvent: _handleKeyboardEvent,
            child: Stack(
              children: [
                // Engine canvas - usar RepaintBoundary para mejor rendimiento
                RepaintBoundary(
                  child: ParkingCanvas(
                    engine: _engine,
                    onTap: _handleCanvasTap,
                    onDragEnd: _handleDragEnd,
                    selectedObjects: _selectedObjects,
                    isEditMode: _viewMode == ViewMode.editor,
                    editorMode: _editorMode,
                  ),
                ),
                
                // Editor controls overlay
                if (_viewMode == ViewMode.editor)
                  EditorControls(
                    editorMode: _editorMode,
                    onModeChanged: _setEditorMode,
                    onAddSpot: (type, {SpotCategory? category}) => 
                      _addParkingSpot(type, category: category ?? SpotCategory.normal),
                    onAddSignage: (type) => _addSignage(type),
                    onAddFacility: (type) => _addFacility(type),
                    onDelete: _selectedObjects.isNotEmpty ? _deleteSelectedObjects : null,
                    onRotate: _selectedObjects.isNotEmpty ? () => _rotateSelectedObjects(90) : null,
                    onDuplicate: _selectedObjects.isNotEmpty ? _duplicateSelectedObjects : null,
                  ),
                
                // Zoom controls
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _setZoom(_engine.zoom * 1.2),
                            tooltip: 'Acercar',
                          ),
                          const Divider(height: 1),
                          IconButton(
                            icon: const Icon(Icons.center_focus_strong),
                            onPressed: _resetViewAndZoom,
                            tooltip: 'Centrar',
                          ),
                          const Divider(height: 1),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => _setZoom(_engine.zoom / 1.2),
                            tooltip: 'Alejar',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // FPS Display
                if (_showFps)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          // Alternar entre mostrar básico y extendido
                          _showExtendedStats = !_showExtendedStats;
                        });
                      },
                      child: FpsDisplay(
                        fps: _currentFps,
                        objectCount: _mainScene.gameObjects.length,
                        showExtended: _showExtendedStats,
                      ),
                    ),
                  ),
                
                // View mode toggle
                Positioned(
                  top: 20,
                  right: 20,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: _toggleViewMode,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _viewMode == ViewMode.editor 
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: _viewMode == ViewMode.editor
                              ? Border.all(color: Colors.blue)
                              : null,
                        ),
                        child: Icon(
                          _viewMode == ViewMode.editor
                            ? Icons.visibility
                            : Icons.edit,
                          color: _viewMode == ViewMode.editor
                            ? Colors.blue
                            : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Performance Mode Toggle
                Positioned(
                  top: 70,
                  right: 20,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: _togglePerformanceMode,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _engine.renderingSystem.simplifiedRendering 
                              ? Colors.green.withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: _engine.renderingSystem.simplifiedRendering
                              ? Border.all(color: Colors.green)
                              : null,
                        ),
                        child: Icon(
                          Icons.speed,
                          color: _engine.renderingSystem.simplifiedRendering
                            ? Colors.green
                            : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Zoom info indicator (shows temporarily)
                if (_showZoomInfo)
                  Positioned(
                    top: 70,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, 
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Zoom: ${(_engine.zoom * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (_engine.cameraPosition.x != 0 || _engine.cameraPosition.y != 0)
                              Text(
                                'Posición: (${_engine.cameraPosition.x.toInt()}, ${_engine.cameraPosition.y.toInt()})',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                
                // Loading indicator
                if (_isLoading)
                  Container(
                    color: (isDarkMode ? Colors.black : Colors.white).withOpacity(0.8),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            _loadingMessage,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Handle tap events on the canvas
  void _handleCanvasTap(Offset position, List<GameObject> hitObjects) {
    // If no edit mode, show details for the first hit object
    if (_viewMode == ViewMode.normal) {
      if (hitObjects.isNotEmpty) {
        final obj = hitObjects.first;
        if (obj is ParkingSpot) {
          _editSpotProperties(obj);
        }
      }
      return;
    }
    
    // Handle edit mode taps
    if (_editorMode == EditorMode.selection) {
      setState(() {
        if (hitObjects.isEmpty) {
          // Clear selection if clicked on empty space
          _selectedObjects.clear();
        } else {
          final obj = hitObjects.first;
          
          // Check if holding shift for multiple selection
          if (HardwareKeyboard.instance.isShiftPressed) {
            if (_selectedObjects.contains(obj)) {
              // Remove from selection if already selected
              _selectedObjects.remove(obj);
            } else {
              // Add to selection
              _selectedObjects.add(obj);
            }
          } else {
            // Replace selection with clicked object
            _selectedObjects.clear();
            _selectedObjects.add(obj);
          }
        }
      });
    }
  }
  
  /// Handle drag end events for object movement
  void _handleDragEnd(List<GameObject> objects, Vector2 delta) {
    // Only handle in edit mode
    if (_viewMode != ViewMode.editor) return;
    
    // Update positions of all objects
    for (final obj in objects) {
      final currentPos = obj.transform.position;
      obj.transform.position = Vector2(
        currentPos.x + delta.x,
        currentPos.y + delta.y,
      );
    }
    
    // Force UI update
    setState(() {});
  }
} 