import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/parking_model.dart';
import '../../services/parking_service.dart';
import '../../state/app_state_container.dart';
import '../../widgets/page_layout.dart';

/// Pantalla para gestionar las tarifas de estacionamiento
class ParkingRatesScreen extends StatefulWidget {
  final String parkingId;
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
  late ParkingService _parkingService;
  bool _isLoading = true;
  ParkingDetailedModel? _parking;
  List<RateModel> _rates = [];
  String? _error;
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _parkingService = AppStateContainer.di(context).resolve<ParkingService>();
    _loadRates();
  }

  // Cargar tarifas desde la API
  Future<void> _loadRates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Obtener detalles del parking que incluyen las tarifas
      final parking = await _parkingService.getParkingDetailed(
        widget.parkingId.toString(),
      );

      if (mounted) {
        setState(() {
          _parking = parking;
          _rates = parking.rates ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar tarifas: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  // Refrescar datos
  Future<void> _refreshRates() async {
    await _loadRates();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Contenido principal
    final content = SafeArea(
      child: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando tarifas...',
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
                      Icons.error_outline,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar',
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
                    FilledButton.icon(
                      onPressed: _refreshRates,
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
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshRates,
              child: _buildRatesContent(context),
            ),
    );

    return PageLayout(
      title: 'Tarifas',
      body: content,
      actions: [
        TextButton.icon(
          onPressed: _showRateDialog,
          icon: Icon(Icons.add, size: 18, color: colorScheme.primary),
          label: Text(
            'Agregar',
            style: textTheme.labelMedium?.copyWith(color: colorScheme.primary),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildRatesContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (_rates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.attach_money_outlined,
                size: 64,
                color: colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No hay tarifas configuradas',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Agrega tarifas para configurar los precios del estacionamiento',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _showRateDialog,
                icon: const Icon(Icons.add),
                label: const Text('Agregar Tarifa'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        // Header con información
        Card(
          margin: const EdgeInsets.only(bottom: 24),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 24,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Configuración de Tarifas',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Gestiona los precios para diferentes tipos de vehículos y períodos de tiempo',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Lista de tarifas
        ..._rates.map((rate) => _buildRateCard(context, rate)).toList(),

        // Espacio al final
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRateCard(BuildContext context, RateModel rate) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del card
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rate.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getVehicleCategoryName(rate.vehicleCategory),
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Estado activo/inactivo
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: rate.isActive
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    rate.isActive ? 'Activa' : 'Inactiva',
                    style: textTheme.bodySmall?.copyWith(
                      color: rate.isActive
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Botón editar
                IconButton(
                  onPressed: () => _showRateDialog(rate: rate),
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  tooltip: 'Editar tarifa',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Precios
            Row(
              children: [
                Expanded(
                  child: _buildPriceItem(
                    context,
                    'Hora',
                    '\$${rate.hourly.toStringAsFixed(2)}',
                    Icons.schedule,
                  ),
                ),
                Expanded(
                  child: _buildPriceItem(
                    context,
                    'Día',
                    '\$${rate.daily.toStringAsFixed(2)}',
                    Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _buildPriceItem(
                    context,
                    'Semana',
                    '\$${rate.weekly.toStringAsFixed(2)}',
                    Icons.view_week,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPriceItem(
                    context,
                    'Mes',
                    '\$${rate.monthly.toStringAsFixed(2)}',
                    Icons.calendar_month,
                  ),
                ),
                Expanded(
                  child: _buildPriceItem(
                    context,
                    'Año',
                    '\$${rate.yearly.toStringAsFixed(2)}',
                    Icons.calendar_month,
                  ),
                ),
                Expanded(
                  child: _buildPriceItem(
                    context,
                    'Tolerancia',
                    '${rate.tolerance} min',
                    Icons.timer,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(height: 4),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  String _getVehicleCategoryName(int category) {
    switch (category) {
      case 0:
        return 'Bicicleta';
      case 1:
        return 'Moto';
      case 2:
        return 'Vehículo';
      case 3:
        return 'Camión';
      default:
        return 'Desconocido';
    }
  }

  // Mostrar diálogo para editar o agregar tarifa
  void _showRateDialog({RateModel? rate}) {
    final isEditing = rate != null;
    final nameController = TextEditingController(text: rate?.name ?? '');
    final hourlyRateController = TextEditingController(
      text: rate?.hourly.toString() ?? '',
    );
    final dailyRateController = TextEditingController(
      text: rate?.daily.toString() ?? '',
    );
    final weeklyRateController = TextEditingController(
      text: rate?.weekly.toString() ?? '',
    );
    final monthlyRateController = TextEditingController(
      text: rate?.monthly.toString() ?? '',
    );
    final yearlyRateController = TextEditingController(
      text: rate?.yearly.toString() ?? '',
    );
    final toleranceController = TextEditingController(
      text: rate?.tolerance.toString() ?? '15',
    );

    bool isActive = rate?.isActive ?? true;

    // Lista de categorías de vehículos
    final List<Map<String, dynamic>> vehicleCategories = [
      {'value': 0, 'label': 'Bicicleta'},
      {'value': 1, 'label': 'Moto'},
      {'value': 2, 'label': 'Vehículo'},
      {'value': 3, 'label': 'Camión'},
    ];
    int selectedCategory = rate?.vehicleCategory ?? 2;

    showDialog(
      context: context,
      builder: (context) => _RateDialog(
        isEditing: isEditing,
        nameController: nameController,
        vehicleCategories: vehicleCategories,
        selectedCategory: selectedCategory,
        hourlyRateController: hourlyRateController,
        dailyRateController: dailyRateController,
        weeklyRateController: weeklyRateController,
        monthlyRateController: monthlyRateController,
        yearlyRateController: yearlyRateController,
        toleranceController: toleranceController,
        isActive: isActive,
        onSave: () async {
          await _saveRate(
            isEditing: isEditing,
            rate: rate,
            nameController: nameController,
            selectedCategory: selectedCategory,
            hourlyRateController: hourlyRateController,
            dailyRateController: dailyRateController,
            weeklyRateController: weeklyRateController,
            monthlyRateController: monthlyRateController,
            yearlyRateController: yearlyRateController,
            toleranceController: toleranceController,
            isActive: isActive,
          );
        },
      ),
    );
  }

  Future<void> _saveRate({
    required bool isEditing,
    RateModel? rate,
    required TextEditingController nameController,
    required int selectedCategory,
    required TextEditingController hourlyRateController,
    required TextEditingController dailyRateController,
    required TextEditingController weeklyRateController,
    required TextEditingController monthlyRateController,
    required TextEditingController yearlyRateController,
    required TextEditingController toleranceController,
    required bool isActive,
  }) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Validar campos requeridos
    if (nameController.text.isEmpty ||
        hourlyRateController.text.isEmpty ||
        dailyRateController.text.isEmpty ||
        weeklyRateController.text.isEmpty ||
        monthlyRateController.text.isEmpty ||
        yearlyRateController.text.isEmpty ||
        toleranceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor completa todos los campos'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    try {
      // Crear nueva tarifa
      final newRate = RateModel(
        id: isEditing
            ? rate!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text,
        vehicleCategory: selectedCategory,
        tolerance: int.tryParse(toleranceController.text) ?? 15,
        hourly: double.parse(hourlyRateController.text),
        daily: double.parse(dailyRateController.text),
        weekly: double.parse(weeklyRateController.text),
        monthly: double.parse(monthlyRateController.text),
        yearly: double.parse(yearlyRateController.text),
        isActive: isActive,
      );

      // Actualizar lista de tarifas
      final updatedRates = List<RateModel>.from(_rates);

      if (isEditing) {
        // Actualizar tarifa existente
        final index = updatedRates.indexWhere((r) => r.id == rate!.id);
        if (index >= 0) {
          updatedRates[index] = newRate;
        }
      } else {
        // Agregar nueva tarifa
        updatedRates.add(newRate);
      }

      // Actualizar el parking con las nuevas tarifas
      final updateModel = ParkingUpdateModel(rates: updatedRates);

      await _parkingService.updateParking(
        widget.parkingId.toString(),
        updateModel,
      );

      // Cerrar diálogo y refrescar
      Navigator.of(context).pop();
      await _refreshRates();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Tarifa actualizada correctamente'
                : 'Tarifa agregada correctamente',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: colorScheme.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar tarifa: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }
}

// Diálogo modernizado para editar/agregar tarifas
class _RateDialog extends StatefulWidget {
  final bool isEditing;
  final TextEditingController nameController;
  final List<Map<String, dynamic>> vehicleCategories;
  final int selectedCategory;
  final TextEditingController hourlyRateController;
  final TextEditingController dailyRateController;
  final TextEditingController weeklyRateController;
  final TextEditingController monthlyRateController;
  final TextEditingController yearlyRateController;
  final TextEditingController toleranceController;
  final bool isActive;
  final VoidCallback onSave;

  const _RateDialog({
    required this.isEditing,
    required this.nameController,
    required this.vehicleCategories,
    required this.selectedCategory,
    required this.hourlyRateController,
    required this.dailyRateController,
    required this.weeklyRateController,
    required this.monthlyRateController,
    required this.yearlyRateController,
    required this.toleranceController,
    required this.isActive,
    required this.onSave,
  });

  @override
  State<_RateDialog> createState() => _RateDialogState();
}

class _RateDialogState extends State<_RateDialog> {
  late int selectedCategory;
  late bool isActive;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.selectedCategory;
    isActive = widget.isActive;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AlertDialog(
      title: Text(
        widget.isEditing ? 'Editar Tarifa' : 'Nueva Tarifa',
        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nombre de tarifa
            _buildTextField(
              controller: widget.nameController,
              label: 'Nombre de tarifa',
              icon: Icons.label_outline,
            ),
            const SizedBox(height: 16),

            // Categoría de vehículo
            _buildDropdownField(
              label: 'Categoría de vehículo',
              icon: Icons.directions_car_outlined,
              value: selectedCategory,
              items: widget.vehicleCategories
                  .map(
                    (category) => DropdownMenuItem<int>(
                      value: category['value'] as int,
                      child: Text(category['label'] as String),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Precios en 2 columnas
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: widget.hourlyRateController,
                    label: 'Precio por hora',
                    icon: Icons.schedule,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefix: '\$',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: widget.dailyRateController,
                    label: 'Tarifa diaria',
                    icon: Icons.calendar_today,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefix: '\$',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: widget.weeklyRateController,
                    label: 'Tarifa semanal',
                    icon: Icons.view_week,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefix: '\$',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: widget.monthlyRateController,
                    label: 'Tarifa mensual',
                    icon: Icons.calendar_month,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefix: '\$',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: widget.yearlyRateController,
                    label: 'Tarifa anual',
                    icon: Icons.calendar_month,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefix: '\$',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: widget.toleranceController,
                    label: 'Tolerancia',
                    icon: Icons.timer,
                    keyboardType: TextInputType.number,
                    suffix: 'min',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Switch de estado activo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 30,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 60),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.power_settings_new_outlined,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tarifa activa',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Determina si la tarifa está disponible para uso',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isActive,
                    onChanged: (value) {
                      setState(() {
                        isActive = value;
                      });
                    },
                    activeColor: colorScheme.primary,
                    activeTrackColor: colorScheme.primaryContainer,
                    inactiveThumbColor: colorScheme.outline,
                    inactiveTrackColor: colorScheme.surfaceContainerHighest,
                  ),
                ],
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
          onPressed: widget.onSave,
          child: Text(widget.isEditing ? 'Actualizar' : 'Agregar'),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? prefix,
    String? suffix,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        prefixText: prefix,
        suffixText: suffix,
      ),
      keyboardType: keyboardType,
      style: textTheme.bodyMedium,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required int value,
    required List<DropdownMenuItem<int>> items,
    required ValueChanged<int?> onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return DropdownButtonFormField<int>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
      ),
      items: items,
      onChanged: onChanged,
      style: textTheme.bodyMedium,
    );
  }
}
