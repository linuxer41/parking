import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/parking_model.dart';
import '../../services/map_service.dart';
import '../reservations/reservation_screen.dart';

class ParkingMapScreen extends StatefulWidget {
  const ParkingMapScreen({super.key});

  @override
  State<ParkingMapScreen> createState() => _ParkingMapScreenState();
}

class _ParkingMapScreenState extends State<ParkingMapScreen> {
  final MapService _mapService = MapService();
  
  // Estado
  bool _isLoading = true;
  String? _errorMessage;
  LatLng _currentLocation = const LatLng(0, 0); // Ubicación predeterminada
  List<ParkingModel> _nearbyParkings = [];
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  ParkingModel? _selectedParking;
  
  // Controlador del mapa
  GoogleMapController? _mapController;
  
  @override
  void initState() {
    super.initState();
    _initializeMap();
  }
  
  Future<void> _initializeMap() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Obtener la ubicación actual
      final position = await _mapService.getCurrentLocation();
      final currentLatLng = LatLng(position.latitude, position.longitude);
      
      // Buscar estacionamientos cercanos
      final parkings = await _mapService.getNearbyParkings(currentLatLng, 1000);
      
      // Generar marcadores para los estacionamientos
      final markers = _mapService.generateParkingMarkers(parkings);
      
      setState(() {
        _currentLocation = currentLatLng;
        _nearbyParkings = parkings;
        _markers = markers;
      });
      
      // Iniciar actualizaciones en tiempo real
      _startRealtimeUpdates();
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar el mapa: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _startRealtimeUpdates() {
    _mapService.startRealtimeUpdates(_nearbyParkings, (updatedParkings) {
      setState(() {
        _nearbyParkings = updatedParkings;
        _markers = _mapService.generateParkingMarkers(updatedParkings);
        
        // Si hay un estacionamiento seleccionado, actualizarlo
        if (_selectedParking != null) {
          _selectedParking = updatedParkings.firstWhere(
            (p) => p.id == _selectedParking!.id,
            orElse: () => _selectedParking!,
          );
        }
      });
    });
  }
  
  Future<void> _getDirectionsToParking(ParkingModel parking) async {
    if (parking.latitude == null || parking.longitude == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final directions = await _mapService.getDirections(
        _currentLocation,
        LatLng(parking.latitude!, parking.longitude!),
      );
      
      final polylineCoordinates = directions['polyline_coordinates'] as List<LatLng>;
      
      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 5,
          ),
        };
        
        _selectedParking = parking;
      });
      
      // Mostrar información de la ruta
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Distancia: ${directions['distance']}, Tiempo estimado: ${directions['duration']}',
          ),
          duration: const Duration(seconds: 5),
        ),
      );
      
      // Ajustar la cámara para mostrar la ruta completa
      if (_mapController != null && polylineCoordinates.isNotEmpty) {
        final bounds = _getBounds(polylineCoordinates);
        _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 50),
        );
      }
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al obtener la ruta: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  LatLngBounds _getBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    
    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }
    
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
  
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapService.initController(controller);
  }
  
  void _goToCurrentLocation() async {
    await _mapService.animateToCurrentLocation();
  }
  
  void _clearRoute() {
    setState(() {
      _polylines = {};
      _selectedParking = null;
    });
  }
  
  void _navigateToReservation(ParkingModel parking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationScreen(parkingId: parking.id),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estacionamientos Cercanos'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeMap,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading && _markers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Mapa
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation,
                    zoom: 15,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: true,
                ),
                
                // Mensaje de error (si existe)
                if (_errorMessage != null)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.red.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                  ),
                
                // Lista de estacionamientos cercanos
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: _selectedParking != null ? 280 : 150,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Barra de arrastre
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        
                        // Título
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            _selectedParking != null
                                ? 'Detalles del Estacionamiento'
                                : 'Estacionamientos Cercanos',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        
                        const Divider(),
                        
                        // Contenido
                        Expanded(
                          child: _selectedParking != null
                              ? _buildParkingDetails()
                              : _buildParkingList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Botón para ir a la ubicación actual
          FloatingActionButton(
            heroTag: 'location',
            onPressed: _goToCurrentLocation,
            mini: true,
            backgroundColor: colorScheme.primary,
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 8),
          
          // Botón para limpiar la ruta (solo si hay una ruta activa)
          if (_polylines.isNotEmpty)
            FloatingActionButton(
              heroTag: 'clear',
              onPressed: _clearRoute,
              mini: true,
              backgroundColor: colorScheme.error,
              child: const Icon(Icons.clear),
            ),
          
          // Espacio adicional para no solapar con la lista de estacionamientos
          SizedBox(height: _selectedParking != null ? 288 : 158),
        ],
      ),
    );
  }
  
  Widget _buildParkingList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _nearbyParkings.length,
      itemBuilder: (context, index) {
        final parking = _nearbyParkings[index];
        final availableSpots = parking.availableSpots ?? 0;
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            title: Text(parking.name),
            subtitle: Text('$availableSpots espacios disponibles'),
            trailing: Icon(
              availableSpots > 0 ? Icons.check_circle : Icons.cancel,
              color: availableSpots > 0 ? Colors.green : Colors.red,
            ),
            onTap: () {
              setState(() {
                _selectedParking = parking;
              });
            },
          ),
        );
      },
    );
  }
  
  Widget _buildParkingDetails() {
    final parking = _selectedParking!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final availableSpots = parking.availableSpots ?? 0;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre del estacionamiento
          Text(
            parking.name,
            style: theme.textTheme.titleLarge,
          ),
          
          const SizedBox(height: 8),
          
          // Dirección
          Row(
            children: [
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  parking.address ?? 'Dirección no disponible',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Disponibilidad
          Row(
            children: [
              Icon(
                availableSpots > 0 ? Icons.check_circle : Icons.cancel,
                color: availableSpots > 0 ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                '$availableSpots espacios disponibles',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: availableSpots > 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Horario
          Row(
            children: [
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 8),
              Text(
                parking.openingHours ?? 'Abierto 24/7',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          
          const Spacer(),
          
          // Botones de acción
          Row(
            children: [
              // Botón para obtener indicaciones
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _getDirectionsToParking(parking),
                  icon: const Icon(Icons.directions),
                  label: const Text('Indicaciones'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Botón para reservar
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: availableSpots > 0
                      ? () => _navigateToReservation(parking)
                      : null,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Reservar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: colorScheme.onSecondary,
                    disabledBackgroundColor: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Botón para cerrar detalles
          TextButton(
            onPressed: () {
              setState(() {
                _selectedParking = null;
                _polylines = {};
              });
            },
            child: const Text('Volver a la lista'),
          ),
        ],
      ),
    );
  }
} 