import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/access_model.dart';
import '../../services/parking_service.dart';
import '../../state/app_state_container.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  final ParkingService _parkingService = ParkingService();

  // Data lists
  final List<AccessModel> _activeAccesses = [];
  final List<AccessModel> _completedAccesses = [];

  // Combined list for display
  List<AccessModel> _displayItems = [];

  bool _isLoading = true;
  String _searchQuery = '';
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  // For filtering by type
  String? _selectedVehicleType;
  final List<String> _vehicleTypes = [
    'Todos',
    'Bicicleta',
    'Automóvil',
    'Motocicleta',
    'Camión',
  ];

  // For sorting
  final String _sortBy = 'date';
  final bool _sortAscending = false;

  // Tab controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appState = AppStateContainer.of(context);
      final parkingId = appState.currentParking?.id;

      if (parkingId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Load active and completed accesses
      final activeAccesses = [];
      final completedAccesses = [];

      setState(() {
        // _activeAccesses = activeAccesses;
        // _completedAccesses = completedAccesses;
        _isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar historial: $e')));
    }
  }

  void _applyFilters() {
    List<AccessModel> filteredItems = [];

    // Get items based on selected tab
    switch (_tabController.index) {
      case 0: // All
        filteredItems = [..._activeAccesses, ..._completedAccesses];
        break;
      case 1: // Active
        filteredItems = [..._activeAccesses];
        break;
      case 2: // Completed
        filteredItems = [..._completedAccesses];
        break;
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredItems = filteredItems.where((access) {
        return access.vehicle.plate.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            access.entryEmployee.name.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            access.spot.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply date range filter
    if (_selectedStartDate != null || _selectedEndDate != null) {
      filteredItems = filteredItems.where((access) {
        DateTime itemDate = access.entryTime;

        bool matchesStart =
            _selectedStartDate == null || itemDate.isAfter(_selectedStartDate!);
        bool matchesEnd =
            _selectedEndDate == null ||
            itemDate.isBefore(_selectedEndDate!.add(const Duration(days: 1)));

        return matchesStart && matchesEnd;
      }).toList();
    }

    // Apply vehicle type filter
    if (_selectedVehicleType != null && _selectedVehicleType != 'Todos') {
      filteredItems = filteredItems.where((access) {
        String vehicleType = access.vehicle.type;
        return _getVehicleTypeName(vehicleType) == _selectedVehicleType;
      }).toList();
    }

    // Sort items
    filteredItems.sort((a, b) {
      if (_sortBy == 'date') {
        return _sortAscending
            ? a.entryTime.compareTo(b.entryTime)
            : b.entryTime.compareTo(a.entryTime);
      } else if (_sortBy == 'plate') {
        return _sortAscending
            ? a.vehicle.plate.compareTo(b.vehicle.plate)
            : b.vehicle.plate.compareTo(a.vehicle.plate);
      }
      return 0;
    });

    setState(() {
      _displayItems = filteredItems;
    });
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedStartDate = null;
      _selectedEndDate = null;
      _selectedVehicleType = null;
    });
    _applyFilters();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start:
          _selectedStartDate ??
          DateTime.now().subtract(const Duration(days: 7)),
      end: _selectedEndDate ?? DateTime.now(),
    );

    final newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: Theme.of(context).colorScheme),
          child: child!,
        );
      },
    );

    if (newDateRange != null) {
      setState(() {
        _selectedStartDate = newDateRange.start;
        _selectedEndDate = newDateRange.end;
      });
      _applyFilters();
    }
  }

  String _getVehicleTypeName(String type) {
    switch (type.toLowerCase()) {
      case 'bicycle':
      case 'bicicleta':
        return 'Bicicleta';
      case 'car':
      case 'automovil':
      case 'sedan':
        return 'Automóvil';
      case 'motorcycle':
      case 'motocicleta':
        return 'Motocicleta';
      case 'truck':
      case 'camion':
        return 'Camión';
      default:
        return 'Automóvil';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width <= 400;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registros',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tab bar
            Padding(
              padding: EdgeInsets.fromLTRB(
                isSmallScreen ? 12 : 16,
                8,
                isSmallScreen ? 12 : 16,
                0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Todos'),
                    Tab(text: 'Activos'),
                    Tab(text: 'Completados'),
                  ],
                  onTap: (index) {
                    _applyFilters();
                  },
                  indicatorColor: colorScheme.primary,
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                ),
              ),
            ),

            // Filters
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar por placa, empleado o espacio',
                          prefixIcon: Icon(
                            Icons.search,
                            color: colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                        onChanged: (value) {
                          _searchQuery = value;
                          if (value.isEmpty || value.length > 2) {
                            _applyFilters();
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Date and type filters
                    Row(
                      children: [
                        // Date selector
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.date_range, size: 16),
                            label: Text(
                              _selectedStartDate == null ? 'Fecha' : 'Fechas',
                              style: const TextStyle(fontSize: 14),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color: colorScheme.outlineVariant.withOpacity(
                                  0.3,
                                ),
                                width: 0.5,
                              ),
                            ),
                            onPressed: () => _selectDateRange(context),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Vehicle type selector
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.outlineVariant.withOpacity(
                                  0.3,
                                ),
                                width: 0.5,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: const Text('Tipo vehículo'),
                                value: _selectedVehicleType,
                                items: _vehicleTypes.map((type) {
                                  return DropdownMenuItem<String>(
                                    value: type == 'Todos' ? null : type,
                                    child: Text(type),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedVehicleType = value;
                                  });
                                  _applyFilters();
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Date range info
                    if (_selectedStartDate != null || _selectedEndDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _getDateRangeText(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedStartDate = null;
                                  _selectedEndDate = null;
                                });
                                _applyFilters();
                              },
                              child: const Text('Limpiar'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // List
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    )
                  : _displayItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_car,
                            size: 80,
                            color: colorScheme.onSurfaceVariant.withOpacity(
                              0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No se encontraron registros',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _resetFilters,
                            child: const Text('Limpiar filtros'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: colorScheme.primary,
                      child: _buildItemList(theme),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _displayItems.length,
      itemBuilder: (context, index) {
        final access = _displayItems[index];
        return _buildAccessCard(theme, access);
      },
    );
  }

  Widget _buildAccessCard(ThemeData theme, AccessModel access) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final isActive = access.isActive;
    final durationText = access.formattedDuration;
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 1,
      shadowColor: colorScheme.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive
              ? colorScheme.primary.withOpacity(0.2)
              : colorScheme.outlineVariant.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showAccessDetails(access),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? colorScheme.primary
                          : colorScheme.secondary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      access.vehicle.plate,
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getVehicleTypeName(access.vehicle.type),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        'ACTIVO',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    )
                  else if (access.amount != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: colorScheme.tertiary.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        '\$${access.amount!.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: colorScheme.tertiary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Entrada',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(access.entryTime),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isActive ? 'Espacio' : 'Salida',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isActive
                              ? access.spot.name
                              : access.exitTime != null
                              ? dateFormat.format(access.exitTime!)
                              : 'Pendiente',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        durationText,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        access.entryEmployee.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
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
    );
  }

  void _showAccessDetails(AccessModel access) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
    final isActive = access.isActive;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isActive
                        ? 'Detalles de Acceso Activo'
                        : 'Detalles de Acceso Completado',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Access number and plate
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _detailItem(
                      label: 'Número',
                      value: access.number.toString(),
                      icon: Icons.confirmation_number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _detailItem(
                      label: 'Placa',
                      value: access.vehicle.plate,
                      icon: Icons.directions_car,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Vehicle type and spot
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _detailItem(
                      label: 'Tipo',
                      value: _getVehicleTypeName(access.vehicle.type),
                      icon: Icons.category,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _detailItem(
                      label: 'Espacio',
                      value: access.spot.name,
                      icon: Icons.local_parking,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Entry time and employee
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _detailItem(
                      label: 'Entrada',
                      value: dateFormat.format(access.entryTime),
                      icon: Icons.login,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _detailItem(
                      label: 'Empleado',
                      value: access.entryEmployee.name,
                      icon: Icons.person,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Duration and parking
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _detailItem(
                      label: 'Duración',
                      value: access.formattedDuration,
                      icon: Icons.access_time,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _detailItem(
                      label: 'Estacionamiento',
                      value: access.parking.name,
                      icon: Icons.local_parking,
                    ),
                  ),
                ],
              ),

              // Show exit information if completed
              if (!isActive && access.exitTime != null) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _detailItem(
                        label: 'Salida',
                        value: dateFormat.format(access.exitTime!),
                        icon: Icons.logout,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _detailItem(
                        label: 'Monto',
                        value: access.amount != null
                            ? '\$${access.amount!.toStringAsFixed(2)}'
                            : 'N/A',
                        icon: Icons.attach_money,
                        color: Theme.of(context).colorScheme.tertiary,
                        isBold: true,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.receipt_long, size: 16),
                    label: Text(isActive ? 'Imprimir Ticket' : 'Ver Factura'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Implement ticket/invoice printing
                    },
                  ),
                  if (isActive)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.logout, size: 16),
                      label: const Text('Registrar Salida'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Navigate to exit registration
                      },
                    )
                  else
                    ElevatedButton.icon(
                      icon: const Icon(Icons.print, size: 16),
                      label: const Text('Imprimir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Implement printing
                      },
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailItem({
    required String label,
    required String value,
    required IconData icon,
    Color? color,
    bool isBold = false,
    bool isLarge = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: isLarge ? 20 : 16, color: color ?? Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: isLarge ? 18 : 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDateRangeText() {
    if (_selectedStartDate == null && _selectedEndDate == null) {
      return 'Selecciona una fecha';
    } else if (_selectedStartDate == null) {
      return 'Desde ${DateFormat('dd/MM/yyyy').format(_selectedEndDate!)}';
    } else if (_selectedEndDate == null) {
      return 'Desde ${DateFormat('dd/MM/yyyy').format(_selectedStartDate!)}';
    } else {
      return '${DateFormat('dd/MM/yyyy').format(_selectedStartDate!)} - ${DateFormat('dd/MM/yyyy').format(_selectedEndDate!)}';
    }
  }
}
