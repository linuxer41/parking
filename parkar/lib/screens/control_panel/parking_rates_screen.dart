import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'base_detail_screen.dart';

/// Modelo para representar una tarifa de estacionamiento
class ParkingRate {
  final int id;
  final String vehicleType;
  final double hourlyRate;
  final double dailyRate;
  final double monthlyRate;
  final bool isActive;

  ParkingRate({
    required this.id,
    required this.vehicleType,
    required this.hourlyRate,
    required this.dailyRate,
    required this.monthlyRate,
    this.isActive = true,
  });
}

/// Pantalla para gestionar las tarifas de estacionamiento
class ParkingRatesScreen extends StatefulWidget {
  final int parkingId;
  final String parkingName;

  const ParkingRatesScreen({
    super.key,
    required this.parkingId,
    required this.parkingName,
  });

  @override
  State<ParkingRatesScreen> createState() => _ParkingRatesScreenState();
}

class _ParkingRatesScreenState extends State<ParkingRatesScreen> {
  bool _isLoading = false;
  List<ParkingRate> _rates = [];
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  // Cargar tarifas (simulación)
  Future<void> _loadRates() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    // Simulación de carga de datos
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _rates = [
          ParkingRate(
            id: 1,
            vehicleType: 'Automóvil',
            hourlyRate: 2.50,
            dailyRate: 15.00,
            monthlyRate: 300.00,
            isActive: true,
          ),
          ParkingRate(
            id: 2,
            vehicleType: 'Motocicleta',
            hourlyRate: 1.00,
            dailyRate: 8.00,
            monthlyRate: 150.00,
            isActive: true,
          ),
          ParkingRate(
            id: 3,
            vehicleType: 'Camión',
            hourlyRate: 4.00,
            dailyRate: 25.00,
            monthlyRate: 500.00,
            isActive: true,
          ),
        ];
        _isLoading = false;
      });
    }
  }

  // Mostrar diálogo para editar o agregar tarifa
  void _showRateDialog({ParkingRate? rate}) {
    final isEditing = rate != null;
    final vehicleTypeController =
        TextEditingController(text: rate?.vehicleType ?? '');
    final hourlyRateController =
        TextEditingController(text: rate?.hourlyRate.toString() ?? '');
    final dailyRateController =
        TextEditingController(text: rate?.dailyRate.toString() ?? '');
    final monthlyRateController =
        TextEditingController(text: rate?.monthlyRate.toString() ?? '');
    bool isActive = rate?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar tarifa' : 'Nueva tarifa'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: vehicleTypeController,
                decoration: const InputDecoration(
                  labelText: 'Tipo de vehículo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: hourlyRateController,
                decoration: const InputDecoration(
                  labelText: 'Tarifa por hora (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dailyRateController,
                decoration: const InputDecoration(
                  labelText: 'Tarifa diaria (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: monthlyRateController,
                decoration: const InputDecoration(
                  labelText: 'Tarifa mensual (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) => SwitchListTile(
                  title: const Text('Activa'),
                  value: isActive,
                  onChanged: (value) {
                    setState(() {
                      isActive = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              // Validar campos
              if (vehicleTypeController.text.isEmpty ||
                  hourlyRateController.text.isEmpty ||
                  dailyRateController.text.isEmpty ||
                  monthlyRateController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor completa todos los campos'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              // Crear o actualizar tarifa
              final newRate = ParkingRate(
                id: rate?.id ?? DateTime.now().millisecondsSinceEpoch,
                vehicleType: vehicleTypeController.text,
                hourlyRate: double.parse(hourlyRateController.text),
                dailyRate: double.parse(dailyRateController.text),
                monthlyRate: double.parse(monthlyRateController.text),
                isActive: isActive,
              );

              setState(() {
                if (isEditing) {
                  // Actualizar tarifa existente
                  _rates =
                      _rates.map((r) => r.id == rate.id ? newRate : r).toList();
                } else {
                  // Agregar nueva tarifa
                  _rates.add(newRate);
                }
              });

              Navigator.of(context).pop();
            },
            child: Text(isEditing ? 'Actualizar' : 'Agregar'),
          ),
        ],
      ),
    );
  }

  // Eliminar tarifa
  void _deleteRate(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar tarifa'),
        content:
            const Text('¿Estás seguro de que deseas eliminar esta tarifa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _rates.removeWhere((rate) => rate.id == id);
              });
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // Mostrar diálogo para gestionar suscripciones
  void _showSubscriptionDialog(ParkingRate rate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Suscripción mensual - ${rate.vehicleType}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Precio mensual'),
                subtitle: Text('\$${rate.monthlyRate.toStringAsFixed(2)}'),
                leading: const Icon(Icons.calendar_month),
              ),
              const SizedBox(height: 16),
              const Text(
                'Beneficios de la suscripción mensual:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const ListTile(
                leading: Icon(Icons.check_circle_outline, color: Colors.green),
                title: Text('Acceso ilimitado 24/7'),
                dense: true,
              ),
              const ListTile(
                leading: Icon(Icons.check_circle_outline, color: Colors.green),
                title: Text('Espacio garantizado'),
                dense: true,
              ),
              const ListTile(
                leading: Icon(Icons.check_circle_outline, color: Colors.green),
                title: Text('Ahorro significativo vs tarifa diaria'),
                dense: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              // Aquí iría la lógica para crear una nueva suscripción
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Suscripción creada correctamente'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Crear suscripción'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BaseDetailScreen(
      title: 'Tarifas de ${widget.parkingName}',
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRateDialog(),
        tooltip: 'Agregar tarifa',
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          // Lista de tarifas
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _rates.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.money_off_outlined,
                            size: 64,
                            color: colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay tarifas configuradas',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Presiona el botón + para agregar una tarifa',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      key: _refreshKey,
                      onRefresh: _loadRates,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _rates.length,
                        itemBuilder: (context, index) {
                          final rate = _rates[index];
                          return _buildRateCard(rate, colorScheme);
                        },
                      ),
                    ),
        ],
      ),
    );
  }

  // Construir tarjeta para cada tarifa
  Widget _buildRateCard(ParkingRate rate, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con tipo de vehículo y estado
            Row(
              children: [
                Icon(
                  _getVehicleIcon(rate.vehicleType),
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rate.vehicleType,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: rate.isActive
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    rate.isActive ? 'Activa' : 'Inactiva',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: rate.isActive
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Tarifas
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildRateInfo(
                  'Tarifa por hora',
                  '\$${rate.hourlyRate.toStringAsFixed(2)}',
                  Icons.access_time,
                  colorScheme,
                ),
                _buildRateInfo(
                  'Tarifa diaria',
                  '\$${rate.dailyRate.toStringAsFixed(2)}',
                  Icons.calendar_today,
                  colorScheme,
                ),
                _buildRateInfo(
                  'Tarifa mensual',
                  '\$${rate.monthlyRate.toStringAsFixed(2)}',
                  Icons.calendar_month,
                  colorScheme,
                  onTap: () => _showSubscriptionDialog(rate),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showSubscriptionDialog(rate),
                  icon: const Icon(Icons.card_membership),
                  label: const Text('Suscripciones'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showRateDialog(rate: rate),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _deleteRate(rate.id),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Eliminar'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget para mostrar información de tarifa
  Widget _buildRateInfo(
    String label,
    String value,
    IconData icon,
    ColorScheme colorScheme, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (onTap != null) ...[
                  const Spacer(),
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: colorScheme.primary,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Obtener icono según tipo de vehículo
  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'automóvil':
      case 'auto':
      case 'carro':
      case 'coche':
        return Icons.directions_car;
      case 'motocicleta':
      case 'moto':
        return Icons.motorcycle;
      case 'camión':
      case 'camion':
        return Icons.local_shipping;
      case 'bicicleta':
      case 'bici':
        return Icons.pedal_bike;
      default:
        return Icons.directions_car;
    }
  }
}
