import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapSelectionScreen extends StatefulWidget {
  const MapSelectionScreen({super.key});

  @override
  State<MapSelectionScreen> createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  bool _isLoading = true;
  String? _error;
  String _selectedAddress = '';
  double? _selectedLatitude;
  double? _selectedLongitude;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Verificar si los servicios de ubicación están habilitados
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception(
          'Los servicios de ubicación están deshabilitados. '
          'Por favor, habilítalos en la configuración de tu dispositivo.',
        );
      }

      // Verificar permisos de ubicación
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception(
            'Permisos de ubicación denegados. '
            'La aplicación necesita acceso a tu ubicación para funcionar correctamente.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Los permisos de ubicación están permanentemente denegados. '
          'Por favor, ve a Configuración > Aplicaciones > Parkar > Permisos '
          'y habilita el acceso a la ubicación.',
        );
      }

      // Obtener ubicación actual
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      setState(() {
        _selectedLatitude = position.latitude;
        _selectedLongitude = position.longitude;
        _isLoading = false;
      });

      // Obtener dirección de las coordenadas
      await _getAddressFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        _error = 'Error al obtener ubicación: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address = [
          placemark.street,
          placemark.subLocality,
          placemark.locality,
          placemark.administrativeArea,
          placemark.country,
        ].where((part) => part != null && part.isNotEmpty).join(', ');

        setState(() {
          _selectedAddress = address;
        });
      }
    } catch (e) {
      // Si no se puede obtener la dirección, usar coordenadas como fallback
      setState(() {
        _selectedAddress = 'Lat: $latitude, Long: $longitude';
      });
    }
  }

  Future<void> _selectCustomLocation() async {
    // Simular selección de ubicación personalizada
    // En una implementación real, aquí se abriría un mapa interactivo
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _CustomLocationDialog(
        currentLatitude: _selectedLatitude,
        currentLongitude: _selectedLongitude,
        currentAddress: _selectedAddress,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLatitude = result['latitude'];
        _selectedLongitude = result['longitude'];
        _selectedAddress = result['address'];
      });
    }
  }

  void _confirmSelection() {
    if (_selectedLatitude != null && _selectedLongitude != null) {
      Navigator.pop(context, {
        'address': _selectedAddress,
        'latitude': _selectedLatitude,
        'longitude': _selectedLongitude,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Seleccionar Ubicación',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _selectedLatitude != null && _selectedLongitude != null
                ? _confirmSelection
                : null,
            child: Text(
              'Confirmar',
              style: textTheme.labelMedium?.copyWith(
                color: _selectedLatitude != null && _selectedLongitude != null
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Obteniendo ubicación...',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off_outlined,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error de ubicación',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Column(
                      children: [
                        FilledButton.icon(
                          onPressed: _getCurrentLocation,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () async {
                            // Abrir configuración de la aplicación
                            await Geolocator.openAppSettings();
                          },
                          icon: const Icon(Icons.settings),
                          label: const Text('Abrir Configuración'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : _buildMapContent(context),
    );
  }

  Widget _buildMapContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        // Vista simulada del mapa
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 60),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Mapa interactivo real
                FlutterMap(
                  options: MapOptions(
                    initialCenter:
                        _selectedLatitude != null && _selectedLongitude != null
                        ? LatLng(_selectedLatitude!, _selectedLongitude!)
                        : const LatLng(
                            -16.5000,
                            -68.1500,
                          ), // Coordenadas por defecto (La Paz, Bolivia)
                    initialZoom: 16.0,
                    onTap: (tapPosition, point) {
                      // Actualizar ubicación seleccionada al tocar el mapa
                      setState(() {
                        _selectedLatitude = point.latitude;
                        _selectedLongitude = point.longitude;
                      });
                      _getAddressFromCoordinates(
                        point.latitude,
                        point.longitude,
                      );
                    },
                  ),
                  children: [
                    // Capa de tiles de OpenStreetMap (gratuita)
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.parkar.app',
                    ),
                    // Marcador de ubicación seleccionada
                    if (_selectedLatitude != null && _selectedLongitude != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              _selectedLatitude!,
                              _selectedLongitude!,
                            ),
                            width: 20,
                            height: 20,
                            child: Icon(
                              Icons.location_on,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Panel de información
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: colorScheme.outline.withValues(alpha: 60),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ubicación Seleccionada',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              // Dirección
              if (_selectedAddress.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 20,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedAddress,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              // Coordenadas
              if (_selectedLatitude != null && _selectedLongitude != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.gps_fixed,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Latitud: ${_selectedLatitude!.toStringAsFixed(6)}',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              'Longitud: ${_selectedLongitude!.toStringAsFixed(6)}',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.my_location),
                      label: const Text('Mi Ubicación'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectCustomLocation,
                      icon: const Icon(Icons.edit_location),
                      label: const Text('Personalizar'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Diálogo para selección personalizada de ubicación
class _CustomLocationDialog extends StatefulWidget {
  final double? currentLatitude;
  final double? currentLongitude;
  final String? currentAddress;

  const _CustomLocationDialog({
    this.currentLatitude,
    this.currentLongitude,
    this.currentAddress,
  });

  @override
  State<_CustomLocationDialog> createState() => _CustomLocationDialogState();
}

class _CustomLocationDialogState extends State<_CustomLocationDialog> {
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _addressController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _latitudeController = TextEditingController(
      text: widget.currentLatitude?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.currentLongitude?.toString() ?? '',
    );
    _addressController = TextEditingController(
      text: widget.currentAddress ?? '',
    );
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getAddressFromCoordinates() async {
    final lat = double.tryParse(_latitudeController.text);
    final lng = double.tryParse(_longitudeController.text);

    if (lat == null || lng == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address = [
          placemark.street,
          placemark.subLocality,
          placemark.locality,
          placemark.administrativeArea,
          placemark.country,
        ].where((part) => part != null && part.isNotEmpty).join(', ');

        setState(() {
          _addressController.text = address;
        });
      }
    } catch (e) {
      // Manejar error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AlertDialog(
      title: Text(
        'Ubicación Personalizada',
        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Campo de latitud
          TextFormField(
            controller: _latitudeController,
            decoration: const InputDecoration(
              labelText: 'Latitud',
              hintText: 'Ej: -16.5000',
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          // Campo de longitud
          TextFormField(
            controller: _longitudeController,
            decoration: const InputDecoration(
              labelText: 'Longitud',
              hintText: 'Ej: -68.1500',
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          // Botón para obtener dirección
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isLoading ? null : _getAddressFromCoordinates,
              icon: _isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.search),
              label: Text(_isLoading ? 'Buscando...' : 'Obtener Dirección'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Campo de dirección
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Dirección',
              hintText: 'Ingresa la dirección manualmente',
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final lat = double.tryParse(_latitudeController.text);
            final lng = double.tryParse(_longitudeController.text);
            final address = _addressController.text.trim();

            if (lat != null && lng != null) {
              Navigator.pop(context, {
                'latitude': lat,
                'longitude': lng,
                'address': address.isNotEmpty
                    ? address
                    : 'Lat: $lat, Long: $lng',
              });
            }
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
