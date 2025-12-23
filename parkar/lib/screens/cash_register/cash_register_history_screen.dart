import 'package:flutter/material.dart';
import 'package:parkar/constants/constants.dart';
import 'package:parkar/models/cash_register_model.dart';
import 'package:parkar/services/cash_register_service.dart';
import 'package:parkar/widgets/page_layout.dart';

class CashRegisterHistoryScreen extends StatefulWidget {
  const CashRegisterHistoryScreen({super.key});

  @override
  State<CashRegisterHistoryScreen> createState() => _CashRegisterHistoryScreenState();
}

class _CashRegisterHistoryScreenState extends State<CashRegisterHistoryScreen> {
  List<CashRegisterModel> _cashRegisters = [];
  bool _isLoading = true;
  final CashRegisterService _cashRegisterService = CashRegisterService();

  @override
  void initState() {
    super.initState();
    _loadCashRegisters();
  }

  Future<void> _loadCashRegisters() async {
    setState(() => _isLoading = true);

    try {
      _cashRegisters = await _cashRegisterService.getCashRegisters();
    } catch (e) {
      _showErrorMessage('Error al cargar historial de cajas: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _approveCashRegister(String cashRegisterId) async {
    try {
      await _cashRegisterService.approveCashRegister(cashRegisterId);
      _showSuccessMessage('Caja aprobada exitosamente');
      _loadCashRegisters(); // Refresh the list
    } catch (e) {
      _showErrorMessage('Error al aprobar caja: $e');
    }
  }

  Future<void> _rejectCashRegister(String cashRegisterId) async {
    try {
      await _cashRegisterService.rejectCashRegister(cashRegisterId);
      _showSuccessMessage('Caja rechazada');
      _loadCashRegisters(); // Refresh the list
    } catch (e) {
      _showErrorMessage('Error al rechazar caja: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PageLayout(
      title: 'Historial de Cajas Registradoras',
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cashRegisters.isEmpty
              ? _buildEmptyView(theme, colorScheme)
              : _buildCashRegistersList(theme, colorScheme),
    );
  }

  Widget _buildEmptyView(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: 80,
            color: colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No hay cajas registradas',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCashRegistersList(ThemeData theme, ColorScheme colorScheme) {
    return RefreshIndicator(
      onRefresh: _loadCashRegisters,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _cashRegisters.length,
        itemBuilder: (context, index) {
          final cashRegister = _cashRegisters[index];
          return _buildCashRegisterCard(cashRegister, theme, colorScheme);
        },
      ),
    );
  }

  Widget _buildCashRegisterCard(CashRegisterModel cashRegister, ThemeData theme, ColorScheme colorScheme) {
    final statusColor = _getStatusColor(cashRegister.status, colorScheme);
    final statusText = _getStatusText(cashRegister.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '#${cashRegister.number}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Details
            _buildDetailRow('Empleado', cashRegister.employee.name),
            _buildDetailRow('Apertura', DateTimeConstants.formatDateTimeWithParkingParams(context, cashRegister.startDate)),
            if (cashRegister.endDate != null)
              _buildDetailRow('Cierre', DateTimeConstants.formatDateTimeWithParkingParams(context, cashRegister.endDate!)),
            _buildDetailRow('Monto Inicial', CurrencyConstants.formatAmountWithParkingParams(context, cashRegister.initialAmount)),
            _buildDetailRow('Monto Final', CurrencyConstants.formatAmountWithParkingParams(context, cashRegister.totalAmount)),
            if (cashRegister.endDate != null) ...[
              const SizedBox(height: 6),
              _buildDetailRow(
                'Monto Recaudado',
                CurrencyConstants.formatAmountWithParkingParams(context, cashRegister.totalAmount - cashRegister.initialAmount),
                (cashRegister.totalAmount - cashRegister.initialAmount) >= 0 ? Colors.green : Colors.red,
              ),
            ],

            const SizedBox(height: 16),

            // Actions (only show for pending status)
            if (cashRegister.status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveCashRegister(cashRegister.id),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Aprobar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectCashRegister(cashRegister.id),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Rechazar'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colorScheme.error),
                        foregroundColor: colorScheme.error,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, [Color? valueColor]) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: valueColor ?? colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.blue;
      case 'closed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return colorScheme.error;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return 'Abierta';
      case 'closed':
        return 'Cerrada';
      case 'pending':
        return 'Pendiente';
      case 'rejected':
        return 'Rechazada';
      default:
        return status;
    }
  }
}