import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/employee_model.dart';
import '../../models/parking_model.dart';
import '../../services/parking_service.dart';
import '../../services/employee_service.dart';
import '../../state/app_state_container.dart';
import '../../widgets/page_layout.dart';

/// Pantalla para gestionar empleados del estacionamiento
class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  late ParkingService _parkingService;
  late EmployeeService _employeeService;
  bool _isLoading = true;
  ParkingModel? _parking;
  late List<EmployeeModel> _employees;
  String? _error;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _parkingService = AppStateContainer.di(context).resolve<ParkingService>();
    _employeeService = EmployeeService();
    _loadParkingDetails();
  }

  // Cargar los detalles del estacionamiento
  Future<void> _loadParkingDetails() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final appState = AppStateContainer.of(context);
      final currentParking = appState.currentParking;

      if (currentParking == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = 'No hay estacionamiento seleccionado';
          });
        }
        return;
      }

      // Load full parking data like parking detail screen does
      final parking = await _parkingService.getParkingById(currentParking.id).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Tiempo de espera agotado'),
      );

      if (mounted) {
        setState(() {
          _parking = parking;
          _employees = List.from(parking.employees ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar datos del estacionamiento: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'Gestión de Empleados',
      body: _buildMainContent(),
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

  Widget _buildMainContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Error al cargar empleados',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loadParkingDetails,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return _buildEmployeesContent();
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
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    String? selectedRole;

    final roles = [
      {'value': 'owner', 'label': 'Propietario'},
      {'value': 'Administrador', 'label': 'Administrador'},
      {'value': 'Supervisor', 'label': 'Supervisor'},
      {'value': 'Operador', 'label': 'Operador'},
      {'value': 'Cajero', 'label': 'Cajero'},
      {'value': 'Guardia', 'label': 'Guardia de Seguridad'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        title: Text(
          'Añadir Empleado',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: SingleChildScrollView(
            child: Column(
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
                  label: 'Email',
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
                _buildRoleSelector(
                  selectedRole: selectedRole,
                  roles: roles,
                  onChanged: (value) => selectedRole = value,
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: passwordController,
                  label: 'Contraseña',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: confirmPasswordController,
                  label: 'Confirmar Contraseña',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              // Validar campos requeridos
              if (nameController.text.isEmpty ||
                  emailController.text.isEmpty ||
                  selectedRole == null ||
                  passwordController.text.isEmpty ||
                  confirmPasswordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor complete todos los campos requeridos'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (passwordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Las contraseñas no coinciden'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Crear empleado con API real
              try {
                final employeeData = {
                  'parkingId': _parking?.id,
                  'name': nameController.text.trim(),
                  'email': emailController.text.trim(),
                  'phone': phoneController.text.isNotEmpty ? phoneController.text.trim() : null,
                  'role': selectedRole,
                  'password': passwordController.text,
                };

                await _employeeService.createEmployee(employeeData);

                if (mounted) {
                  Navigator.of(context).pop();
                  await _loadParkingDetails(); // Recargar lista
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Empleado creado exitosamente'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al crear empleado: $e'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
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
    bool obscureText = false,
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
      obscureText: obscureText,
      style: textTheme.bodyMedium,
    );
  }

  Widget _buildRoleSelector({
    required String? selectedRole,
    required List<Map<String, String>> roles,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rol',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 60),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedRole,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.work_outline,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            hint: Text(
              'Seleccionar rol',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            items: roles.map((role) {
              return DropdownMenuItem<String>(
                value: role['value'],
                child: Text(
                  role['label']!,
                  style: textTheme.bodyMedium,
                ),
              );
            }).toList(),
            onChanged: onChanged,
            dropdownColor: colorScheme.surface,
            icon: Icon(
              Icons.arrow_drop_down,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  void _editEmployee(EmployeeModel employee) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    String? selectedRole = employee.role;
    bool changePassword = false;
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmNewPasswordController = TextEditingController();

    final roles = [
      {'value': 'owner', 'label': 'Propietario'},
      {'value': 'Administrador', 'label': 'Administrador'},
      {'value': 'Supervisor', 'label': 'Supervisor'},
      {'value': 'Operador', 'label': 'Operador'},
      {'value': 'Cajero', 'label': 'Cajero'},
      {'value': 'Guardia', 'label': 'Guardia de Seguridad'},
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          title: Text(
            'Editar Empleado',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Información del empleado (solo lectura)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información del Empleado',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          employee.name,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (employee.email != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            employee.email!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (employee.phone != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            employee.phone!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Selector de rol (editable)
                  _buildRoleSelector(
                    selectedRole: selectedRole,
                    roles: roles,
                    onChanged: (value) => selectedRole = value,
                  ),
                  const SizedBox(height: 16),
                  // Opción para cambiar contraseña
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Cambiar Contraseña',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Switch(
                              value: changePassword,
                              onChanged: (value) {
                                setState(() {
                                  changePassword = value;
                                });
                              },
                              activeColor: colorScheme.primary,
                            ),
                          ],
                        ),
                        if (changePassword) ...[
                          const SizedBox(height: 16),
                          _buildDialogTextField(
                            controller: currentPasswordController,
                            label: 'Contraseña Actual',
                            icon: Icons.lock_outline,
                            obscureText: true,
                          ),
                          const SizedBox(height: 12),
                          _buildDialogTextField(
                            controller: newPasswordController,
                            label: 'Nueva Contraseña',
                            icon: Icons.lock_outline,
                            obscureText: true,
                          ),
                          const SizedBox(height: 12),
                          _buildDialogTextField(
                            controller: confirmNewPasswordController,
                            label: 'Confirmar Nueva Contraseña',
                            icon: Icons.lock_outline,
                            obscureText: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                // Validar campos requeridos
                if (selectedRole == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor seleccione un rol'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Validar cambio de contraseña si está activado
                if (changePassword) {
                  if (currentPasswordController.text.isEmpty ||
                      newPasswordController.text.isEmpty ||
                      confirmNewPasswordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor complete todos los campos de contraseña'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (newPasswordController.text != confirmNewPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Las nuevas contraseñas no coinciden'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                }

                try {
                  // Actualizar datos del empleado
                  final updateData = <String, dynamic>{};
                  if (selectedRole != employee.role) {
                    updateData['role'] = selectedRole;
                  }

                  if (updateData.isNotEmpty) {
                    await _employeeService.updateEmployee(employee.id, updateData);
                  }

                  // Cambiar contraseña si está activado
                  if (changePassword) {
                    await _employeeService.changeEmployeePassword(employee.id, {
                      'currentPassword': currentPasswordController.text,
                      'newPassword': newPasswordController.text,
                    });
                  }

                  if (mounted) {
                    Navigator.of(context).pop();
                    await _loadParkingDetails(); // Recargar lista
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Empleado actualizado exitosamente'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al actualizar empleado: $e'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Actualizar'),
            ),
          ],
        ),
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
            onPressed: () async {
              try {
                await _employeeService.deleteEmployee(employee.id);

                if (mounted) {
                  Navigator.of(context).pop();
                  await _loadParkingDetails(); // Recargar lista
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Empleado eliminado exitosamente'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar empleado: $e'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
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
