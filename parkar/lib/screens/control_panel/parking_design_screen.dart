import 'package:flutter/material.dart';
import 'base_detail_screen.dart';
import '../../models/parking.dart';
import '../../services/parking_service.dart';

/// Modelo para representar un elemento en el diseño de estacionamiento
class ParkingDesignElement {
  final String id;
  final String type; // 'spot', 'wall', 'entrance', 'exit', 'path'
  final double x;
  final double y;
  final double width;
  final double height;
  final double rotation;
  final String? label;
  final String? spotType; // 'standard', 'handicap', 'electric', 'compact'

  ParkingDesignElement({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.rotation = 0.0,
    this.label,
    this.spotType,
  });
}

/// Pantalla para diseñar estacionamientos
class ParkingDesignScreen extends StatefulWidget {
  /// ID del estacionamiento a diseñar
  final int parkingId;

  /// Nombre del estacionamiento
  final String parkingName;

  /// Constructor
  const ParkingDesignScreen({
    super.key,
    required this.parkingId,
    required this.parkingName,
  });

  @override
  State<ParkingDesignScreen> createState() => _ParkingDesignScreenState();
}

class _ParkingDesignScreenState extends State<ParkingDesignScreen> {
  final ParkingService _parkingService = ParkingService();
  bool _isLoading = true;
  Parking? _parking;
  String? _error;
  List<ParkingDesignElement> _elements = [];
  String _selectedTool = 'select';
  ParkingDesignElement? _selectedElement;
  double _canvasScale = 1.0;
  Offset _canvasOffset = Offset.zero;
  bool _isDraggingCanvas = false;
  Offset? _lastFocalPoint;

  // Herramientas disponibles
  final List<Map<String, dynamic>> _tools = [
    {
      'id': 'select',
      'name': 'Seleccionar',
      'icon': Icons.pan_tool_outlined,
    },
    {
      'id': 'spot',
      'name': 'Espacio',
      'icon': Icons.local_parking,
    },
    {
      'id': 'wall',
      'name': 'Muro',
      'icon': Icons.border_style,
    },
    {
      'id': 'entrance',
      'name': 'Entrada',
      'icon': Icons.login,
    },
    {
      'id': 'exit',
      'name': 'Salida',
      'icon': Icons.logout,
    },
    {
      'id': 'path',
      'name': 'Camino',
      'icon': Icons.timeline,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadParkingDetails();
  }

  // Cargar detalles del estacionamiento
  Future<void> _loadParkingDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Obtener detalles del estacionamiento
      final parking = await _parkingService.getParkingById(widget.parkingId);

      if (mounted) {
        setState(() {
          _parking = parking;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar detalles: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    // Contenido principal del editor de diseño
    final designContent = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadParkingDetails,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              )
            : _buildDesignEditor(context);

    // En escritorio, mostrar el editor centrado sin panel lateral
    if (isDesktop && !_isLoading && _error == null) {
      return BaseDetailScreen(
        title: 'Diseñar ${widget.parkingName}',
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Editor centrado
            SizedBox(
              width: 900,
              child: designContent,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: () {
              // Implementar guardado de diseño
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Guardado de diseño no implementado'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: 'Guardar diseño',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadParkingDetails,
            tooltip: 'Actualizar',
          ),
        ],
      );
    }

    // En móvil o cuando hay error/cargando, mostrar solo el contenido principal
    return BaseDetailScreen(
      title: 'Diseñar ${widget.parkingName}',
      body: designContent,
      actions: [
        IconButton(
          icon: const Icon(Icons.save_outlined),
          onPressed: () {
            // Implementar guardado de diseño
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Guardado de diseño no implementado'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          tooltip: 'Guardar diseño',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _isLoading ? null : _loadParkingDetails,
          tooltip: 'Actualizar',
        ),
      ],
    );
  }

  // Construir el editor de diseño
  Widget _buildDesignEditor(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: colorScheme.surfaceContainerLowest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.design_services,
              size: 64,
              color: colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Editor de Diseño',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Aquí podrás diseñar el layout de tu estacionamiento. '
                'Usa las herramientas del panel lateral para agregar elementos.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Implementar inicio de diseño
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Función en desarrollo'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Comenzar diseño'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Construir el panel de herramientas
  Widget _buildToolsPanel(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: colorScheme.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Herramientas',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                _buildToolCategory(
                  context,
                  title: 'Espacios',
                  icon: Icons.local_parking,
                  color: Colors.blue,
                  tools: [
                    _buildToolItem(
                      context,
                      title: 'Espacio estándar',
                      icon: Icons.directions_car_outlined,
                      onTap: () => _handleToolTap('standard_spot'),
                    ),
                    _buildToolItem(
                      context,
                      title: 'Espacio para discapacitados',
                      icon: Icons.accessible_outlined,
                      onTap: () => _handleToolTap('handicap_spot'),
                    ),
                    _buildToolItem(
                      context,
                      title: 'Espacio para motos',
                      icon: Icons.motorcycle_outlined,
                      onTap: () => _handleToolTap('motorcycle_spot'),
                    ),
                  ],
                ),
                _buildToolCategory(
                  context,
                  title: 'Señalización',
                  icon: Icons.signpost_outlined,
                  color: Colors.orange,
                  tools: [
                    _buildToolItem(
                      context,
                      title: 'Flecha',
                      icon: Icons.arrow_forward,
                      onTap: () => _handleToolTap('arrow'),
                    ),
                    _buildToolItem(
                      context,
                      title: 'Señal de entrada',
                      icon: Icons.login,
                      onTap: () => _handleToolTap('entrance'),
                    ),
                    _buildToolItem(
                      context,
                      title: 'Señal de salida',
                      icon: Icons.logout,
                      onTap: () => _handleToolTap('exit'),
                    ),
                  ],
                ),
                _buildToolCategory(
                  context,
                  title: 'Instalaciones',
                  icon: Icons.elevator_outlined,
                  color: Colors.green,
                  tools: [
                    _buildToolItem(
                      context,
                      title: 'Ascensor',
                      icon: Icons.elevator,
                      onTap: () => _handleToolTap('elevator'),
                    ),
                    _buildToolItem(
                      context,
                      title: 'Escaleras',
                      icon: Icons.stairs_outlined,
                      onTap: () => _handleToolTap('stairs'),
                    ),
                    _buildToolItem(
                      context,
                      title: 'Baños',
                      icon: Icons.wc_outlined,
                      onTap: () => _handleToolTap('bathroom'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Construir categoría de herramientas
  Widget _buildToolCategory(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> tools,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...tools,
          ],
        ),
      ),
    );
  }

  // Construir elemento de herramienta
  Widget _buildToolItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: colorScheme.primary,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium,
      ),
      dense: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onTap: onTap,
    );
  }

  // Manejar tap en herramienta
  void _handleToolTap(String toolId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Seleccionada herramienta: $toolId'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

/// Painter para dibujar la cuadrícula de fondo
class GridPainter extends CustomPainter {
  final Offset offset;
  final double scale;
  final double gridSize;
  final Color gridColor;

  GridPainter({
    required this.offset,
    required this.scale,
    required this.gridSize,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;

    // Calcular los límites de la cuadrícula
    final scaledGridSize = gridSize * scale;
    final startX = (offset.dx % scaledGridSize) - scaledGridSize;
    final startY = (offset.dy % scaledGridSize) - scaledGridSize;
    final endX = size.width + scaledGridSize;
    final endY = size.height + scaledGridSize;

    // Dibujar líneas verticales
    for (double x = startX; x <= endX; x += scaledGridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Dibujar líneas horizontales
    for (double y = startY; y <= endY; y += scaledGridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
