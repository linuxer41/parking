import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

import '../../services/parking_api_service.dart';
import '../../services/parking_realtime_service.dart';
import '../../services/service_locator.dart';
import '../../state/app_state.dart';
import '../../state/app_state_container.dart';
import 'core/parking_state.dart';
import 'engine/game_engine.dart';
import 'models/element_factory.dart';
import 'models/enums.dart';
import 'models/parking_data.dart';
import 'models/parking_elements.dart';
import 'models/parking_facility.dart';
import 'models/parking_signage.dart';
import 'models/parking_spot.dart';
import 'widgets/index.dart';

/// Pantalla principal del sistema de parkeo
class ParkingScreen extends StatefulWidget {
  const ParkingScreen({super.key});

  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen>
    with TickerProviderStateMixin {
  // Estado global del sistema de parkeo
  late ParkingState _parkingState;

  // Motor de juego
  late GameEngine _gameEngine;

  // Estado de carga
  bool _isLoading = true;

  // Servicio de tiempo real
  final ParkingRealtimeService _realtimeService = ParkingRealtimeService();

  // Estado general de la aplicación
  final AppState _appState = ServiceLocator().getAppState();

  @override
  void initState() {
    super.initState();

    // Inicializar el estado del parkeo
    _parkingState = ParkingState();

    // Inicializar el motor de juego
    _gameEngine = GameEngine(
      parkingState: _parkingState,
      onUpdate: () {
        if (mounted) {
          setState(() {});
        }
      },
    );

    // Iniciar el motor
    _gameEngine.start(this);

    // Cargar datos iniciales
    _loadInitialData();

    // Iniciar actualizaciones en tiempo real
    _initRealtimeUpdates();
  }

  @override
  void dispose() {
    // Detener el motor de juego
    _gameEngine.stop();
    // Detener las actualizaciones en tiempo real
    _realtimeService.stopRealtimeUpdates();
    super.dispose();
  }

  // Método para cargar datos iniciales
  void _loadInitialData() {
    setState(() {
      _isLoading = true;
    });

    // Crear instancia del servicio API
    final apiService = ParkingApiService();

    // Cargar datos desde "API" (archivo JSON)
    apiService.loadParkingData().then((ParkingData parkingData) {
      // Limpiar datos existentes
      _parkingState.clear();

      // Añadir spots desde el JSON
      for (final spot in parkingData.toSpots()) {
        _parkingState.addSpot(spot);
      }

      // Añadir señalización desde el JSON
      for (final signage in parkingData.toSignages()) {
        _parkingState.addSignage(signage);
      }

      // Añadir instalaciones desde el JSON
      for (final facility in parkingData.toFacilities()) {
        _parkingState.addFacility(facility);
      }

      // Actualizar el estado
      setState(() {
        _isLoading = false;
      });

      // Asegurar que la vista esté centrada en el origen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Obtener el tamaño de la pantalla para una centralización óptima
        final Size screenSize = MediaQuery.of(context).size;
        _parkingState.centerViewOnOrigin(screenSize);
      });
    }).catchError((error) {
      print('Error al cargar datos de estacionamiento: $error');

      // En caso de error, cargar datos de simulación fallback
      _addSimulationData();

      setState(() {
        _isLoading = false;
      });
    });
  }

  // Método para iniciar actualizaciones en tiempo real
  void _initRealtimeUpdates() {
    // Iniciar actualizaciones periódicas
    _realtimeService.startRealtimeUpdates(
        interval: const Duration(seconds: 10));

    // Escuchar cambios en el estado de los espacios de estacionamiento
    _realtimeService.parkingSpots.listen((spots) {
      // Actualizar spots en el estado local
      _updateParkingSpotsFromAPI(spots);
    });
  }

  // Método para actualizar el estado desde el estado general de la aplicación
  void _updateFromAppState() {
    if (_appState.currentLevel != null && _appState.currentParking != null) {
      // Aquí se actualizaría el estado local con datos del área actual
      // Por ahora, sólo mostramos mensajes informativos

      // También podemos cargar los elementos (spots, signs, facilities) desde el área
      // Esta es una implementación simulada

      // En una implementación real, se convertirían los datos del área en ParkingElement
      // Ejemplo:
      // final area = _appState.currentLevel!;
      // for (final spotData in area.spots) {
      //   final spot = ElementFactory.createSpotFromAPI(spotData);
      //   _parkingState.addSpot(spot);
      // }

      // Añadir datos de simulación si no hay datos reales
      if (_parkingState.spots.isEmpty) {
        _addSimulationData();
      }
    }
  }

  // Método para actualizar los spots desde la API
  void _updateParkingSpotsFromAPI(List<dynamic> apiSpots) {
    // Implementación simplificada para actualizar estado de ocupación
    // En una implementación real, se mapearían los SpotModel a ParkingSpot

    // Ejemplo usando simulación:
    for (final spot in _parkingState.spots) {
      if (spot is ParkingSpot) {
        // Simular cambios aleatorios en ocupación para demostración
        final shouldUpdate = DateTime.now().millisecondsSinceEpoch % 3 == 0;
        if (shouldUpdate) {
          // Alternar el estado de ocupación
          spot.isOccupied = !spot.isOccupied;
          if (spot.isOccupied) {
            spot.entryTime = DateTime.now();
            spot.vehiclePlate =
                "SIM-${(1000 + DateTime.now().second * 17) % 9999}";
          } else {
            spot.exitTime = DateTime.now();
          }
        }
      }
    }
  }

  // Método para añadir datos de simulación
  void _addSimulationData() {
    // Limpiar datos existentes
    _parkingState.clear();

    // ======= OBTENER DIMENSIONES REALES DE ELEMENTPROPERTIES =======
    // Obtener las dimensiones reales de los spots desde ElementProperties
    final vehicleSpotVisuals = ElementProperties.spotVisuals[SpotType.vehicle]!;
    final spotWidth = vehicleSpotVisuals.width;
    final spotLength = vehicleSpotVisuals.height;
    const spotSpacing = 10.0; // Espacio entre spots

    // ======= ESTRUCTURA BÁSICA DE VÍAS (SIMPLIFICADA) =======

    // Vía principal horizontal (reducida para evitar superposiciones)
    const roadY = 0.0;
    // Menos señales, más espaciadas para evitar superposiciones
    for (int i = -6; i <= 6; i += 2) {
      final path = ElementFactory.createSignage(
        position: vector_math.Vector2(i * 40.0, roadY),
        type: SignageType.path,
        rotation: 0.0,
      );
      _parkingState.addSignage(path);
    }

    // Vía vertical izquierda (reducida)
    const leftRoadX = -150.0;
    for (int i = -8; i <= 8; i += 2) {
      // Evitar solapamiento con la vía horizontal
      if (i == 0) continue;

      final path = ElementFactory.createSignage(
        position: vector_math.Vector2(leftRoadX, i * 40.0),
        type: SignageType.path,
        rotation: 90.0,
      );
      _parkingState.addSignage(path);
    }

    // Vía vertical derecha (reducida)
    const rightRoadX = 150.0;
    for (int i = -8; i <= 8; i += 2) {
      // Evitar solapamiento con la vía horizontal
      if (i == 0) continue;

      final path = ElementFactory.createSignage(
        position: vector_math.Vector2(rightRoadX, i * 40.0),
        type: SignageType.path,
        rotation: 90.0,
      );
      _parkingState.addSignage(path);
    }

    // ======= ENTRADA Y SALIDA =======
    // Entrada ubicada de forma estratégica
    final entrance = ElementFactory.createSignage(
      position: vector_math.Vector2(-250.0, roadY - 50.0),
      type: SignageType.entrance,
      rotation: 0.0,
      scale: 1.0,
    );
    _parkingState.addSignage(entrance);

    // Salida ubicada de forma estratégica
    final exit = ElementFactory.createSignage(
      position: vector_math.Vector2(250.0, roadY + 50.0),
      type: SignageType.exit,
      rotation: 0.0,
      scale: 1.0,
    );
    _parkingState.addSignage(exit);

    // ======= 30 PLAZAS DE ESTACIONAMIENTO =======

    // BLOQUE NORTE (10 plazas en batería a 90°)
    const northStartY = -150.0;

    for (int i = 0; i < 10; i++) {
      // Calcular posición basada en dimensiones reales
      final spotX = -200.0 + (i * (spotWidth + spotSpacing));

      // Determinar categoría
      SpotCategory category = SpotCategory.normal;

      // Primeros dos espacios para discapacitados
      if (i < 2) {
        category = SpotCategory.disabled;
      }
      // Los últimos dos son VIP
      else if (i >= 8) {
        category = SpotCategory.vip;
      }

      final spot = ElementFactory.createSpot(
        position: vector_math.Vector2(spotX, northStartY),
        type: SpotType.vehicle,
        category: category,
        label: 'N-${i + 1}',
        rotation: 0.0,
        scale: 1.0,
      );
      _parkingState.addSpot(spot);
    }

    // BLOQUE OESTE (10 plazas perpendiculares)
    const westStartX = -250.0;

    for (int i = 0; i < 10; i++) {
      // Calcular posición basada en dimensiones reales
      final spotY = -100.0 + (i * (spotWidth + spotSpacing));

      // Determinar categoría
      SpotCategory category = SpotCategory.normal;

      // Espacio reservado en el medio
      if (i == 4 || i == 5) {
        category = SpotCategory.reserved;
      }

      final spot = ElementFactory.createSpot(
        position: vector_math.Vector2(westStartX, spotY),
        type: SpotType.vehicle,
        category: category,
        label: 'W-${i + 1}',
        rotation: 90.0, // Rotación perpendicular a la vía
        scale: 1.0,
      );
      _parkingState.addSpot(spot);
    }

    // BLOQUE ESTE (10 plazas perpendiculares)
    const eastStartX = 250.0;

    for (int i = 0; i < 10; i++) {
      // Calcular posición basada en dimensiones reales
      final spotY = -100.0 + (i * (spotWidth + spotSpacing));

      // Determinar categoría
      SpotCategory category = SpotCategory.normal;

      // Espacio reservado en el medio
      if (i == 4 || i == 5) {
        category = SpotCategory.reserved;
      }

      final spot = ElementFactory.createSpot(
        position: vector_math.Vector2(eastStartX, spotY),
        type: SpotType.vehicle,
        category: category,
        label: 'E-${i + 1}',
        rotation: -90.0, // Rotación perpendicular a la vía (inversa)
        scale: 1.0,
      );
      _parkingState.addSpot(spot);
    }

    // ======= INSTALACIONES EN LUGARES ESTRATÉGICOS =======

    // Centro de Pago - Cerca de la salida para facilitar pagos antes de salir
    final paymentStation = ElementFactory.createFacility(
      position: vector_math.Vector2(200.0, 120.0),
      type: FacilityType.paymentStation,
      name: 'Centro de Pago',
      scale: 1.0,
    );
    _parkingState.addFacility(paymentStation);

    // Seguridad - Ubicado cerca de la entrada para control de acceso
    final security = ElementFactory.createFacility(
      position: vector_math.Vector2(-200.0, -50.0),
      type: FacilityType.securityPost,
      name: 'Seguridad',
      scale: 1.0,
    );
    _parkingState.addFacility(security);

    // Baños - Ubicado en el centro para fácil acceso desde cualquier punto
    final bathroom = ElementFactory.createFacility(
      position: vector_math.Vector2(0.0, 80.0),
      type: FacilityType.bathroom,
      name: 'Baños',
      scale: 1.0,
    );
    _parkingState.addFacility(bathroom);

    // Elevador - Cerca de los espacios para discapacitados
    final elevator = ElementFactory.createFacility(
      position: vector_math.Vector2(-180.0, -180.0),
      type: FacilityType.elevator,
      name: 'Elevador',
      scale: 1.0,
    );
    _parkingState.addFacility(elevator);

    // ======= SEÑALIZACIÓN MÍNIMA =======

    // Solo una señal informativa principal
    final infoSign = ElementFactory.createSignage(
      position: vector_math.Vector2(0.0, -220.0),
      type: SignageType.info,
      rotation: 0.0,
    );
    _parkingState.addSignage(infoSign);

    // Simular ocupación aleatoria (30% aproximadamente)
    _simulateRandomOccupation(30);
  }

  // Método para simular ocupación aleatoria
  void _simulateRandomOccupation(int percentOccupied) {
    final List<ParkingSpot> spots = [];

    // Recopilar todos los spots
    for (final element in _parkingState.spots) {
      if (element is ParkingSpot) {
        spots.add(element);
      }
    }

    // Calcular cuántos spots ocupar
    final int numToOccupy = (spots.length * percentOccupied / 100).round();

    // Barajar la lista para selección aleatoria
    spots.shuffle();

    // Ocupar los primeros 'numToOccupy' spots
    for (int i = 0; i < numToOccupy; i++) {
      if (i < spots.length) {
        final parkingSpot = spots[i];
        parkingSpot.isOccupied = true;
        parkingSpot.vehiclePlate = "ABC-${1000 + i}";
        parkingSpot.entryTime =
            DateTime.now().subtract(Duration(minutes: (i * 17) % 240));

        // Asignar un color aleatorio
        final colors = ['Blanco', 'Negro', 'Gris', 'Rojo', 'Azul', 'Verde'];
        parkingSpot.vehicleColor = colors[i % colors.length];
      }
    }
  }

  // Método para simular spots ocupados aleatoriamente
  void _simulateOccupiedSpots(int percentOccupied) {
    final List<ParkingSpot> spots = [];

    // Recopilar todos los spots
    for (final element in _parkingState.spots) {
      if (element is ParkingSpot) {
        spots.add(element);
      }
    }

    // Calcular cuántos spots ocupar
    final int numToOccupy = (spots.length * percentOccupied / 100).round();

    // Barajar la lista para selección aleatoria
    spots.shuffle();

    // Ocupar los primeros 'numToOccupy' spots
    for (int i = 0; i < numToOccupy; i++) {
      if (i < spots.length) {
        final parkingSpot = spots[i];
        parkingSpot.isOccupied = true;
        parkingSpot.vehiclePlate = "ABC-${1000 + i}";
        parkingSpot.entryTime =
            DateTime.now().subtract(Duration(minutes: (i * 17) % 240));

        // Asignar un color aleatorio
        final colors = ['Blanco', 'Negro', 'Gris', 'Rojo', 'Azul', 'Verde'];
        parkingSpot.vehicleColor = colors[i % colors.length];
      }
    }
  }

  // Método para crear estacionamiento en batería en ángulo
  void _createAngledParkingBlock(
      {required double startX,
      required double startY,
      required int rows,
      required int spotsPerRow,
      required double spotWidth,
      required double spotLength,
      required double spacing,
      required double angle,
      required String section,
      required int startNumber}) {
    // Convertir ángulo a radianes
    final angleRad = angle * math.pi / 180;

    // Calcular offset entre filas basado en el ángulo
    final rowOffset = (spotWidth + spacing) * math.cos(angleRad);
    final rowSpacing = (spotWidth + spacing) * math.sin(angleRad);

    int spotCounter = startNumber;

    for (int row = 0; row < rows; row++) {
      final rowStartY = startY + row * rowSpacing;

      for (int i = 0; i < spotsPerRow; i++) {
        // Calcular posición real con offset por ángulo
        final spotX = startX + i * rowOffset;
        final spotY = rowStartY;

        // Determinar categoría
        SpotCategory category = SpotCategory.normal;

        // Asignar spots especiales
        if (row == 0 && (i == 0 || i == 1)) {
          category = SpotCategory.disabled;
        } else if (row == rows - 1 &&
            (i == spotsPerRow - 1 || i == spotsPerRow - 2)) {
          category = SpotCategory.vip;
        } else if (row == rows ~/ 2 && (i == spotsPerRow ~/ 2)) {
          category = SpotCategory.reserved;
        }

        final parkingSpot = ElementFactory.createSpot(
          position: vector_math.Vector2(spotX, spotY),
          type: SpotType.vehicle,
          category: category,
          label: '$section-$spotCounter',
          rotation: angle,
          scale: 0.95, // Ligera reducción para evitar solapamientos
        );

        _parkingState.addSpot(parkingSpot);
        spotCounter++;
      }
    }
  }

  // Método para crear estacionamiento perpendicular
  void _createPerpendicularParkingBlock(
      {required double startX,
      required double startY,
      required int rows,
      required int spotsPerRow,
      required double spotWidth,
      required double spotLength,
      required double spacing,
      required double rowSpacing,
      required String section,
      required int startNumber,
      required bool isLeftSide}) {
    final angle = isLeftSide ? 90.0 : -90.0;
    int spotCounter = startNumber;

    for (int row = 0; row < rows; row++) {
      final rowY = startY + row * (spotWidth + rowSpacing);

      for (int i = 0; i < spotsPerRow; i++) {
        final spotX =
            startX + (isLeftSide ? -1 : 1) * i * (spotLength + spacing);

        // Determinar categoría
        SpotCategory category = SpotCategory.normal;

        // Asignar spots especiales
        if (row == 0 && (i == 0 || i == 1)) {
          category = SpotCategory.disabled;
        } else if (row == rows - 1 &&
            (i == spotsPerRow - 1 || i == spotsPerRow - 2)) {
          category = SpotCategory.vip;
        } else if (row == rows ~/ 2 && (i == spotsPerRow ~/ 2)) {
          category = SpotCategory.reserved;
        }

        final parkingSpot = ElementFactory.createSpot(
          position: vector_math.Vector2(spotX, rowY),
          type: SpotType.vehicle,
          category: category,
          label: '$section-$spotCounter',
          rotation: angle,
          scale: 0.95,
        );

        _parkingState.addSpot(parkingSpot);
        spotCounter++;
      }
    }
  }

  // Método para crear estacionamiento paralelo a la vía
  void _createParallelParkingBlock(
      {required double startX,
      required double startY,
      required int count,
      required double spotWidth,
      required double spotLength,
      required double spacing,
      required String section,
      required int startNumber,
      required String orientation}) {
    final isHorizontal = orientation == 'horizontal';
    final angle = isHorizontal ? 0.0 : 90.0;

    for (int i = 0; i < count; i++) {
      final posX = isHorizontal ? startX + i * (spotLength + spacing) : startX;
      final posY = isHorizontal ? startY : startY + i * (spotLength + spacing);

      // Determinar categoría
      SpotCategory category = SpotCategory.normal;

      // Primeros dos spots para discapacitados
      if (i == 0) {
        category = SpotCategory.disabled;
      }
      // Últimos dos spots VIP
      else if (i == count - 1) {
        category = SpotCategory.vip;
      }

      final parkingSpot = ElementFactory.createSpot(
        position: vector_math.Vector2(posX, posY),
        type: SpotType.vehicle,
        category: category,
        label: '$section-${startNumber + i}',
        rotation: angle,
        scale: 0.95,
      );

      _parkingState.addSpot(parkingSpot);
    }
  }

  // Método para crear islas de estacionamiento (doble fila)
  void _createIslandParkingBlock(
      {required double centerX,
      required double startY,
      required int rows,
      required int spotsPerRow,
      required double spotWidth,
      required double spotLength,
      required double spacing,
      required double rowSpacing,
      required String section,
      required int startNumber}) {
    int spotCounter = startNumber;

    for (int row = 0; row < rows; row++) {
      final rowY = startY + row * rowSpacing;

      // Fila hacia la izquierda (rotación 90 grados)
      for (int i = 0; i < spotsPerRow ~/ 2; i++) {
        final spotX = centerX - spotWidth / 2 - i * (spotLength + spacing);

        SpotCategory category = SpotCategory.normal;
        if (row == 0 && i == 0) {
          category = SpotCategory.disabled;
        }

        final leftSpot = ElementFactory.createSpot(
          position: vector_math.Vector2(spotX, rowY),
          type: SpotType.vehicle,
          category: category,
          label: '$section-$spotCounter',
          rotation: 90.0,
          scale: 0.95,
        );

        _parkingState.addSpot(leftSpot);
        spotCounter++;
      }

      // Fila hacia la derecha (rotación -90 grados)
      for (int i = 0; i < spotsPerRow ~/ 2; i++) {
        final spotX = centerX + spotWidth / 2 + i * (spotLength + spacing);

        SpotCategory category = SpotCategory.normal;
        if (row == rows - 1 && i == (spotsPerRow ~/ 2) - 1) {
          category = SpotCategory.vip;
        }

        final rightSpot = ElementFactory.createSpot(
          position: vector_math.Vector2(spotX, rowY),
          type: SpotType.vehicle,
          category: category,
          label: '$section-$spotCounter',
          rotation: -90.0,
          scale: 0.95,
        );

        _parkingState.addSpot(rightSpot);
        spotCounter++;
      }
    }
  }

  // Método común para manejar la adición de elementos
  void _handleAddElement<T extends ParkingElement>({
    required vector_math.Vector2 position,
    required Size elementSize,
    required T Function(vector_math.Vector2) createElement,
    required void Function(T) addToState,
  }) {
    if (!_parkingState.isEditMode) return;

    // Encontrar una posición óptima sin colisiones
    final optimalPosition =
        _parkingState.findOptimalPosition(elementSize, position);

    // Crear el nuevo elemento en la posición óptima
    final newElement = createElement(optimalPosition);

    // Asegurar que el nuevo elemento sea visible
    newElement.isVisible = true;

    // Añadir al estado
    addToState(newElement);

    // Seleccionar el nuevo elemento
    _parkingState.clearSelection();
    _parkingState.selectElement(newElement);

    // Registrar la acción en el historial
    _parkingState.historyManager.addElementAction(newElement);
  }

  // Métodos para manejar la adición de elementos
  void _handleAddSpot(SpotType type) {
    // Obtener posición del cursor en el mundo
    final cursorPos = _parkingState.cursorPosition;

    // Obtener tamaño del nuevo elemento
    final elementSize = ElementProperties.spotVisuals[type]!;
    final elementSizeObj = Size(elementSize.width, elementSize.height);

    _handleAddElement<ParkingSpot>(
      position: cursorPos,
      elementSize: elementSizeObj,
      createElement: (pos) => ElementFactory.createSpot(
        position: pos,
        type: type,
        label: 'Spot-${_parkingState.spots.length + 1}',
      ),
      addToState: _parkingState.addSpot,
    );
  }

  void _handleAddSignage(SignageType type) {
    // Obtener posición del cursor en el mundo
    final cursorPos = _parkingState.cursorPosition;

    // Obtener tamaño del nuevo elemento
    final elementSize = ElementProperties.signageVisuals[type]!;
    final elementSizeObj = Size(elementSize.width, elementSize.height);

    _handleAddElement<ParkingSignage>(
      position: cursorPos,
      elementSize: elementSizeObj,
      createElement: (pos) => ElementFactory.createSignage(
        position: pos,
        type: type,
      ),
      addToState: _parkingState.addSignage,
    );
  }

  void _handleAddFacility(FacilityType type) {
    // Obtener posición del cursor en el mundo
    final cursorPos = _parkingState.cursorPosition;

    // Obtener tamaño del nuevo elemento
    final elementSize = ElementProperties.facilityVisuals[type]!;
    final elementSizeObj = Size(elementSize.width, elementSize.height);

    _handleAddElement<ParkingFacility>(
      position: cursorPos,
      elementSize: elementSizeObj,
      createElement: (pos) => ElementFactory.createFacility(
        position: pos,
        type: type,
        name: '${elementSize.label} ${_parkingState.facilities.length + 1}',
      ),
      addToState: _parkingState.addFacility,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final appTheme = AppStateContainer.theme(context);
    final colorScheme = theme.colorScheme;

    return ChangeNotifierProvider.value(
      value: _parkingState,
      child: ChangeNotifierProvider.value(
        value: appTheme,
        child: Scaffold(
          body: Stack(
            children: [
              // Canvas principal del sistema de parkeo
              const ParkingCanvas(),

              // Panel superior con información del estacionamiento y nivel
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Consumer<ParkingState>(
                    builder: (context, state, _) {
                      // Solo mostrar el panel de información cuando no está en modo edición
                      if (state.isEditMode) {
                        return const SizedBox.shrink();
                      }
                      return _buildParkingInfoPanel(theme, colorScheme);
                    },
                  ),
                ),
              ),

              // Botones de acción de edición (solo visibles en modo edición)
              Consumer<ParkingState>(
                builder: (context, state, _) {
                  if (state.isEditMode) {
                    return Positioned(
                      top: 0,
                      right: 0,
                      child: SafeArea(
                        child: EditActionButtons(
                          onSaveChanges: () {
                            state.isEditMode = false;
                          },
                          onCancelChanges: () {
                            state.isEditMode = false;
                          },
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),

              // Panel de control inferior (solo visible en modo edición)
              Consumer<ParkingState>(
                builder: (context, state, _) {
                  if (state.isEditMode) {
                    return Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        bottom: true,
                        child: Center(
                          child: ElementControlsPanel(
                            onAddSpot: _handleAddSpot,
                            onAddSignage: _handleAddSignage,
                            onAddFacility: _handleAddFacility,
                          ),
                        ),
                      ),
                    );
                  } else {
                    // Panel de estadísticas cuando no está en modo edición
                    return Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        bottom: true,
                        child:
                            _buildParkingStatusPanel(state, theme, colorScheme),
                      ),
                    );
                  }
                },
              ),

              // Pantalla de carga
              if (_isLoading)
                Container(
                  color: isDarkMode ? Colors.black87 : Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Cargando estacionamiento...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Barra de herramientas vertical siempre al final para que esté por encima de todo
              const ParkingToolbar(),
            ],
          ),
        ),
      ),
    );
  }

  // Panel superior con información del estacionamiento y nivel
  Widget _buildParkingInfoPanel(ThemeData theme, ColorScheme colorScheme) {
    final parkingName = _appState.currentParking?.name ?? 'Parqueo';
    final areaName = _appState.currentLevel?.name ?? 'Área principal';

    // Determinar si es móvil o tablet
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Calcular ancho máximo del contenedor
    final containerWidth =
        isMobile ? screenWidth : math.min(500.0, screenWidth);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : (screenWidth - containerWidth) / 2 + 8,
        vertical: 8,
      ),
      height: 56,
      width: containerWidth,
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.black.withOpacity(0.7)
            : colorScheme.surfaceContainerHighest.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Información del parqueo y nivel (70%)
            Expanded(
              flex: 7, // 70% del espacio
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nombre del parqueo con icono
                  Row(
                    children: [
                      Icon(
                        Icons.local_parking,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          parkingName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Área con icono
                  Row(
                    children: [
                      Icon(
                        Icons.grid_view_rounded,
                        size: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          areaName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Botones de acción (30% del espacio)
            Expanded(
              flex: 3, // 30% del espacio
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Botón para cambiar nivel/parqueo (minimalista)
                  Consumer<ParkingState>(
                    builder: (context, state, _) {
                      if (state.isEditMode) return const SizedBox.shrink();
                      return IconButton(
                        onPressed: () => _showChangeParkingDialog(context),
                        icon: Icon(
                          Icons.swap_horiz,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        tooltip: 'Cambiar',
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      );
                    },
                  ),

                  // Botón para editar (minimalista)
                  Consumer<ParkingState>(
                    builder: (context, state, _) {
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            state.isEditMode = !state.isEditMode;
                          });
                        },
                        icon: Icon(
                          state.isEditMode ? Icons.close : Icons.edit,
                          size: 18,
                          color: state.isEditMode
                              ? colorScheme.error
                              : colorScheme.primary,
                        ),
                        tooltip: state.isEditMode ? 'Cancelar' : 'Editar',
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Diálogo para cambiar de parqueo o nivel
  void _showChangeParkingDialog(BuildContext context) {
    // Obtener tema y colores
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Estacionamientos de ejemplo (en una implementación real vendrían de la API)
    final parkings = [
      {
        'name': 'Parqueo Central',
        'address': 'Calle Principal #123',
        'isActive': true,
        'areas': [
          {'name': 'Área A - Planta principal', 'capacity': 120},
          {'name': 'Área B - Planta 1', 'capacity': 80},
          {'name': 'Área C - Sótano', 'capacity': 50},
        ]
      },
      {
        'name': 'Plaza Norte',
        'address': 'Av. Norte #456',
        'isActive': true,
        'areas': [
          {'name': 'Área Única', 'capacity': 200},
        ]
      },
      {
        'name': 'Estacionamiento Sur',
        'address': 'Calle Sur #789',
        'isActive': false,
        'areas': [
          {'name': 'Área Baja', 'capacity': 60},
          {'name': 'Área Alta', 'capacity': 40},
        ]
      },
    ];

    // Mapa para controlar qué estacionamientos están expandidos
    final Map<String, bool> expandedParkings = {};

    // Mostrar diálogo modal
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: EdgeInsets.only(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Seleccionar Estacionamiento y Área',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Divider(),

                  // Lista unificada de estacionamientos con áreas expandibles
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: parkings.length,
                    itemBuilder: (context, index) {
                      final parking = parkings[index];
                      final isActive = parking['isActive'] as bool;
                      final areas = parking['areas'] as List;
                      final hasMultipleAreas = areas.length > 1;
                      final parkingId = parking['name'] as String;
                      final isExpanded = expandedParkings[parkingId] ?? false;

                      return Column(
                        children: [
                          // Tarjeta del estacionamiento
                          Card(
                            elevation: 0,
                            color: theme.brightness == Brightness.dark
                                ? colorScheme.surfaceContainerHighest
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white10
                                    : Colors.black12,
                                width: 1,
                              ),
                            ),
                            margin: EdgeInsets.only(
                                bottom: hasMultipleAreas && isExpanded ? 4 : 8),
                            child: InkWell(
                              onTap: () {
                                if (hasMultipleAreas) {
                                  // Si tiene múltiples áreas, expandir/contraer
                                  setState(() {
                                    expandedParkings[parkingId] = !isExpanded;
                                    print(
                                        "Expandiendo $parkingId: ${!isExpanded}");
                                  });
                                } else {
                                  // Si solo tiene un área, seleccionar directamente
                                  // En una implementación real, se cargarían el estacionamiento y área
                                  // _appState.setCurrentParking(parking);
                                  // _appState.setCurrentArea(areas[0]);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Seleccionado: ${parking['name']} - ${areas[0]['name']}'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  Navigator.pop(context);
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? colorScheme.primary
                                                .withOpacity(0.1)
                                            : colorScheme.surfaceVariant,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.local_parking_rounded,
                                          color: isActive
                                              ? colorScheme.primary
                                              : colorScheme.onSurfaceVariant,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            parking['name'] as String,
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            parking['address'] as String,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${areas.length} ${areas.length == 1 ? 'area' : 'areas'}',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: colorScheme.primary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (hasMultipleAreas)
                                      Icon(
                                        isExpanded
                                            ? Icons.keyboard_arrow_up_rounded
                                            : Icons.keyboard_arrow_down_rounded,
                                        color: colorScheme.primary,
                                        size: 24,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Áreas expandibles (solo si tiene múltiples áreas y está expandido)
                          if (hasMultipleAreas && isExpanded)
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 8, bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    child: Text(
                                      'Áreas:',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  // Construir las áreas manualmente
                                  for (int i = 0; i < areas.length; i++)
                                    _buildAreaCard(context, areas[i], parking,
                                        theme, colorScheme),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Botón para registrar nuevo estacionamiento
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navegar a la página de perfil, pestaña de parkeo
                      Navigator.pushNamed(context, '/profile');
                      // En una implementación real, se navegaría directamente a la pestaña de parkeo
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Registrar nuevo estacionamiento'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Método auxiliar para construir una tarjeta de área
  Widget _buildAreaCard(BuildContext context, dynamic area,
      Map<String, dynamic> parking, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: theme.brightness == Brightness.dark
          ? colorScheme.surfaceContainerLow
          : colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: theme.brightness == Brightness.dark
              ? Colors.white10
              : Colors.black12,
          width: 0.5,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () {
          // En una implementación real, se cargarían el estacionamiento y área
          // _appState.setCurrentParking(parking);
          // _appState.setCurrentArea(area);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Seleccionado: ${parking['name']} - ${area['name']}'),
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.grid_view_rounded,
                    color: colorScheme.primary,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      area['name'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Capacidad: ${area['capacity']} espacios',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Panel de estado de estacionamiento
  Widget _buildParkingStatusPanel(
      ParkingState state, ThemeData theme, ColorScheme colorScheme) {
    // Contar espacios ocupados y libres
    int totalSpots = 0;
    int occupiedSpots = 0;

    // Calcular tiempo promedio de estancia
    double averageStayMinutes = 0;
    int vehiclesWithStay = 0;

    for (final element in state.spots) {
      if (element is ParkingSpot) {
        totalSpots++;
        if (element.isOccupied) {
          occupiedSpots++;
          if (element.entryTime != null) {
            final stayDuration = DateTime.now().difference(element.entryTime!);
            averageStayMinutes += stayDuration.inMinutes;
            vehiclesWithStay++;
          }
        }
      }
    }

    int freeSpots = totalSpots - occupiedSpots;
    double occupancyRate =
        totalSpots > 0 ? (occupiedSpots / totalSpots) * 100 : 0;

    // Calcular promedio de estancia
    if (vehiclesWithStay > 0) {
      averageStayMinutes = averageStayMinutes / vehiclesWithStay;
    }

    // Determinar el color de ocupación basado en el porcentaje
    Color occupancyColor;
    if (occupancyRate < 50) {
      occupancyColor = Colors.green;
    } else if (occupancyRate < 80) {
      occupancyColor = Colors.orange;
    } else {
      occupancyColor = Colors.red;
    }

    // Determinar si es móvil o desktop
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final containerWidth = isMobile ? screenWidth : 600.0;

    return Container(
      width: containerWidth,
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 0 : (screenWidth - containerWidth) / 2,
      ),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Espacios Libres
            _buildStatusItem(
              icon: Icons.check_circle_outline,
              iconColor: Colors.green,
              label: 'Libres',
              value: '$freeSpots',
              theme: theme,
              colorScheme: colorScheme,
            ),

            // Separador vertical
            Container(
              height: 40,
              width: 1,
              color: colorScheme.outlineVariant,
            ),

            // Espacios Ocupados
            _buildStatusItem(
              icon: Icons.car_rental,
              iconColor: Colors.red,
              label: 'Ocupados',
              value: '$occupiedSpots',
              theme: theme,
              colorScheme: colorScheme,
            ),

            // Separador vertical
            Container(
              height: 40,
              width: 1,
              color: colorScheme.outlineVariant,
            ),

            // Porcentaje de Ocupación
            _buildStatusItem(
              icon: Icons.pie_chart,
              iconColor: occupancyColor,
              label: 'Ocupación',
              value: '${occupancyRate.toStringAsFixed(1)}%',
              theme: theme,
              colorScheme: colorScheme,
            ),
          ],
        ),
      ),
    );
  }

  // Elemento individual del panel de estado
  Widget _buildStatusItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono con fondo circular suave
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 4),

          // Valor principal
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),

          // Etiqueta
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
