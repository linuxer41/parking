import 'package:flutter/material.dart';
import 'package:parkar/models/cash_register_model.dart';
import 'package:parkar/models/movement_model.dart';
import 'package:parkar/services/cash_register_service.dart';
import 'package:parkar/services/movement_service.dart';
import 'package:parkar/state/app_state_container.dart';
import 'package:parkar/widgets/cash_register_dialogs.dart';
import 'package:intl/intl.dart';

class CashRegisterScreen extends StatefulWidget {
  const CashRegisterScreen({super.key});

  @override
  State<CashRegisterScreen> createState() => _CashRegisterScreenState();
}

class _CashRegisterScreenState extends State<CashRegisterScreen> {
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
      // Get current open cash register
      final currentCashRegister = await _cashRegisterService
          .getCurrentCashRegister();
      appState.setCurrentCashRegister(currentCashRegister);

      if (currentCashRegister != null) {
        // Load movements for the current cash register
        _movements = await _movementService.getMovementsByCashRegister(
          currentCashRegister.id,
        );
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
    final cashRegister = await CashRegisterDialogs.showOpenCashRegisterDialog(context);
    if (cashRegister == null) return; // User cancelled

    // The dialog already opened the cash register and set the app state
    _movements = []; // Start with empty movements

    setState(() {});
    _showSuccessMessage('Caja abierta exitosamente');
  }

  Future<void> _closeCashRegister() async {
    final appState = AppStateContainer.of(context);
    if (appState.currentCashRegister == null) return;

    // Calculate total cash
    double totalCash = appState.currentCashRegister!.initialAmount;
    for (final movement in _movements) {
      if (movement.type == 'income') {
        totalCash += movement.amount;
      } else {
        totalCash -= movement.amount;
      }
    }

    final success = await CashRegisterDialogs.showCloseCashRegisterDialog(context, appState.currentCashRegister!, totalCash);
    if (success != true) return; // User cancelled or error

    // The dialog already closed the cash register and set the app state
    _movements = [];

    setState(() {});
    _showSuccessMessage('Caja cerrada exitosamente');
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
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appState = AppStateContainer.of(context);
    final currentCashRegister = appState.currentCashRegister;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caja Registradora'),
        backgroundColor: colorScheme.primaryContainer,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: currentCashRegister != null
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: currentCashRegister != null
                    ? Colors.green.withValues(alpha: 0.3)
                    : Colors.orange.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: currentCashRegister != null ? _closeCashRegister : _openCashRegister,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentCashRegister != null ? 'Cerrar Caja' : 'Abrir Caja',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: currentCashRegister != null
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        currentCashRegister != null ? Icons.close : Icons.play_arrow,
                        size: 16,
                        color: currentCashRegister != null
                            ? Colors.green.shade600
                            : Colors.orange.shade600,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : currentCashRegister == null
              ? _buildNoCashRegisterView(theme, colorScheme)
              : _buildCashRegisterView(theme, colorScheme, currentCashRegister),
    );
  }

  Widget _buildMovementsTable() {
    final incomeMovements = _movements.where((m) => m.type == 'income').toList();

    if (incomeMovements.isEmpty) {
      return const Center(
        child: Text('No hay cobros registrados'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Fecha')),
          DataColumn(label: Text('Descripción')),
          DataColumn(label: Text('Monto')),
        ],
        rows: incomeMovements.map((movement) {
          return DataRow(
            cells: [
              DataCell(Text(DateFormat('dd/MM/yyyy HH:mm').format(movement.createdAt))),
              DataCell(Text(movement.description)),
              DataCell(Text('\$${movement.amount.toStringAsFixed(2)}')),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNoCashRegisterView(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No se ha inicializado una caja',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _openCashRegister,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Abrir Caja'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: theme.textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashRegisterView(ThemeData theme, ColorScheme colorScheme, CashRegisterModel currentCashRegister) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cash Register Details
          Text('Caja #: ${currentCashRegister.number}'),
          Text(
            'Empleado: ${currentCashRegister.employee.name}',
          ),
          Text(
            'Inicio: ${DateFormat('dd/MM/yyyy HH:mm').format(currentCashRegister.startDate)}',
          ),
          Text('Estado: ${currentCashRegister.status}'),
          const SizedBox(height: 16),

          // Collection History Table
          Text(
            'Historial de Cobros',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildMovementsTable(),
          ),
        ],
      ),
    );
  }
}
