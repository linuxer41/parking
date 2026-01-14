import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../constants/constants.dart';
import '../models/access_model.dart';
import '../models/booking_model.dart';
import '../models/cash_register_model.dart';
import '../models/movement_model.dart';
import '../models/subscription_model.dart';

// Unified data model for all ticket types
class TicketData {
  final String title;
  final String parkingName;
  final List<MapEntry<String, String>> topInfo;
  final List<MapEntry<String, String>> vehicleInfo;
  final List<MapEntry<String, String>>? paymentInfo;
  final List<String> footerMessages;
  final bool showPaymentHeader;

  TicketData({
    required this.title,
    required this.parkingName,
    required this.topInfo,
    required this.vehicleInfo,
    this.paymentInfo,
    required this.footerMessages,
    this.showPaymentHeader = true,
  });

  // Generate ZPL
  String generateZPL() {
    final buffer = StringBuffer();


    buffer.writeln('^XA');
    buffer.writeln('^PW576');
    buffer.writeln('^LL600');
    buffer.writeln('^CI28');
    buffer.writeln('^FO0,60^FB576,1,0,C^A0N,30,30^FD$title^FS');
    buffer.writeln('^FO0,90^FB576,1,0,C^A0N,20,28^FD${parkingName.toUpperCase()}^FS');

    int yOffset = 120;
    for (final entry in topInfo) {
      buffer.writeln('^FO0,${yOffset}^A0N,22,22^FD${entry.key}:^FS');
      buffer.writeln('^FO350,${yOffset}^FB226,1,0,R^A0N,22,22^FD${entry.value}^FS');
      yOffset += 30;
    }
    buffer.writeln('^FO0,${yOffset}^GB576,1,1,B,0^FS');
    yOffset += 30;

    for (final entry in vehicleInfo) {
      buffer.writeln('^FO0,${yOffset}^A0N,22,22^FD${entry.key}:^FS');
      String font = entry.key == 'Total a pagar' ? '^A0N,26,26' : '^A0N,22,22';
      buffer.writeln('^FO350,${yOffset}$font^FB226,1,0,R^FD${entry.value}^FS');
      yOffset += 30;
    }

    if (paymentInfo != null && paymentInfo!.isNotEmpty) {
      buffer.writeln('^FO0,${yOffset}^GB576,1,1,B,0^FS');
      yOffset += 30;
      if (showPaymentHeader) {
        buffer.writeln('^FO0,${yOffset}^FB576,1,0,C^A0N,26,26^FDPAGO^FS');
        yOffset += 30;
      }
      for (final entry in paymentInfo!) {
        buffer.writeln('^FO0,${yOffset}^A0N,22,22^FD${entry.key}:^FS');
        buffer.writeln('^FO350,${yOffset}^FB226,1,0,R^A0N,22,22^FD${entry.value}^FS');
        yOffset += 30;
      }
    }

    buffer.writeln('^FO0,${yOffset}^GB576,1,1,B,0^FS');
    yOffset += 30;
    for (final msg in footerMessages) {
      buffer.writeln('^FO0,${yOffset}^FB576,1,0,C^A0N,20,20^FD$msg^FS');
      yOffset += 30;
    }
    buffer.writeln('^XZ');
    final int totalHeight = yOffset + 0;
    return buffer.toString().replaceFirst('^LL600', '^LL$totalHeight');
  }

  // Generate PDF
  Future<Uint8List> generatePDF() async {
    final pdf = pw.Document();

    // Cargar fuentes
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    // Crear página con formato de ticket
    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          80 * PdfPageFormat.mm,
          200 * PdfPageFormat.mm,
          marginAll: 5,
        ),
        build: (pw.Context context) {
          return pw.Container(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Título
                pw.Text(
                  title.toUpperCase(),
                  style: pw.TextStyle(font: fontBold, fontSize: 14),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 0),
                // Nombre del parqueo
                pw.Text(
                  parkingName.toUpperCase(),
                  style: pw.TextStyle(font: fontBold, fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 8),
                // Top info
                ...topInfo.map(
                  (entry) => pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            '${entry.key}:',
                            style: pw.TextStyle(font: fontBold, fontSize: 10),
                          ),
                          pw.Text(
                            entry.value,
                            style: pw.TextStyle(font: fontBold, fontSize: 10),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                    ],
                  ),
                ),
                // Separador
                pw.Divider(thickness: 1, color: PdfColors.black),
                pw.SizedBox(height: 8),

                // Información del vehículo
                ...vehicleInfo.map(
                  (entry) => pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            '${entry.key}:',
                            style: pw.TextStyle(font: fontBold, fontSize: 10),
                          ),
                          pw.Text(
                            entry.value,
                            style: pw.TextStyle(font: fontBold, fontSize: entry.key == 'Tarifa' ? 12 : 10),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                    ],
                  ),
                ),

                // Información de pago si existe
                if (paymentInfo != null && paymentInfo!.isNotEmpty) ...[
                  if (showPaymentHeader) ...[
                    pw.SizedBox(height: 8),
                    pw.Divider(thickness: 1, color: PdfColors.black),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'PAGO',
                      style: pw.TextStyle(font: fontBold, fontSize: 12),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 8),
                  ],
                  ...paymentInfo!.map(
                    (entry) => pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              '${entry.key}:',
                              style: pw.TextStyle(font: fontBold, fontSize: 12),
                            ),
                            pw.Text(
                              entry.value,
                              style: pw.TextStyle(font: fontBold, fontSize: 12),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],

                // Separador
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 1, color: PdfColors.black),
                pw.SizedBox(height: 8),

                // Mensaje
                ...footerMessages.map(
                  (msg) => pw.Column(
                    children: [
                      pw.Text(
                        msg,
                        style: pw.TextStyle(font: fontBold, fontSize: 10),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 4),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  // Generate ESC/POS
  List<int> generateESC() {
    List<int> bytes = [];
    // Initialize
    bytes.addAll([0x1B, 0x40]); // ESC @
    // Center align
    bytes.addAll([0x1B, 0x61, 0x01]); // ESC a 1
    // Bold
    bytes.addAll([0x1B, 0x45, 0x01]); // ESC E 1
    bytes.addAll(utf8.encode('${parkingName.toUpperCase()}\n'));
    bytes.addAll(utf8.encode('$title\n'));
    // Normal
    bytes.addAll([0x1B, 0x45, 0x00]); // ESC E 0
    bytes.addAll([0x1B, 0x61, 0x00]); // ESC a 0
    for (final entry in vehicleInfo) {
      bytes.addAll(utf8.encode('${entry.key}: ${entry.value}\n'));
    }
    if (paymentInfo != null) {
      for (final entry in paymentInfo!) {
        bytes.addAll(utf8.encode('${entry.key}: ${entry.value}\n'));
      }
    }
    for (final msg in footerMessages) {
      bytes.addAll(utf8.encode('\n$msg'));
    }
    bytes.addAll(utf8.encode('\n\n'));
    // Cut
    bytes.addAll([0x1D, 0x56, 0x42, 0x00]); // GS V B 0
    return bytes;
  }
}

class DocumentService {

  // Conectar a dispositivo Bluetooth
  Future<bool> connectToDevice(String address) async {
    try {
      // Try different possible API patterns
      await FlutterBluetoothPrinter.connect(address);
      return true;
    } catch (e) {
      print('Error conectando a Bluetooth: $e');
      return false;
    }
  }

  // Desconectar
  Future<void> disconnect(String address) async {
    try {
      await FlutterBluetoothPrinter.disconnect(address);
    } catch (e) {
      print('Error desconectando: $e');
    }
  }

  // Verificar si está conectado
  Future<bool> get isConnected async {
    try {
      final state = FlutterBluetoothPrinter.connectionStateNotifier.value;
      return state != BluetoothConnectionState.idle;
    } catch (e) {
      print('Error checking connection: $e');
      return false;
    }
  }

// Generar ZPL para ticket de entrada

// Generar datos unificados para ticket de entrada
TicketData _generateEntryTicketData(AccessModel access) {
  final vehicleInfo = <MapEntry<String, String>>[
    MapEntry('Placa', access.vehicle.plate.isNotEmpty ? access.vehicle.plate.toUpperCase() : '--'),
    MapEntry('Tipo de vehículo', access.vehicle.type.isNotEmpty ? _formatVehicleType(access.vehicle.type) : '--'),
    MapEntry('Color', access.vehicle.color?.isNotEmpty == true ? access.vehicle.color! : '--'),
  ];

  if (access.spot?.id != null) {
    vehicleInfo.add(MapEntry('Espacio', access.spot?.name ?? '--'));
  }

  return TicketData(
    title: 'TICKET DE ENTRADA',
    parkingName: access.parking.name,
    topInfo: [
      MapEntry('Nro', access.number?.toString().padLeft(6, '0') ?? '000000'),
      MapEntry('Fecha de ingreso', DateTimeConstants.formatDateTimeForPdf(access.entryTime, access.parking.params?.timeZone ?? 'America/La_Paz', format: 'dd/MM/yyyy HH:mm')),
    ],
    vehicleInfo: vehicleInfo,
    footerMessages: ['Conserve este ticket, requerido para la salida'],
  );
}
  // Generar datos unificados para ticket de salida
  TicketData _generateExitTicketData(AccessModel access) {
    final exitTime = access.exitTime ?? DateTime.now();
    final duration = exitTime.difference(access.entryTime);

    final vehicleInfo = <MapEntry<String, String>>[
      MapEntry('Placa', access.vehicle.plate.isNotEmpty ? access.vehicle.plate.toUpperCase() : '--'),
      MapEntry('Tipo de vehículo', access.vehicle.type.isNotEmpty ? _formatVehicleType(access.vehicle.type) : '--'),
      MapEntry('Permanencia', _formatDuration(duration)),
      MapEntry('Total a pagar', CurrencyConstants.formatAmountForPdf(access.amount, access.parking.params?.currency ?? 'BOB', access.parking.params?.decimalPlaces ?? 2)),
    ];

    if (access.spot?.name?.isNotEmpty == true) {
      vehicleInfo.add(MapEntry('Espacio', access.spot?.name ?? ''));
    }
    
    return TicketData(
      title: 'TICKET DE SALIDA',
      parkingName: access.parking.name,
      topInfo: [
        MapEntry('Nro', access.number?.toString().padLeft(6, '0') ?? '000000'),
        MapEntry('Fecha de ingreso', DateTimeConstants.formatDateTimeForPdf(access.entryTime, access.parking.params?.timeZone ?? 'America/La_Paz', format: 'dd/MM/yyyy HH:mm')),
        MapEntry('Fecha de salida', DateTimeConstants.formatDateTimeForPdf(exitTime, access.parking.params?.timeZone ?? 'America/La_Paz', format: 'dd/MM/yyyy HH:mm')),
      ],
      vehicleInfo: vehicleInfo,
      footerMessages: ['Gracias por su visita - Comprobante de pago'],
      showPaymentHeader: false,
    );
  }

  // Generar datos unificados para reserva
    TicketData _generateReservationData(BookingModel booking) {
      final vehicleInfo = <MapEntry<String, String>>[
        MapEntry('Placa', booking.vehicle.plate.isNotEmpty ? booking.vehicle.plate.toUpperCase() : '--'),
        MapEntry('Tipo', booking.vehicle.type.isNotEmpty ? _formatVehicleType(booking.vehicle.type) : '--'),
        MapEntry('Inicio', DateFormat('dd/MM/yyyy HH:mm').format(booking.startDate.toLocal())),
        MapEntry('Fin', DateFormat('dd/MM/yyyy HH:mm').format((booking.endDate ?? DateTime.now()).toLocal())),
        MapEntry('Duracion', '${booking.duration?.inHours ?? 0} horas'),
      ];

      if (booking.spotId?.isNotEmpty == true) {
        vehicleInfo.add(MapEntry('Espacio', booking.spotId!));
      }

      return TicketData(
        title: 'RESERVA DE ESTACIONAMIENTO',
        parkingName: booking.parking.name,
        topInfo: [
          MapEntry('Nro', booking.number?.toString().padLeft(6, '0') ?? '000000'),
          MapEntry('Fecha de reserva', DateTimeConstants.formatDateTimeForPdf(DateTime.now(), booking.parking.params?.timeZone ?? 'America/La_Paz', format: 'dd/MM/yyyy HH:mm')),
        ],
        vehicleInfo: vehicleInfo,
        footerMessages: ['Presente este ticket al llegar, la reserva expira 15 min despues'],
      );
    }

  // Generar datos unificados para suscripción
    TicketData _generateSubscriptionData(SubscriptionModel booking) {
      final vehicleInfo = <MapEntry<String, String>>[
        MapEntry('Placa', booking.vehicle.plate.isNotEmpty ? booking.vehicle.plate.toUpperCase() : '--'),
        MapEntry('Inicio', DateFormat('dd/MM/yyyy').format(booking.startDate)),
        MapEntry('Fin', DateFormat('dd/MM/yyyy').format(booking.endDate ?? DateTime.now())),
      ];
  
      final paymentInfo = <MapEntry<String, String>>[
        MapEntry('Monto', CurrencyConstants.formatAmountForPdf(booking.amount, booking.parking.params?.currency ?? 'BOB', booking.parking.params?.decimalPlaces ?? 2)),
        MapEntry('Metodo', 'Efectivo'),
        MapEntry('Estado', 'Pagado'),
      ];
  
      return TicketData(
        title: 'RECIBO DE SUSCRIPCION',
        parkingName: booking.parking.name,
        topInfo: [
          MapEntry('Nro', booking.number?.toString().padLeft(6, '0') ?? '000000'),
          MapEntry('Fecha de emision', DateTimeConstants.formatDateTimeForPdf(DateTime.now(), booking.parking.params?.timeZone ?? 'America/La_Paz', format: 'dd/MM/yyyy HH:mm')),
        ],
        vehicleInfo: vehicleInfo,
        paymentInfo: paymentInfo,
        footerMessages: ['Recibo oficial conserve este documento'],
      );
    }


  // Método para formatear el tipo de vehículo
  String _formatVehicleType(String vehicleType) {
    switch (vehicleType) {
      case 'car':
        return 'Automóvil';
      case 'motorcycle':
        return 'Motocicleta';
      case 'truck':
        return 'Camioneta';
      default:
        return vehicleType;
    }
  }

  // Método para formatear la duración
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '$hours h ${minutes.toString().padLeft(2, '0')} m';
    } else {
      return '${minutes.toString().padLeft(2, '0')} m';
    }
  }


  // Helper method for printing lines (placeholder)
  Future<void> _printLine(
    String text, {
    bool bold = false,
    bool center = false,
  }) async {
    // TODO: Implement with correct API
    print('Print line: $text (bold: $bold, center: $center)');
  }

  // Helper method for cutting paper (placeholder)
  Future<void> _cutPaper() async {
    // TODO: Implement with correct API
    print('Cutting paper');
  }

  // Public methods to generate PDFs
  Future<Uint8List> generateEntryTicketPDF(AccessModel access) async {
    return _generateEntryTicketData(access).generatePDF();
  }

  Future<Uint8List> generateExitTicketPDF(AccessModel access) async {
    return _generateExitTicketData(access).generatePDF();
  }

  Future<Uint8List> generateReservationTicketPDF(BookingModel booking) async {
    return _generateReservationData(booking).generatePDF();
  }

  Future<Uint8List> generateSubscriptionReceiptPDF(SubscriptionModel subscription) async {
    return _generateSubscriptionData(subscription).generatePDF();
  }

  Future<Uint8List> generateTestPrintPDF() async {
    final data = TicketData(
      title: 'PRUEBA DE IMPRESION',
      parkingName: 'ParKar',
      topInfo: [
        MapEntry('Nro', '000000'),
        MapEntry('Fecha:',
          DateTimeConstants.formatDateTimeForPdf(DateTime.now(), 'America/La_Paz', format: 'dd/MM/yyyy HH:mm')),
      ],
      vehicleInfo: [
        MapEntry('Estado', 'Impresora OK'),
      ],
      footerMessages: ['Prueba completada exitosamente'],
    );
    return data.generatePDF();
  }

  // Public methods to generate ZPL
  String generateEntryTicketZPL(AccessModel access) {
    final data = _generateEntryTicketData(access);
    return data.generateZPL();
  }

  String generateExitTicketZPL(AccessModel access) {
    final data = _generateExitTicketData(access);
    return data.generateZPL();
  }

  String generateReservationTicketZPL(BookingModel booking) {
    return _generateReservationData(booking).generateZPL();
  }

  String generateSubscriptionReceiptZPL(SubscriptionModel subscription) {
    return _generateSubscriptionData(subscription).generateZPL();
  }

  String generateTestZPL() {
    return '''
^XA
^PW576
^LL200
^CI28
^FO0,40^FB576,1,0,C^A0N,30,30^FDPRUEBA DE IMPRESION^FS
^FO0,80^A0N,22,22^FDFecha:^FS
^FO350,80^FB226,1,0,R^A0N,22,22^FD${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now().toLocal())}^FS
^FO0,110^A0N,22,22^FDEstado:^FS
^FO350,110^FB226,1,0,R^A0N,22,22^FDImpresora Bluetooth OK^FS
^XZ
''';
  }

  // Public methods to generate ESC
  List<int> generateEntryTicketESC(AccessModel access) {
    final data = _generateEntryTicketData(access);
    return data.generateESC();
  }

  List<int> generateExitTicketESC(AccessModel access) {
    final data = _generateExitTicketData(access);
    return data.generateESC();
  }

  List<int> generateReservationTicketESC(BookingModel booking) {
    return _generateReservationData(booking).generateESC();
  }

  List<int> generateSubscriptionReceiptESC(SubscriptionModel subscription) {
    return _generateSubscriptionData(subscription).generateESC();
  }

  List<int> generateTestESC() {
    return [
      ...utf8.encode('PRUEBA DE IMPRESION\n'),
      ...utf8.encode('Fecha: ${DateTimeConstants.formatDateTimeForPdf(DateTime.now(), 'America/La_Paz', format: 'dd/MM/yyyy HH:mm')}\n'),
      ...utf8.encode('Impresora Bluetooth OK\n\n'),
      0x1D, 0x56, 0x42, 0x00,
    ];
  }

  // Generar reporte de accesos en PDF
  Future<Uint8List> generateAccessReport({
    required List<AccessModel> accesses,
    required String periodType,
    required String parkingName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final pdf = pw.Document();

    // Cargar fuentes
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    // Calcular estadísticas
    final totalAccesses = accesses.length;
    final totalRevenue = accesses.fold<double>(0, (sum, access) => sum + access.amount);
    final activeAccesses = accesses.where((a) => a.exitTime == null).length;
    final completedAccesses = totalAccesses - activeAccesses;

    // Formatear período
    String periodText;
    switch (periodType) {
      case 'daily':
        periodText = 'Diario - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}';
        break;
      case 'weekly':
        final monday = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
        final sunday = monday.add(const Duration(days: 6));
        periodText = 'Semanal - ${DateFormat('dd/MM/yyyy').format(monday)} al ${DateFormat('dd/MM/yyyy').format(sunday)}';
        break;
      case 'monthly':
        periodText = 'Mensual - ${DateFormat('MMMM yyyy').format(DateTime.now())}';
        break;
      case 'custom':
        periodText = 'Personalizado - ${DateFormat('dd/MM/yyyy').format(startDate!)} al ${DateFormat('dd/MM/yyyy').format(endDate!)}';
        break;
      default:
        periodText = 'Período no especificado';
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Encabezado
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'REPORTE DE ACCESOS',
                    style: pw.TextStyle(font: fontBold, fontSize: 20),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    parkingName,
                    style: pw.TextStyle(font: font, fontSize: 14),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Período: $periodText',
                    style: pw.TextStyle(font: font, fontSize: 12),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Generado: ${DateTimeConstants.formatDateTimeForPdf(DateTime.now(), 'America/La_Paz', format: 'dd/MM/yyyy HH:mm')}',
                    style: pw.TextStyle(font: font, fontSize: 10),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Estadísticas
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Total Accesos', totalAccesses.toString(), font, fontBold),
                  _buildStatItem('Activos', activeAccesses.toString(), font, fontBold),
                  _buildStatItem('Completados', completedAccesses.toString(), font, fontBold),
                  _buildStatItem('Ingresos Totales',
                    CurrencyConstants.formatAmountForPdf(totalRevenue, 'BOB', 2),
                    font, fontBold),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Tabla de accesos
            pw.Text(
              'DETALLE DE ACCESOS',
              style: pw.TextStyle(font: fontBold, fontSize: 14),
            ),
            pw.SizedBox(height: 10),

            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey),
              columnWidths: {
                0: const pw.FlexColumnWidth(1), // Fecha/Hora
                1: const pw.FlexColumnWidth(1), // Placa
                2: const pw.FlexColumnWidth(1), // Tipo
                3: const pw.FlexColumnWidth(2), // Propietario
                4: const pw.FlexColumnWidth(1), // Monto
                5: const pw.FlexColumnWidth(1), // Estado
              },
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _buildTableHeader('Fecha/Hora', fontBold),
                    _buildTableHeader('Placa', fontBold),
                    _buildTableHeader('Tipo', fontBold),
                    _buildTableHeader('Propietario', fontBold),
                    _buildTableHeader('Monto', fontBold),
                    _buildTableHeader('Estado', fontBold),
                  ],
                ),
                // Data rows
                ...accesses.map((access) => pw.TableRow(
                  children: [
                    _buildTableCell(DateTimeConstants.formatDateTimeForPdf(access.entryTime, 'America/La_Paz', format: 'dd/MM/yyyy HH:mm'), font),
                    _buildTableCell(access.vehicle.plate.toUpperCase(), font),
                    _buildTableCell(_formatVehicleType(access.vehicle.type), font),
                    _buildTableCell(access.vehicle.ownerName ?? '--', font),
                    _buildTableCell(CurrencyConstants.formatAmountForPdf(access.amount, 'BOB', 2), font),
                    _buildTableCell(access.exitTime == null ? 'Activo' : 'Completado', font),
                  ],
                )),
              ],
            ),

            pw.SizedBox(height: 20),

            // Footer
            pw.Footer(
              leading: pw.Text(
                '© ${DateTime.now().year} ParKar - Reporte generado automáticamente',
                style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildStatItem(String label, String value, pw.Font font, pw.Font fontBold) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(font: fontBold, fontSize: 16),
        ),
        pw.Text(
          label,
          style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700),
        ),
      ],
    );
  }

  pw.Widget _buildTableHeader(String text, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 10, fontWeight: pw.FontWeight.bold),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildTableCell(String text, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 9),
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value, pw.Font fontBold, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(font: fontBold, fontSize: 10),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value, style: pw.TextStyle(font: font, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  // Generar reporte de caja
  Future<Uint8List> generateCashRegisterReport({
    required CashRegisterModel cashRegister,
    required List<MovementModel> movements,
    required String parkingName,
  }) async {
    final pdf = pw.Document();

    // Cargar fuentes
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    // Calcular estadísticas
    final totalIncome = movements.where((m) => m.type == 'income').fold<double>(0, (sum, m) => sum + m.amount);
    final totalExpenses = movements.where((m) => m.type == 'expense').fold<double>(0, (sum, m) => sum + m.amount);
    final netAmount = cashRegister.totalAmount;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Encabezado
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'REPORTE DE CAJA',
                    style: pw.TextStyle(font: fontBold, fontSize: 20),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    parkingName,
                    style: pw.TextStyle(font: font, fontSize: 14),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Caja #${cashRegister.number}',
                    style: pw.TextStyle(font: font, fontSize: 12),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Generado: ${DateTimeConstants.formatDateTimeForPdf(DateTime.now(), 'America/La_Paz', format: 'dd/MM/yyyy HH:mm')}',
                    style: pw.TextStyle(font: font, fontSize: 10),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Información de la caja
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'INFORMACIÓN DE LA CAJA',
                    style: pw.TextStyle(font: fontBold, fontSize: 14),
                  ),
                  pw.SizedBox(height: 12),
                  _buildInfoRow('Número de Caja', cashRegister.number.toString(), fontBold, font),
                  _buildInfoRow('Usuario', cashRegister.employee.name, fontBold, font),
                  _buildInfoRow('Fecha de Apertura', DateTimeConstants.formatDateTimeForPdf(cashRegister.startDate, 'America/La_Paz', format: 'dd/MM/yyyy HH:mm'), fontBold, font),
                  _buildInfoRow('Fecha de Cierre', cashRegister.endDate != null ? DateTimeConstants.formatDateTimeForPdf(cashRegister.endDate!, 'America/La_Paz', format: 'dd/MM/yyyy HH:mm') : '--', fontBold, font),
                  _buildInfoRow('Monto Inicial', CurrencyConstants.formatAmountForPdf(cashRegister.initialAmount, 'BOB', 2), fontBold, font),
                  _buildInfoRow('Monto Actual', CurrencyConstants.formatAmountForPdf(netAmount, 'BOB', 2), fontBold, font),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Estadísticas
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Total Ingresos', CurrencyConstants.formatAmountForPdf(totalIncome, 'BOB', 2), font, fontBold),
                  _buildStatItem('Total Egresos', CurrencyConstants.formatAmountForPdf(totalExpenses, 'BOB', 2), font, fontBold),
                  _buildStatItem('Saldo Neto', CurrencyConstants.formatAmountForPdf(netAmount, 'BOB', 2), font, fontBold),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Tabla de movimientos
            pw.Text(
              'DETALLE DE MOVIMIENTOS',
              style: pw.TextStyle(font: fontBold, fontSize: 14),
            ),
            pw.SizedBox(height: 10),

            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey),
              columnWidths: {
                0: const pw.FlexColumnWidth(1), // Fecha/Hora
                1: const pw.FlexColumnWidth(1), // Tipo
                2: const pw.FlexColumnWidth(2), // Descripción
                3: const pw.FlexColumnWidth(1), // Monto
              },
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _buildTableHeader('Fecha/Hora', fontBold),
                    _buildTableHeader('Tipo', fontBold),
                    _buildTableHeader('Descripción', fontBold),
                    _buildTableHeader('Monto', fontBold),
                  ],
                ),
                // Data rows
                ...movements.map((movement) => pw.TableRow(
                  children: [
                    _buildTableCell(DateTimeConstants.formatDateTimeForPdf(movement.createdAt, 'America/La_Paz', format: 'dd/MM/yyyy HH:mm'), font),
                    _buildTableCell(movement.type == 'income' ? 'Ingreso' : 'Egreso', font),
                    _buildTableCell(movement.description, font),
                    _buildTableCell(CurrencyConstants.formatAmountForPdf(movement.amount, 'BOB', 2), font),
                  ],
                )),
              ],
            ),

            pw.SizedBox(height: 20),

            // Footer
            pw.Footer(
              leading: pw.Text(
                '© ${DateTime.now().year} ParKar - Reporte generado automáticamente',
                style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }
}
