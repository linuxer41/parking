# Parkar - Sistema de Gestión de Estacionamientos

## Descripción General

Parkar es un sistema avanzado de gestión de estacionamientos desarrollado en Flutter. Permite la creación, edición y administración de espacios de estacionamiento mediante una interfaz visual intuitiva. El sistema incluye herramientas para diseñar la distribución de estacionamientos, administrar la ocupación de espacios, y gestionar la entrada y salida de vehículos.

## Características Principales

- **Editor Visual**: Diseño de estacionamientos mediante una interfaz drag-and-drop
- **Gestión de Espacios**: Soporte para diferentes tipos de vehículos (automóviles, motocicletas, camiones)
- **Categorías Especiales**: Espacios para deshabilitados, VIP, y reservados
- **Registro de Vehículos**: Control de entrada y salida con información detallada
- **Herramientas de Edición**: Alineación, distribución, rotación y escalado de elementos
- **Historial de Acciones**: Sistema completo de deshacer/rehacer
- **Sistema de Clipboard**: Copiado y pegado de elementos con ID únicos
- **Zoom y Navegación**: Herramientas avanzadas de visualización
- **Animaciones Fluidas**: Sistema de animaciones para transiciones suaves

## Arquitectura del Sistema

El sistema Parkar está construido siguiendo un patrón de arquitectura Modelo-Vista-Controlador (MVC) con componentes reactivos:

```
lib/
├── models/          # Modelos de datos y lógica de negocio
├── screens/         # Pantallas y componentes UI
│   └── home/
│       └── parking/ # Módulo de gestión de estacionamientos
│           ├── core/        # Estado y lógica central
│           ├── engine/      # Motor de renderizado
│           ├── models/      # Modelos específicos de parking
│           ├── utils/       # Utilidades y helpers
│           └── widgets/     # Componentes visuales
├── services/        # Servicios para API y backend
└── state/           # Gestión de estado global
```

## Guía para Desarrolladores

### Inicialización del Sistema

Para iniciar el sistema de gestión de estacionamientos, use el widget `ParkingCanvas`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parkar/screens/home/parking/core/parking_state.dart';
import 'package:parkar/screens/home/parking/widgets/parking_canvas.dart';

class ParkingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ParkingState(),
      child: Scaffold(
        appBar: AppBar(title: Text('Gestión de Estacionamientos')),
        body: ParkingCanvas(),
      ),
    );
  }
}
```

### Modelo de Datos

#### Elementos Principales

El sistema utiliza varios tipos de elementos que heredan de la clase base `ParkingElement`:

- `ParkingSpot`: Espacios de estacionamiento para vehículos
- `ParkingSignage`: Señalización y direcciones dentro del estacionamiento
- `ParkingFacility`: Instalaciones como elevadores, baños, etc.

#### Enumeraciones Importantes

```dart
// Tipos de espacios de estacionamiento
enum SpotType { vehicle, motorcycle, truck }

// Categorías de espacios
enum SpotCategory { normal, disabled, reserved, vip }

// Tipos de señalización
enum SignageType { entrance, exit, path, info, noParking, oneWay, twoWay }

// Tipos de instalaciones
enum FacilityType { elevator, stairs, bathroom, paymentStation, chargingStation, securityPost }
```

### Gestión de Estado

El estado del sistema se maneja a través de la clase `ParkingState` que actúa como un controlador central:

```dart
final parkingState = ParkingState();

// Agregar un espacio de estacionamiento
final newSpot = ElementFactory.createSpot(
  position: vector_math.Vector2(100, 100),
  type: SpotType.vehicle,
  label: 'A-01',
);
parkingState.addElement(newSpot);

// Seleccionar un elemento
parkingState.selectElement(element);

// Cambiar el modo de edición
parkingState.setEditorMode(EditorMode.select);
```

### Personalización del Renderizado

El sistema utiliza la clase `ParkingRenderer` para dibujar los elementos. Puede personalizarse para adaptar el aspecto visual:

```dart
final renderer = ParkingRenderer(
  state: parkingState,
  canvasSize: Size(800, 600),
  showGrid: true,
  gridSize: 20.0,
  gridColor: Colors.grey,
  backgroundColor: Colors.white,
  selectionColor: Colors.blue,
  enableShadows: true,
  isDarkMode: false,
);
```

### Sistema de Animaciones

El sistema incluye un potente gestor de animaciones para mejorar la experiencia de usuario. Estas animaciones se pueden personalizar o desactivar según sea necesario:

#### Animaciones Disponibles

1. **Animación de Selección**: Destaca elementos seleccionados con una transición suave
2. **Animación de Movimiento**: Suaviza el movimiento de elementos al arrastrarlos
3. **Animación de Zoom**: Transición fluida al hacer zoom en el canvas
4. **Animación de Creación/Eliminación**: Efectos de fade-in y fade-out al añadir o eliminar elementos
5. **Animación de Rotación**: Transición suave al rotar elementos

#### Personalización del AnimationManager

El sistema utiliza la clase `AnimationManager` para gestionar todas las animaciones:

```dart
// Crear un gestor de animaciones personalizado
final animationManager = AnimationManager(
  defaultDuration: Duration(milliseconds: 300),
  defaultCurve: Curves.easeInOut,
  enableSelectionAnimation: true,
  enableMovementAnimation: true,
  enableZoomAnimation: true,
  enableCreateDeleteAnimation: true,
);
```

#### Uso de Métodos de Animación

El sistema proporciona métodos convenientes para utilizar animaciones en diversas operaciones:

```dart
// Añadir un elemento con animación de aparición
await parkingState.addElementWithAnimation(
  newElement,
  this, // Debe ser un TickerProvider (normalmente un State<StatefulWidget>)
);

// Mover elementos con animación
await parkingState.moveElementsWithAnimation(
  parkingState.selectedElements,
  vector_math.Vector2(50, 0), // Delta de movimiento
  this,
);

// Animar la rotación de un elemento
await parkingState.rotateElementWithAnimation(
  element,
  math.pi / 4, // 45 grados
  this,
);

// Eliminar un elemento con animación de desvanecimiento
await parkingState.removeElementWithAnimation(
  element,
  this,
);

// Animar el zoom de la cámara
await parkingState.zoomToWithAnimation(2.0, this);

// Centrar la vista en un punto con animación
await parkingState.centerViewOnPointWithAnimation(
  vector_math.Vector2(100, 100),
  this,
  targetZoom: 1.5,
);
```

#### Implementación de Animaciones Personalizadas

Para implementar una animación personalizada:

```dart
// Crear un controlador de animación
final animationController = AnimationController(
  duration: Duration(milliseconds: 300),
  vsync: this,
);

// Animar una propiedad específica
animationController.addListener(() {
  // Actualizar propiedades basadas en el valor de la animación
  element.scale = 1.0 + animationController.value * 0.2;
  setState(() {}); // Si es necesario
});

// Iniciar la animación
await animationController.forward();

// No olvide liberar recursos
animationController.dispose();
```

### Integración con Backend

Para integrar el sistema con un backend, utilice los servicios proporcionados:

```dart
import 'package:parkar/services/parking_service.dart';

// Guardar el diseño actual
final parkingService = ParkingService();
await parkingService.saveParkingLayout(parkingState.toJson());

// Cargar un diseño existente
final layout = await parkingService.getParkingLayout(layoutId);
parkingState.loadFromJson(layout);
```

### Extensión del Sistema

Para extender el sistema con nuevos tipos de elementos:

1. Cree una nueva clase que extienda `ParkingElement`
2. Implemente los métodos `render()`, `getSize()`, `clone()` y `toJson()`
3. Añada lógica para la detección de colisiones
4. Actualice `ElementFactory` para soportar la creación del nuevo tipo

Ejemplo:

```dart
class ParkingBarrier extends ParkingElement {
  final BarrierType type;
  
  ParkingBarrier({
    required String id,
    required vector_math.Vector2 position,
    required this.type,
    double rotation = 0.0,
  }) : super(id: id, position: position, rotation: rotation);
  
  @override
  void render(Canvas canvas, dynamic renderer) {
    // Implementación de renderizado
  }
  
  @override
  Size getSize() {
    return Size(80.0, 20.0);
  }
  
  @override
  ParkingElement clone() {
    return ParkingBarrier(
      id: '$id-copy',
      position: vector_math.Vector2(position.x, position.y),
      type: type,
      rotation: rotation,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    // Implementación
  }
}
```

## Mejores Prácticas

1. **Rendimiento**: Para grandes estacionamientos, utilice las optimizaciones de caché integradas
2. **Gestión de Memoria**: Libere recursos no utilizados cuando cierre el editor
3. **Responsividad**: Adapte el tamaño del grid y los elementos según el tamaño de pantalla
4. **Persistencia**: Guarde frecuentemente los cambios utilizando el sistema de serialización
5. **Extensibilidad**: Utilice la arquitectura de plugins para extender la funcionalidad
6. **Animaciones**: Utilice animaciones para mejorar la UX, pero con moderación para evitar problemas de rendimiento

## Resolución de Problemas Comunes

| Problema | Solución |
|----------|----------|
| Rendimiento lento en grandes layouts | Reduzca la cantidad de elementos visibles usando `isVisible` |
| Colisiones no detectadas | Asegúrese de que `getSize()` devuelve el tamaño correcto para sus elementos |
| Problemas de selección | Verifique la implementación de `findElementAt()` y la lógica de transformación |
| Animaciones entrecortadas | Reduzca la duración o la complejidad de las animaciones |
| Memoria insuficiente | Libere recursos no utilizados con `dispose()` y limite el uso de animaciones simultáneas |

## Ejemplos de Código

### Crear un Estacionamiento Básico

```dart
void createBasicParking(ParkingState state) {
  // Crear una fila de espacios para automóviles
  final spots = ElementFactory.generateSpotRow(
    startPosition: vector_math.Vector2(100, 100),
    count: 10,
    type: SpotType.vehicle,
    labelPrefix: 'A',
    spacing: 10.0,
  );
  
  // Añadir los espacios al estado
  for (final spot in spots) {
    state.addElement(spot);
  }
  
  // Añadir entrada y salida
  final entrance = ElementFactory.createSignage(
    position: vector_math.Vector2(50, 50),
    type: SignageType.entrance,
  );
  
  final exit = ElementFactory.createSignage(
    position: vector_math.Vector2(350, 50),
    type: SignageType.exit,
  );
  
  state.addElement(entrance);
  state.addElement(exit);
}
```

### Registrar Entrada de Vehículo

```dart
void registerVehicleEntry(ParkingSpot spot, String plate, String color) {
  if (!spot.isOccupied) {
    spot.isOccupied = true;
    spot.vehiclePlate = plate;
    spot.vehicleColor = color;
    spot.entryTime = DateTime.now();
    spot.exitTime = null;
    
    // Notificar cambios (si se usa fuera del sistema reactivo)
    spot.notifyListeners();
  }
}
```

## Contribuir al Proyecto

Si desea contribuir al desarrollo de Parkar, siga estas directrices:

1. Mantenga la coherencia con el estilo de código existente
2. Asegúrese de que todas las nuevas funciones incluyan pruebas
3. Documente cualquier cambio en la API
4. Actualice este README con nuevas características o cambios importantes

## Licencia

Este proyecto está licenciado bajo los términos de la licencia MIT.
