import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:parkar/constants/constants.dart';
import 'package:parkar/models/cash_register_model.dart';
import 'package:parkar/models/movement_model.dart';
import 'package:parkar/services/cash_register_service.dart';
import 'package:parkar/services/document_service.dart';
import 'package:parkar/services/movement_service.dart';
import 'package:parkar/state/app_state_container.dart';
import 'package:parkar/widgets/cash_register_dialogs.dart';
import 'package:parkar/widgets/page_layout.dart';
import 'package:parkar/widgets/pdf_viewer.dart';
import 'package:parkar/models/printer_model.dart';
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
  final DocumentService _documentService = DocumentService();

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
    final closedCashRegister = appState.currentCashRegister!;
    final closedMovements = List<MovementModel>.from(_movements);

    _movements = [];

    setState(() {});
    _showSuccessMessage('Caja cerrada exitosamente');

    // Show the closure PDF document
    await _showClosureReceipt(closedCashRegister, closedMovements);
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

  Future<void> _downloadCashRegisterReport() async {
    final appState = AppStateContainer.of(context);
    final currentCashRegister = appState.currentCashRegister;

    if (currentCashRegister == null) {
      _showErrorMessage('No hay caja abierta');
      return;
    }

    if (_movements.isEmpty) {
      _showErrorMessage('No hay movimientos para generar el reporte');
      return;
    }

    try {
      // Mostrar indicador de carga
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generando PDF...'),
          duration: Duration(seconds: 1),
        ),
      );

      final parkingName = appState.currentParking?.name ?? 'ParKar';

      // Generar PDF
      final pdfBytes = await _documentService.generateCashRegisterReport(
        cashRegister: currentCashRegister,
        movements: _movements,
        parkingName: parkingName,
      );

      // Guardar archivo
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'reporte_caja_${currentCashRegister.number}_$timestamp.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      // Mostrar éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF guardado en: ${file.path}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareCashRegisterReport() async {
    final appState = AppStateContainer.of(context);
    final currentCashRegister = appState.currentCashRegister;

    if (currentCashRegister == null) {
      _showErrorMessage('No hay caja abierta');
      return;
    }

    if (_movements.isEmpty) {
      _showErrorMessage('No hay movimientos para compartir');
      return;
    }

    try {
      // Mostrar indicador de carga
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generando PDF para compartir...'),
          duration: Duration(seconds: 1),
        ),
      );

      final parkingName = appState.currentParking?.name ?? 'ParKar';

      // Generar PDF
      final pdfBytes = await _documentService.generateCashRegisterReport(
        cashRegister: currentCashRegister,
        movements: _movements,
        parkingName: parkingName,
      );

      // Crear archivo temporal
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'reporte_caja_${currentCashRegister.number}_$timestamp.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      // Compartir archivo
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Reporte de Caja - $parkingName',
      );

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al compartir: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _printCashRegisterReceipt(CashRegisterModel cashRegister) async {
    // Note: printCashRegisterReceipt is in PrintService, but since this screen uses DocumentService,
    // we'll call it directly. For now, we'll show the PDF using DocumentService method.
    final appState = AppStateContainer.of(context);
    final parkingName = appState.currentParking?.name ?? 'ParKar';

    try {
      final pdfData = await _documentService.generateCashRegisterReport(
        cashRegister: cashRegister,
        movements: _movements,
        parkingName: parkingName,
      );

      if (context.mounted) {
        PdfViewer.show(
          context,
          pdfData: pdfData,
          title: 'Recibo de Caja',
          filename: 'recibo_caja_${cashRegister.number}',
          onPrintPressed: appState.printSettings.printMethod == PrintMethod.bluetooth
              ? () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Impresión Bluetooth disponible desde el visor PDF')),
                  );
                }
              : null,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar recibo: $e')),
        );
      }
    }
  }

  Future<void> _showClosureReceipt(CashRegisterModel cashRegister, List<MovementModel> movements) async {
    final appState = AppStateContainer.of(context);
    final parkingName = appState.currentParking?.name ?? 'ParKar';

    try {
      final pdfData = await _documentService.generateCashRegisterReport(
        cashRegister: cashRegister,
        movements: movements,
        parkingName: parkingName,
      );

      if (context.mounted) {
        PdfViewer.show(
          context,
          pdfData: pdfData,
          title: 'Recibo de Cierre de Caja',
          filename: 'cierre_caja_${cashRegister.number}',
          onPrintPressed: appState.printSettings.printMethod == PrintMethod.bluetooth
              ? () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Impresión Bluetooth disponible desde el visor PDF')),
                  );
                }
              : null,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al mostrar recibo de cierre: $e')),
        );
      }
    }
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
              DataCell(Text(DateTimeConstants.formatDateTimeWithParkingParams(context, movement.createdAt))),
              DataCell(Text(CurrencyConstants.formatAmountWithParkingParams(context, movement.amount))),
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
    return Column(
      children: [
        // Main content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cash Register Details with reprint button
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Id de caja #:', currentCashRegister.number.toString()),
                          _buildDetailRow('Usuario:', currentCashRegister.employee.name),
                          _buildDetailRow('Apertura:', DateTimeConstants.formatDateTimeWithParkingParams(context, currentCashRegister.startDate)),
                          _buildDetailRow('Monto Actual:', CurrencyConstants.formatAmountWithParkingParams(context, currentCashRegister.totalAmount)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _printCashRegisterReceipt(currentCashRegister),
                      icon: const Icon(Icons.receipt_long),
                      tooltip: 'Reimprimir Recibo',
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.primaryContainer,
                        foregroundColor: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
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
          ),
        ),

        // Fixed bottom buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _downloadCashRegisterReport,
                  icon: const Icon(Icons.download),
                  label: const Text('Descargar PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _shareCashRegisterReport,
                  icon: const Icon(Icons.share),
                  label: const Text('Compartir'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
