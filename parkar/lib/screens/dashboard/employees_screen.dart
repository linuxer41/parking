import 'package:flutter/material.dart';
import '../../models/employee_model.dart';
import '../../models/parking_model.dart';
import '../../services/parking_service.dart';
import '../../state/app_state_container.dart';
import '../../widgets/page_layout.dart';

/// Pantalla para gestionar empleados del estacionamiento
class EmployeesScreen extends StatefulWidget {
  final ParkingModel parking;
  final VoidCallback onSave;

  const EmployeesScreen({
    super.key,
    required this.parking,
    required this.onSave,
  });

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  bool _isLoading = false;
  String? _error;
  late List<EmployeeModel> _employees;
  late ParkingService _parkingService;

  @override
  void initState() {
    super.initState();
    _employees = List.from(widget.parking.employees ?? []);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _parkingService = AppStateContainer.di(context).resolve<ParkingService>();
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'Gestión de Empleados',
      body: _buildEmployeesContent(),
      actions: [
        TextButton.icon(
          onPressed: _addEmployee,
          icon: Icon(
            Icons.add,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          label: Text(
            'Agregar',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildEmployeesContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Cargando empleados...',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
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
            ],
          ),
        ),
      );
    }

    if (_employees.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64, color: colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                'No hay empleados registrados',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Agrega empleados para gestionar el estacionamiento',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _addEmployee,
                icon: const Icon(Icons.add),
                label: const Text('Agregar Empleado'),
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
                    Icon(Icons.people, size: 24, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Personal del Estacionamiento',
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
                  'Administra el personal que trabaja en el estacionamiento',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Lista de empleados
        ..._employees
            .map((employee) => _buildEmployeeCard(context, employee))
            .toList(),

        // Espacio al final
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEmployeeCard(BuildContext context, EmployeeModel employee) {
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
                // Avatar del empleado
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  radius: 24,
                  child: Text(
                    employee.name.substring(0, 1).toUpperCase(),
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Información del empleado
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          employee.role,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Botón editar
                IconButton(
                  onPressed: () => _editEmployee(employee),
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  tooltip: 'Editar empleado',
                ),
                // Botón eliminar
                IconButton(
                  onPressed: () => _deleteEmployee(employee),
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: colorScheme.error,
                  ),
                  tooltip: 'Eliminar empleado',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Información de contacto
            if (employee.email != null || employee.phone != null) ...[
              if (employee.email != null)
                _buildContactItem(
                  context,
                  'Email',
                  employee.email!,
                  Icons.email_outlined,
                ),
              if (employee.phone != null) ...[
                if (employee.email != null) const SizedBox(height: 8),
                _buildContactItem(
                  context,
                  'Teléfono',
                  employee.phone!,
                  Icons.phone_outlined,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addEmployee() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final roleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Añadir Empleado',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogTextField(
              controller: nameController,
              label: 'Nombre del empleado',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildDialogTextField(
              controller: emailController,
              label: 'Email (opcional)',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildDialogTextField(
              controller: phoneController,
              label: 'Teléfono (opcional)',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildDialogTextField(
              controller: roleController,
              label: 'Rol',
              icon: Icons.work_outline,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              // Implementar lógica para añadir empleado
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Funcionalidad en desarrollo'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: colorScheme.primary,
                ),
              );
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: keyboardType,
      style: textTheme.bodyMedium,
    );
  }

  void _editEmployee(EmployeeModel employee) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final roleController = TextEditingController(text: employee.role);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Editar Empleado',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Empleado: ${employee.name}',
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
            if (employee.email != null) ...[
              const SizedBox(height: 8),
              Text(
                'Email: ${employee.email}',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (employee.phone != null) ...[
              const SizedBox(height: 8),
              Text(
                'Teléfono: ${employee.phone}',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),
            _buildDialogTextField(
              controller: roleController,
              label: 'Rol',
              icon: Icons.work_outline,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              // Implementar lógica para actualizar empleado
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Funcionalidad en desarrollo'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: colorScheme.primary,
                ),
              );
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _deleteEmployee(EmployeeModel employee) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Eliminar Empleado',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              '¿Estás seguro de que quieres eliminar a ${employee.name}?',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Esta acción no se puede deshacer.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              // Implementar lógica para eliminar empleado
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Funcionalidad en desarrollo'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: colorScheme.primary,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
