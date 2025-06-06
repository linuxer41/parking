import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/vehicle_model.dart';
import '../../services/vehicle_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final VehicleService _vehicleService = VehicleService();
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;
  String _searchQuery = '';
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  
  // Para filtrar por tipo de vehículo
  String? _selectedVehicleType;
  final List<String> _vehicleTypes = ['Todos', 'Automóvil', 'Motocicleta', 'Camión'];
  
  // Para ordenar
  String _sortBy = 'date';
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // En una implementación real, obtendríamos los datos del servicio
      // Aquí estamos simulando datos para el ejemplo
      await Future.delayed(const Duration(milliseconds: 800));
      
      final now = DateTime.now();
      final vehicles = List.generate(50, (index) {
        final isExit = index % 3 == 0; // Algunos vehículos ya han salido
        final entryTime = now.subtract(Duration(hours: index + (index % 5), minutes: index * 7 % 60));
        final exitTime = isExit ? entryTime.add(Duration(hours: 1 + (index % 4), minutes: index * 11 % 60)) : null;
        final vehicleType = index % 5 == 0 ? 'Camión' : (index % 3 == 0 ? 'Motocicleta' : 'Automóvil');
        
        return Vehicle(
          id: 'VEH-${1000 + index}',
          licensePlate: 'ABC-${123 + index}',
          entryTime: entryTime,
          exitTime: exitTime,
          spotId: 'SPOT-${100 + (index % 20)}',
          type: vehicleType,
          ownerName: 'Cliente ${index + 1}',
          cost: isExit ? (10.0 + index % 30) : null,
        );
      });
      
      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar historial: $e')),
      );
    }
  }

  void _applyFilters() {
    setState(() {
      _isLoading = true;
    });
    
    // Filtrar vehículos según los criterios seleccionados
    List<Vehicle> filteredVehicles = _vehicles.where((vehicle) {
      // Filtrar por búsqueda de texto (placa o nombre)
      bool matchesSearch = _searchQuery.isEmpty || 
          vehicle.licensePlate.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (vehicle.ownerName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      
      // Filtrar por rango de fechas
      bool matchesDateRange = true;
      if (_selectedStartDate != null) {
        matchesDateRange = matchesDateRange && vehicle.entryTime.isAfter(_selectedStartDate!);
      }
      if (_selectedEndDate != null) {
        // Añadir un día completo para incluir el día seleccionado
        final endDatePlusDay = _selectedEndDate!.add(const Duration(days: 1));
        matchesDateRange = matchesDateRange && vehicle.entryTime.isBefore(endDatePlusDay);
      }
      
      // Filtrar por tipo de vehículo
      bool matchesType = _selectedVehicleType == null || 
          _selectedVehicleType == 'Todos' || 
          vehicle.type == _selectedVehicleType;
      
      return matchesSearch && matchesDateRange && matchesType;
    }).toList();
    
    // Ordenar la lista filtrada
    filteredVehicles.sort((a, b) {
      if (_sortBy == 'date') {
        return _sortAscending 
            ? a.entryTime.compareTo(b.entryTime) 
            : b.entryTime.compareTo(a.entryTime);
      } else if (_sortBy == 'plate') {
        return _sortAscending 
            ? a.licensePlate.compareTo(b.licensePlate) 
            : b.licensePlate.compareTo(a.licensePlate);
      } else if (_sortBy == 'cost') {
        final aCost = a.cost ?? 0.0;
        final bCost = b.cost ?? 0.0;
        return _sortAscending ? aCost.compareTo(bCost) : bCost.compareTo(aCost);
      }
      return 0;
    });
    
    // Actualizar la lista filtrada después de un breve retraso para mostrar el efecto de carga
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _vehicles = filteredVehicles;
          _isLoading = false;
        });
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedStartDate = null;
      _selectedEndDate = null;
      _selectedVehicleType = null;
    });
    _loadVehicles();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: _selectedStartDate ?? DateTime.now().subtract(const Duration(days: 7)),
      end: _selectedEndDate ?? DateTime.now(),
    );
    
    final newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Vehículos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVehicles,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(theme),
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _vehicles.isEmpty 
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history_toggle_off,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No se encontraron registros',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
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
                    : _buildVehicleList(theme),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilters(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar por placa o nombre',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      if (value.isEmpty || value.length > 2) {
                        _applyFilters();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.date_range, size: 16),
                  label: Text(
                    _selectedStartDate == null ? 'Fecha' : 'Fechas',
                    style: const TextStyle(fontSize: 14),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  onPressed: () => _selectDateRange(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Selector de tipo de vehículo
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Tipo de vehículo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    value: _selectedVehicleType,
                    hint: const Text('Todos'),
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
                const SizedBox(width: 8),
                // Selector de ordenamiento
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Ordenar por',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    value: _sortBy,
                    items: const [
                      DropdownMenuItem(value: 'date', child: Text('Fecha')),
                      DropdownMenuItem(value: 'plate', child: Text('Placa')),
                      DropdownMenuItem(value: 'cost', child: Text('Costo')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _sortBy = value;
                        });
                        _applyFilters();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Botón para invertir orden
                IconButton(
                  icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                  tooltip: _sortAscending ? 'Ascendente' : 'Descendente',
                  onPressed: () {
                    setState(() {
                      _sortAscending = !_sortAscending;
                    });
                    _applyFilters();
                  },
                ),
              ],
            ),
            if (_selectedStartDate != null || _selectedEndDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      _getDateRangeText(),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedStartDate = null;
                          _selectedEndDate = null;
                        });
                        _applyFilters();
                      },
                      child: const Text('Limpiar fechas'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  String _getDateRangeText() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    if (_selectedStartDate != null && _selectedEndDate != null) {
      return '${dateFormat.format(_selectedStartDate!)} - ${dateFormat.format(_selectedEndDate!)}';
    } else if (_selectedStartDate != null) {
      return 'Desde ${dateFormat.format(_selectedStartDate!)}';
    } else if (_selectedEndDate != null) {
      return 'Hasta ${dateFormat.format(_selectedEndDate!)}';
    }
    return '';
  }
  
  Widget _buildVehicleList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = _vehicles[index];
        final isActive = vehicle.exitTime == null;
        
        // Calcular duración
        String durationText = '';
        if (vehicle.exitTime != null) {
          final duration = vehicle.exitTime!.difference(vehicle.entryTime);
          final hours = duration.inHours;
          final minutes = duration.inMinutes % 60;
          durationText = '${hours}h ${minutes}m';
        } else {
          final duration = DateTime.now().difference(vehicle.entryTime);
          final hours = duration.inHours;
          final minutes = duration.inMinutes % 60;
          durationText = '${hours}h ${minutes}m (Activo)';
        }
        
        // Formato de fechas
        final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isActive 
                ? BorderSide(color: theme.colorScheme.primary.withOpacity(0.3), width: 1) 
                : BorderSide.none,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showVehicleDetails(vehicle),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive 
                              ? theme.colorScheme.primary 
                              : Colors.grey[600],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          vehicle.licensePlate,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        vehicle.type,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (vehicle.cost != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '\$${vehicle.cost!.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: theme.colorScheme.tertiary,
                              fontWeight: FontWeight.bold,
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
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFormat.format(vehicle.entryTime),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Salida',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              vehicle.exitTime != null 
                                  ? dateFormat.format(vehicle.exitTime!) 
                                  : 'En curso',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: vehicle.exitTime == null 
                                    ? theme.colorScheme.primary 
                                    : null,
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
                          const Icon(Icons.access_time, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            durationText,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.local_parking, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Espacio: ${vehicle.spotId}',
                            style: const TextStyle(
                              fontSize: 14,
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
      },
    );
  }
  
  void _showVehicleDetails(Vehicle vehicle) {
    // Formato de fechas para la vista detallada
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
    
    // Calcular duración
    final duration = vehicle.exitTime != null 
        ? vehicle.exitTime!.difference(vehicle.entryTime)
        : DateTime.now().difference(vehicle.entryTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final durationText = '$hours horas y $minutes minutos';
    
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
                    'Detalles del Vehículo',
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
              
              // ID y placa
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _detailItem(
                      label: 'ID',
                      value: vehicle.id,
                      icon: Icons.confirmation_number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _detailItem(
                      label: 'Placa',
                      value: vehicle.licensePlate,
                      icon: Icons.directions_car,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Tipo y propietario
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _detailItem(
                      label: 'Tipo',
                      value: vehicle.type,
                      icon: Icons.category,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _detailItem(
                      label: 'Propietario',
                      value: vehicle.ownerName ?? 'No registrado',
                      icon: Icons.person,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Hora de entrada y salida
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _detailItem(
                      label: 'Entrada',
                      value: dateFormat.format(vehicle.entryTime),
                      icon: Icons.login,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _detailItem(
                      label: 'Salida',
                      value: vehicle.exitTime != null 
                          ? dateFormat.format(vehicle.exitTime!) 
                          : 'En curso',
                      icon: Icons.logout,
                      color: vehicle.exitTime == null 
                          ? Theme.of(context).colorScheme.primary 
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Duración y espacio
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _detailItem(
                      label: 'Duración',
                      value: durationText,
                      icon: Icons.access_time,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _detailItem(
                      label: 'Espacio',
                      value: vehicle.spotId,
                      icon: Icons.local_parking,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Costo
              if (vehicle.cost != null)
                _detailItem(
                  label: 'Costo Total',
                  value: '\$${vehicle.cost!.toStringAsFixed(2)}',
                  icon: Icons.attach_money,
                  color: Theme.of(context).colorScheme.tertiary,
                  isBold: true,
                  isLarge: true,
                ),
              
              const SizedBox(height: 24),
              
              // Botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (vehicle.exitTime != null)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.receipt_long, size: 16),
                      label: const Text('Ver Factura'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        // Implementar visualización de factura
                      },
                    ),
                  
                  if (vehicle.exitTime == null)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.logout, size: 16),
                      label: const Text('Registrar Salida'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        // Implementar registro de salida
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
        Icon(
          icon, 
          size: isLarge ? 20 : 16, 
          color: color ?? Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
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
} 