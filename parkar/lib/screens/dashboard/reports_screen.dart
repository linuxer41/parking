import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/access_model.dart';
import '../../models/vehicle_model.dart';
import '../../models/employee_model.dart';
import '../../services/access_service.dart';
import '../../services/vehicle_service.dart';
import '../../services/employee_service.dart';
import '../../services/document_service.dart';
import '../../state/app_state_container.dart';
import '../../widgets/page_layout.dart';
import '../parking/widgets/components/access_report_table.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late AccessService _accessService;
  late DocumentService _documentService;
  bool _isLoading = true;
  List<AccessModel> _accesses = [];
  String? _error;
  String _selectedPeriod = 'daily';
  DateTime _customStartDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _customEndDate = DateTime.now();
  late VehicleService _vehicleService;
  late EmployeeService _employeeService;
  List<VehicleModel> _vehicles = [];
  List<EmployeeModel> _employees = [];
  String? _selectedVehicleId;
  String? _selectedEmployeeId;
  String? _selectedStatus;
  bool _inParkingOnly = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _accessService = AppStateContainer.di(context).resolve<AccessService>();
    _documentService = DocumentService();
    _loadAccesses();
  }

  // Cargar accesos desde la API
  Future<void> _loadAccesses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final appState = AppStateContainer.of(context);
      final parkingId = appState.currentParking?.id;

      if (parkingId == null) {
        setState(() {
          _error = 'No se encontró el estacionamiento actual';
          _isLoading = false;
        });
        return;
      }

      // Calcular rango de fechas basado en el período seleccionado
      final now = DateTime.now();
      DateTime startDate;
      DateTime endDate;

      switch (_selectedPeriod) {
        case 'daily':
          startDate = DateTime(now.year, now.month, now.day);
          endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'weekly':
          final monday = now.subtract(Duration(days: now.weekday - 1));
          startDate = DateTime(monday.year, monday.month, monday.day);
          endDate = DateTime(monday.year, monday.month, monday.day, 23, 59, 59).add(const Duration(days: 6));
          break;
        case 'monthly':
          startDate = DateTime(now.year, now.month, 1);
          endDate = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));
          break;
        case 'custom':
          startDate = DateTime(_customStartDate.year, _customStartDate.month, _customStartDate.day);
          endDate = DateTime(_customEndDate.year, _customEndDate.month, _customEndDate.day, 23, 59, 59);
          break;
        default:
          startDate = DateTime(now.year, now.month, now.day);
          endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      }

      // Cargar accesos que están actualmente en el parqueo
      final accesses = await _accessService.list(
         AccessFilter(
          parkingId: parkingId
        )
      );

      // Filtrar por rango de fechas
      final filteredAccesses = accesses.where((access) {
        final accessDate = access.entryTime;
        return accessDate.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
               accessDate.isBefore(endDate.add(const Duration(seconds: 1)));
      }).toList();

      if (mounted) {
        setState(() {
          _accesses = filteredAccesses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar accesos: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  // Refrescar datos
  Future<void> _refreshAccesses() async {
    await _loadAccesses();
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(title: 'Reportes de Accesos', body: _buildReportsContent());
  }

  Widget _buildReportsContent() {
    return Column(
      children: [
        // Selector de período
        _buildPeriodSelector(),

        // Tabla de reportes
        Expanded(
          child: AccessReportTable(
            accesses: _accesses,
            isLoading: _isLoading,
            error: _error,
            onRetry: _refreshAccesses,
          ),
        ),

        // Botones de acción
        _buildActionButtons(),
      ],
    );
  }


  Widget _buildPeriodSelector() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seleccionar Período',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              // Selector de tipo de período
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipo de Período',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPeriod,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'daily',
                          child: Text('Diario'),
                        ),
                        DropdownMenuItem(
                          value: 'weekly',
                          child: Text('Semanal'),
                        ),
                        DropdownMenuItem(
                          value: 'monthly',
                          child: Text('Mensual'),
                        ),
                        DropdownMenuItem(
                          value: 'custom',
                          child: Text('Personalizado'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedPeriod = value;
                          });
                          _loadAccesses();
                        }
                      },
                    ),
                  ],
                ),
              ),

              if (_selectedPeriod == 'custom') ...[
                const SizedBox(width: 12),
                // Botón para abrir modal de fechas personalizadas
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _showCustomDateModal(context),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      '${_formatDate(_customStartDate)} - ${_formatDate(_customEndDate)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _downloadReport(),
              icon: const Icon(Icons.download),
              label: const Text('Descargar PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _shareReport(),
              icon: const Icon(Icons.share),
              label: const Text('Compartir'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
                side: BorderSide(color: colorScheme.primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCustomDateModal(BuildContext context) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    DateTime tempStartDate = _customStartDate;
    DateTime tempEndDate = _customEndDate;

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Seleccionar Rango de Fechas'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Fecha inicio
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: tempStartDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          tempStartDate = picked;
                          // Si la fecha fin es anterior a la nueva fecha inicio, ajustarla
                          if (tempEndDate.isBefore(tempStartDate)) {
                            tempEndDate = tempStartDate;
                          }
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fecha Inicio',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  _formatDate(tempStartDate),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Fecha fin
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: tempEndDate,
                        firstDate: tempStartDate,
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          tempEndDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fecha Fin',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  _formatDate(tempEndDate),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      setState(() {
        _customStartDate = tempStartDate;
        _customEndDate = tempEndDate;
      });
      _loadAccesses();
    }
  }

  Future<void> _downloadReport() async {
    if (_accesses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay datos para generar el reporte'),
          backgroundColor: Colors.orange,
        ),
      );
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

      final appState = AppStateContainer.of(context);
      final parkingName = appState.currentParking?.name ?? 'ParKar';

      // Generar PDF
      final pdfBytes = await _documentService.generateAccessReport(
        accesses: _accesses,
        periodType: _selectedPeriod,
        parkingName: parkingName,
        startDate: _selectedPeriod == 'custom' ? _customStartDate : null,
        endDate: _selectedPeriod == 'custom' ? _customEndDate : null,
      );

      // Guardar archivo
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'reporte_accesos_$timestamp.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      // Mostrar éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF guardado en: ${file.path}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Abrir',
              textColor: Colors.white,
              onPressed: () async {
                // Aquí podrías abrir el archivo con un visor de PDF
              },
            ),
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

  Future<void> _shareReport() async {
    if (_accesses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay datos para compartir'),
          backgroundColor: Colors.orange,
        ),
      );
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

      final appState = AppStateContainer.of(context);
      final parkingName = appState.currentParking?.name ?? 'ParKar';

      // Generar PDF
      final pdfBytes = await _documentService.generateAccessReport(
        accesses: _accesses,
        periodType: _selectedPeriod,
        parkingName: parkingName,
        startDate: _selectedPeriod == 'custom' ? _customStartDate : null,
        endDate: _selectedPeriod == 'custom' ? _customEndDate : null,
      );

      // Crear archivo temporal
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'reporte_accesos_$timestamp.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      // Compartir archivo
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Reporte de Accesos - $parkingName',
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
