import 'package:flutter/material.dart';
import 'package:parkar/models/cash_register_model.dart';
import 'package:parkar/models/movement_model.dart';
import 'package:parkar/services/cash_register_service.dart';
import 'package:parkar/services/movement_service.dart';
import 'package:parkar/state/app_state_container.dart';
import 'package:parkar/widgets/cash_register_dialogs.dart';
import 'package:parkar/widgets/page_layout.dart';
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

    return PageLayout(
      title: 'Caja',
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: currentCashRegister != null ? _closeCashRegister : _openCashRegister,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentCashRegister != null ? 'Cerrar Caja' : 'Abrir Caja',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : currentCashRegister == null
              ? _buildNoCashRegisterView(theme, colorScheme)
              : _buildCashRegisterView(theme, colorScheme, currentCashRegister),
    );
  }

  Widget _buildMovementsTable() {
    final incomeMovements = _movements.where((m) => m.type != 'expense').toList();

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
          DataColumn(label: Text('Monto')),
          DataColumn(label: Text('Descripción')),
        ],
        rows: incomeMovements.map((movement) {
          return DataRow(
            cells: [
              DataCell(Text(DateFormat('dd/MM/yyyy HH:mm').format(movement.createdAt))),
              DataCell(Text('\$${movement.amount.toStringAsFixed(2)}')),
              DataCell(Text(movement.description)),
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

  Widget _buildDetailRow(String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$label ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
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
          _buildDetailRow('Id de caja #:', currentCashRegister.number.toString()),
          _buildDetailRow('Usuario:', currentCashRegister.employee.name),
          _buildDetailRow('Apertura:', DateFormat('dd/MM/yyyy HH:mm').format(currentCashRegister.startDate)),
          _buildDetailRow('Monto Actual:', '${currentCashRegister.totalAmount.toStringAsFixed(2)} Bs.'),
          const SizedBox(height: 16),

          // Collection History Table
          Text(
            'Historial de Cobros',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
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
