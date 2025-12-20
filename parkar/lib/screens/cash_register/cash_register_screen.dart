import 'package:flutter/material.dart';
import 'package:parkar/models/cash_register_model.dart';
import 'package:parkar/models/movement_model.dart';
import 'package:parkar/services/cash_register_service.dart';
import 'package:parkar/services/movement_service.dart';
import 'package:parkar/state/app_state_container.dart';
import 'package:parkar/widgets/custom_snackbar.dart';
import 'package:intl/intl.dart';

class CashRegisterScreen extends StatefulWidget {
  const CashRegisterScreen({super.key});

  @override
  State<CashRegisterScreen> createState() => _CashRegisterScreenState();
}

class _CashRegisterScreenState extends State<CashRegisterScreen> {
  CashRegisterModel? _currentCashRegister;
  List<MovementModel> _movements = [];
  bool _isLoading = true;
  final CashRegisterService _cashRegisterService = CashRegisterService();
  final MovementService _movementService = MovementService();

  @override
  void initState() {
    super.initState();
    _loadCashRegisterData();
  }

  Future<void> _loadCashRegisterData() async {
    setState(() => _isLoading = true);

    try {
      final appState = AppStateContainer.of(context);
      final parkingId = appState.currentParking?.id;

      if (parkingId == null) {
        _showErrorMessage('No hay estacionamiento seleccionado');
        return;
      }

      // Get current open cash register
      final cashRegisters = await _cashRegisterService.getCashRegistersByParking(parkingId);
      _currentCashRegister = cashRegisters.where((cr) => cr.status == 'open').firstOrNull;

      if (_currentCashRegister != null) {
        // Load movements for the current cash register
        _movements = await _movementService.getMovementsByCashRegister(_currentCashRegister!.id);
      }
    } catch (e) {
      _showErrorMessage('Error al cargar datos de caja: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openCashRegister() async {
    try {
      final appState = AppStateContainer.of(context);
      final parkingId = appState.currentParking?.id;
      final employeeId = appState.currentUser?.id;

      if (parkingId == null || employeeId == null) {
        _showErrorMessage('Datos insuficientes para abrir caja');
        return;
      }

      final createModel = CashRegisterCreateModel(
        number: 1, // Default number, could be configurable
        parkingId: parkingId,
        employeeId: employeeId,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(hours: 8)), // Default 8 hours
        status: 'open',
      );

      _currentCashRegister = await _cashRegisterService.createCashRegister(createModel);
      _movements = []; // Start with empty movements

      setState(() {});
      _showSuccessMessage('Caja abierta exitosamente');
    } catch (e) {
      _showErrorMessage('Error al abrir caja: $e');
    }
  }

  Future<void> _closeCashRegister() async {
    if (_currentCashRegister == null) return;

    try {
      final updateModel = CashRegisterUpdateModel(
        status: 'closed',
        endDate: DateTime.now(),
      );

      await _cashRegisterService.updateCashRegister(_currentCashRegister!.id, updateModel);
      _currentCashRegister = null;
      _movements = [];

      setState(() {});
      _showSuccessMessage('Caja cerrada exitosamente');
    } catch (e) {
      _showErrorMessage('Error al cerrar caja: $e');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caja Registradora'),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cash Register Status Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estado de Caja',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_currentCashRegister != null) ...[
                            Text('Caja #: ${_currentCashRegister!.number}'),
                            Text('Empleado: ${_currentCashRegister!.employee.name}'),
                            Text('Inicio: ${DateFormat('dd/MM/yyyy HH:mm').format(_currentCashRegister!.startDate)}'),
                            Text('Estado: ${_currentCashRegister!.status}'),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _closeCashRegister,
                              icon: const Icon(Icons.close),
                              label: const Text('Cerrar Caja'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.error,
                                foregroundColor: colorScheme.onError,
                              ),
                            ),
                          ] else ...[
                            const Text('No hay caja abierta'),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _openCashRegister,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Abrir Caja'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Movements History
                  if (_currentCashRegister != null) ...[
                    Text(
                      'Historial de Movimientos',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _movements.isEmpty
                          ? const Center(child: Text('No hay movimientos registrados'))
                          : ListView.builder(
                              itemCount: _movements.length,
                              itemBuilder: (context, index) {
                                final movement = _movements[index];
                                return Card(
                                  child: ListTile(
                                    title: Text(movement.description),
                                    subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(movement.createdAt)),
                                    trailing: Text(
                                      '${movement.type == 'income' ? '+' : '-'}\$${movement.amount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: movement.type == 'income' ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}