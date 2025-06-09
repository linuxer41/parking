# Parking System Module Documentation

## Overview

The Parking System Module is a comprehensive solution for creating, visualizing, and managing parking facilities within the application. It provides a sophisticated editor with real-time visualization capabilities that allows users to design parking layouts, add various elements such as parking spots, signage, and facilities, and manage the occupancy status of the parking areas.

## Directory Structure

```
lib/screens/home/parking/
├── core/                     # Core state management and system components
│   ├── animation_manager.dart      # Handles animations for UI elements
│   ├── camera.dart                 # Camera system for world view management
│   ├── clipboard_manager.dart      # Manages copy/paste operations
│   ├── grid_manager.dart           # Controls the grid display and snapping
│   ├── history_manager.dart        # Implements undo/redo functionality
│   ├── keyboard_shortcuts_manager.dart # Handles keyboard shortcuts
│   ├── parking_state.dart          # Main state container for the parking system
│   └── index.dart                  # Export file
├── engine/                   # Game engine components
│   ├── game_engine.dart           # Real-time update engine
│   └── index.dart                 # Export file
├── models/                   # Data models for parking elements
│   ├── element_factory.dart       # Factory for creating parking elements
│   ├── enums.dart                 # Enumerations for parking types
│   ├── parking_elements.dart      # Base classes for parking elements
│   ├── parking_facility.dart      # Facility element model
│   ├── parking_signage.dart       # Signage element model
│   ├── parking_spot.dart          # Parking spot model
│   └── index.dart                 # Export file
├── utils/                    # Utility functions and helpers
│   ├── drawing_utils.dart         # Utilities for drawing on the canvas
│   └── index.dart                 # Export file
├── widgets/                  # UI components
│   ├── context_toolbar.dart       # Context menu toolbar
│   ├── editor_toolbar.dart        # Editor mode toolbar
│   ├── element_controls.dart      # Controls for element properties
│   ├── parking_canvas.dart        # Main drawing canvas
│   ├── toolbar.dart               # Main toolbar
│   └── index.dart                 # Export file
└── parking_screen.dart       # Main screen that integrates all components
```

## Core Components

### ParkingState

The central state management class that keeps track of:
- Parking elements (spots, signages, facilities)
- Editor state (edit mode, editor mode)
- Selection state
- Grid and coordinate display options

### Camera

A dedicated camera system inspired by game engines that manages:
- Position and movement in the 2D world
- Zoom level and viewport transformations
- Conversion between screen and world coordinates
- Smooth animated transitions
- Viewport bounds and constraints

### Game Engine

A simplified game engine inspired by professional game engines that:
- Handles the update loop
- Maintains timing and frame rate
- Updates element transformations
- Notifies UI of changes

### Animation Manager

Handles smooth animations for:
- Selection effects
- Movement transitions
- Zoom transitions
- Creation/deletion effects

## Models

The system uses a hierarchy of models to represent different parking elements:

### Base Classes
- `ParkingElement`: Abstract base class for all parking elements

### Concrete Elements
- `ParkingSpot`: Represents individual parking spaces with types:
  - Vehicle
  - Motorcycle
  - Truck
  
- `ParkingSignage`: Represents signage elements with types:
  - Entrance
  - Exit
  - Path
  - Info
  - No Parking
  - One Way
  - Two Way

- `ParkingFacility`: Represents facility elements with types:
  - Elevator
  - Stairs
  - Bathroom
  - Payment Station
  - Charging Station
  - Security Post

## Editing Capabilities

The system provides a complete set of editing features:
- Add/remove parking elements
- Select and manipulate elements
- Copy/paste/duplicate elements
- Undo/redo operations
- Grid snapping and alignment
- Keyboard shortcuts for common operations

## User Interface

The UI consists of several integrated components:
- `ParkingCanvas`: The main drawing area where parking elements are visualized
- `ParkingToolbar`: Primary toolbar with editor tools
- `ElementControlsPanel`: Controls panel for adding and configuring elements
- Status indicators showing occupancy statistics

## Implementation Requirements

When extending or modifying this module:

1. **State Management**: Always update state through the `ParkingState` class to ensure proper notification of changes.

2. **Camera Operations**: Use the `Camera` class for all viewport, zoom, and coordinate transformation operations.

3. **Element Creation**: Use the `ElementFactory` to create new elements to ensure proper initialization.

4. **Rendering**: Custom rendering should be implemented in the appropriate render methods of the `ParkingCanvas` widget.

5. **Performance**: Be mindful of performance, especially when handling large numbers of elements. Use the `GameEngine` for animations and updates to ensure smooth operation.

## Usage Example

```dart
// Add a new parking spot
void _handleAddSpot(SpotType type) {
  final cursorPos = _parkingState.cursorPosition;
  final elementSize = ElementProperties.spotVisuals[type]!;
  final elementSizeObj = Size(elementSize.width, elementSize.height);
  
  _handleAddElement<ParkingSpot>(
    position: cursorPos,
    elementSize: elementSizeObj,
    createElement: (pos) => ElementFactory.createSpot(
      position: pos,
      type: type,
      label: 'Spot-${_parkingState.spots.length + 1}',
    ) as ParkingSpot,
    addToState: _parkingState.addSpot,
  );
}
```

## Working with the Camera

The Camera system provides an elegant way to handle viewport transformations:

```dart
// Convert from screen to world coordinates
vector_math.Vector2 worldPos = camera.screenToWorld(screenOffset);

// Convert from world to screen coordinates
Offset screenPos = camera.worldToScreen(worldVector);

// Smoothly animate to a position with zoom
camera.centerOnPointWithAnimation(targetPosition, vsync, targetZoom: 1.5);

// Apply a transformation matrix to a Canvas for rendering
canvas.transform(camera.viewMatrix.storage);
```

## Extending the Module

To add new element types:

1. Add new enum values in `enums.dart`
2. Create a new model class extending `ParkingElement`
3. Add factory methods in `ElementFactory`
4. Implement rendering in `ParkingCanvas`
5. Update UI controls as needed

## Troubleshooting

Common issues:
- Elements not appearing: Ensure visibility property is set to true
- Performance issues: Check for too many elements or complex animations
- UI not updating: Make sure state changes notify listeners
- Rendering issues: Verify that the Camera's viewMatrix is properly applied 