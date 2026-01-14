import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../constants/constants.dart';
import '../models/access_model.dart';
import '../models/booking_model.dart';
import '../models/printer_model.dart';
import '../models/subscription_model.dart';

// Unified data model for all ticket types
class TicketData {
  final String title;
  final String parkingName;
  final String ticketNumber;
  final String dateLabel;
  final DateTime dateTime;
  final List<MapEntry<String, String>> vehicleInfo;
  final List<MapEntry<String, String>>? paymentInfo;
  final String footerMessage;
  final bool showPaymentHeader;

  TicketData({
    required this.title,
    required this.parkingName,
    required this.ticketNumber,
    required this.dateLabel,
    required this.dateTime,
    required this.vehicleInfo,
    this.paymentInfo,
    required this.footerMessage,
    this.showPaymentHeader = true,
  });

  // Generate ZPL
  String generateZPL() {
    final buffer = StringBuffer();
    buffer.writeln('^XA');
    buffer.writeln('^PW576');
    buffer.writeln('^LL600');
    buffer.writeln('^CI28');
    buffer.writeln('^FO0,40^FB576,1,0,C^A0N,30,30^FD$title^FS');
    buffer.writeln('^FO0,80^FB576,1,0,C^A0N,28,28^FD${parkingName.toUpperCase()}^FS');
    buffer.writeln('^FO0,120^A0N,22,22^FDNro:^FS');
    buffer.writeln('^FO350,120^FB226,1,0,R^A0N,22,22^FD$ticketNumber^FS');
    buffer.writeln('^FO0,150^A0N,22,22^FD$dateLabel^FS');
    buffer.writeln('^FO350,150^FB226,1,0,R^A0N,22,22^FD${DateFormat('dd/MM/yyyy HH:mm').format(dateTime)}^FS');
    buffer.writeln('^FO0,180^GB576,1,1,B,0^FS');

    int yOffset = 210;
    for (final entry in vehicleInfo) {
      buffer.writeln('^FO0,${yOffset}^A0N,22,22^FD${entry.key}:^FS');
      buffer.writeln('^FO350,${yOffset}^FB226,1,0,R^A0N,22,22^FD${entry.value}^FS');
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
    buffer.writeln('^FO0,${yOffset}^FB576,1,0,C^A0N,20,20^FD$footerMessage^FS');
    buffer.writeln('^XZ');
    return buffer.toString();
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
                pw.SizedBox(height: 8),
                // Nombre del parqueo
                pw.Text(
                  parkingName.toUpperCase(),
                  style: pw.TextStyle(font: fontBold, fontSize: 12),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 8),
                // Número de ticket
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Nro:',
                      style: pw.TextStyle(font: fontBold, fontSize: 10),
                    ),
                    pw.Text(
                      ticketNumber,
                      style: pw.TextStyle(font: fontBold, fontSize: 10),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                // Fecha
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      '$dateLabel',
                      style: pw.TextStyle(font: fontBold, fontSize: 10),
                    ),
                    pw.Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(dateTime),
                      style: pw.TextStyle(font: fontBold, fontSize: 10),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
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
                            style: pw.TextStyle(font: fontBold, fontSize: 10),
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
                pw.Text(
                  footerMessage,
                  style: pw.TextStyle(font: fontBold, fontSize: 10),
                  textAlign: pw.TextAlign.center,
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
    bytes.addAll(utf8.encode('\n$footerMessage\n\n'));
    // Cut
    bytes.addAll([0x1D, 0x56, 0x42, 0x00]); // GS V B 0
    return bytes;
  }
}

class DocumentService {
  FlutterBluetoothPrinter bluetooth = FlutterBluetoothPrinter();

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
// Función para crear un ticket ZPL unificado
String _createUnifiedTicketZPL({
  required String title,
  required String parkingName,
  required String ticketNumber,
  required String dateLabel,
  required DateTime dateTime,
  required List<MapEntry<String, String>> vehicleInfo,
  List<MapEntry<String, String>>? paymentInfo,
  required String footerMessage,
  bool showPaymentHeader = true,
}) {
  final buffer = StringBuffer();
  buffer.writeln('^XA');
  buffer.writeln('^PW576');
  buffer.writeln('^LL600');
  buffer.writeln('^CI28');
  buffer.writeln('^FO0,40^FB576,1,0,C^A0N,30,30^FD$title^FS');
  buffer.writeln('^FO0,80^FB576,1,0,C^A0N,28,28^FD${parkingName.toUpperCase()}^FS');
  buffer.writeln('^FO0,120^A0N,22,22^FDNro:^FS');
  buffer.writeln('^FO350,120^FB226,1,0,R^A0N,22,22^FD$ticketNumber^FS');
  buffer.writeln('^FO0,150^A0N,22,22^FD$dateLabel^FS');
  buffer.writeln('^FO350,150^FB226,1,0,R^A0N,22,22^FD${DateFormat('dd/MM/yyyy HH:mm').format(dateTime)}^FS');
  buffer.writeln('^FO0,180^GB576,1,1,B,0^FS');

  int yOffset = 210;
  for (final entry in vehicleInfo) {
    buffer.writeln('^FO0,${yOffset}^A0N,22,22^FD${entry.key}:^FS');
    buffer.writeln('^FO350,${yOffset}^FB226,1,0,R^A0N,22,22^FD${entry.value}^FS');
    yOffset += 30;
  }

  if (paymentInfo != null && paymentInfo.isNotEmpty) {
    buffer.writeln('^FO0,${yOffset}^GB576,1,1,B,0^FS');
    yOffset += 30;
    if (showPaymentHeader) {
      buffer.writeln('^FO0,${yOffset}^FB576,1,0,C^A0N,26,26^FDPAGO^FS');
      yOffset += 30;
    }
    for (final entry in paymentInfo) {
      buffer.writeln('^FO0,${yOffset}^A0N,22,22^FD${entry.key}:^FS');
      buffer.writeln('^FO350,${yOffset}^FB226,1,0,R^A0N,22,22^FD${entry.value}^FS');
      yOffset += 30;
    }
  }

  buffer.writeln('^FO0,${yOffset}^GB576,1,1,B,0^FS');
  yOffset += 30;
  buffer.writeln('^FO0,${yOffset}^FB576,1,0,C^A0N,20,20^FD$footerMessage^FS');
  buffer.writeln('^XZ');
  return buffer.toString();
}

// Generar datos unificados para ticket de entrada
TicketData _generateEntryTicketData(AccessModel access) {
  final vehicleInfo = <MapEntry<String, String>>[
    MapEntry('Placa', access.vehicle.plate.isNotEmpty ? access.vehicle.plate.toUpperCase() : '--'),
    MapEntry('Tipo', access.vehicle.type.isNotEmpty ? _formatVehicleType(access.vehicle.type) : '--'),
    MapEntry('Color', access.vehicle.color?.isNotEmpty == true ? access.vehicle.color! : '--'),
  ];

  if (access.spot?.id != null) {
    vehicleInfo.add(MapEntry('Espacio', access.spot?.name ?? '--'));
  }

  return TicketData(
    title: 'TICKET DE ENTRADA',
    parkingName: access.parking.name,
    ticketNumber: access.number?.toString().padLeft(6, '0') ?? '000000',
    dateLabel: 'Fecha de ingreso:',
    dateTime: access.entryTime,
    vehicleInfo: vehicleInfo,
    footerMessage: 'Conserve este ticket, requerido para la salida',
  );
}
  // Generar datos unificados para ticket de salida
  TicketData _generateExitTicketData(AccessModel access) {
    final exitTime = access.exitTime ?? DateTime.now();
    final duration = exitTime.difference(access.entryTime);

    final vehicleInfo = <MapEntry<String, String>>[
      MapEntry('Placa', access.vehicle.plate.isNotEmpty ? access.vehicle.plate.toUpperCase() : '--'),
      MapEntry('Entrada', DateFormat('dd/MM/yyyy HH:mm').format(access.entryTime)),
      MapEntry('Salida', DateFormat('dd/MM/yyyy HH:mm').format(exitTime)),
      MapEntry('Duracion', _formatDuration(duration)),
    ];

    if (access.spot?.name?.isNotEmpty == true) {
      vehicleInfo.add(MapEntry('Espacio', access.spot?.name ?? ''));
    }

    final paymentInfo = <MapEntry<String, String>>[
      MapEntry('Tarifa', CurrencyConstants.formatAmountForPdf(access.amount, access.parking.params?.currency ?? 'BOB', access.parking.params?.decimalPlaces ?? 2)),
    ];

    final attendedBy = access.employee?.name.isNotEmpty == true ? access.employee!.name : '--';

    return TicketData(
      title: 'TICKET DE SALIDA',
      parkingName: access.parking.name,
      ticketNumber: access.number?.toString().padLeft(6, '0') ?? '000000',
      dateLabel: 'Fecha de salida:',
      dateTime: exitTime,
      vehicleInfo: vehicleInfo,
      paymentInfo: paymentInfo,
      footerMessage: 'Atendido por: $attendedBy gracias por su visita este documento es comprobante de pago',
      showPaymentHeader: false,
    );
  }

  // Generar ZPL para reserva
  String _generateReservationTicketZPL(BookingModel booking) {
    final vehicleInfo = <MapEntry<String, String>>[
      MapEntry('Placa', booking.vehicle.plate.isNotEmpty ? booking.vehicle.plate.toUpperCase() : '--'),
      MapEntry('Tipo', booking.vehicle.type.isNotEmpty ? _formatVehicleType(booking.vehicle.type) : '--'),
      MapEntry('Inicio', DateFormat('dd/MM/yyyy HH:mm').format(booking.startDate)),
      MapEntry('Fin', DateFormat('dd/MM/yyyy HH:mm').format(booking.endDate ?? DateTime.now())),
      MapEntry('Duracion', '${booking.duration?.inHours ?? 0} horas'),
    ];

    if (booking.spotId?.isNotEmpty == true) {
      vehicleInfo.add(MapEntry('Espacio', booking.spotId!));
    }

    return _createUnifiedTicketZPL(
      title: 'RESERVA DE ESTACIONAMIENTO',
      parkingName: booking.parking.name,
      ticketNumber: booking.number?.toString().padLeft(6, '0') ?? '000000',
      dateLabel: 'Fecha de reserva:',
      dateTime: DateTime.now(),
      vehicleInfo: vehicleInfo,
      footerMessage: 'Presente este ticket al llegar, la reserva expira 15 min despues',
    );
  }

  // Generar ZPL para suscripción
  String _generateSubscriptionReceiptZPL(SubscriptionModel booking) {
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

    return _createUnifiedTicketZPL(
      title: 'RECIBO DE SUSCRIPCION',
      parkingName: booking.parking.name,
      ticketNumber: booking.number?.toString().padLeft(6, '0') ?? '000000',
      dateLabel: 'Fecha de emision:',
      dateTime: DateTime.now(),
      vehicleInfo: vehicleInfo,
      paymentInfo: paymentInfo,
      footerMessage: 'Recibo oficial conserve este documento',
    );
  }

  // Imprimir ticket de entrada
  Future<bool> printEntryTicket(
    AccessModel booking,
    String address,
    PrinterType printerType,
  ) async {
    try {
      print('printEntryTicket');
      final data = _generateEntryTicketData(booking);
      if (printerType == PrinterType.zebra) {
        // Generate ZPL and send to printer
        final zpl = data.generateZPL();
        await _sendZPLToPrinter(zpl, address);
      } else {
        // Generate ESC/POS
        final escPos = data.generateESC();
        await _sendESCToPrinter(escPos, address);
      }
      return true;
    } catch (e) {
      print('Error imprimiendo ticket de entrada: $e');
      return false;
    }
  }

  // Imprimir ticket de salida
  Future<bool> printExitTicket(AccessModel booking, String address, PrinterType printerType) async {
    if (!(await isConnected)) return false;

    try {
      final data = _generateExitTicketData(booking);
      final zpl = data.generateZPL();
      await _sendZPLToPrinter(zpl, address);
      return true;
    } catch (e) {
      print('Error imprimiendo ticket de salida: $e');
      return false;
    }
  }

  // Imprimir ticket de reserva
  Future<bool> printReservationTicket(BookingModel booking, String address, PrinterType printerType) async {
    if (!(await isConnected)) return false;

    try {
      final zpl = _generateReservationTicketZPL(booking);
      await _sendZPLToPrinter(zpl, address);
      return true;
    } catch (e) {
      print('Error imprimiendo ticket de reserva: $e');
      return false;
    }
  }

  // Imprimir recibo de suscripción
  Future<bool> printSubscriptionReceipt(SubscriptionModel booking, String address, PrinterType printerType) async {
    if (!(await isConnected)) return false;

    try {
      final zpl = _generateSubscriptionReceiptZPL(booking);
      await _sendZPLToPrinter(zpl, address);
      return true;
    } catch (e) {
      print('Error imprimiendo recibo de suscripción: $e');
      return false;
    }
  }

  // Imprimir prueba
  Future<bool> printTest(String address, PrinterType printerType) async {
    try {
      print('Imprimiendo prueba...');
      Uint8List data;
      if (printerType == PrinterType.zebra) {
        // ZPL test
        final zpl =
            '''
^XA
^PW576
^LL200
^CI28
^FO0,40^FB576,1,0,C^A0N,30,30^FDPRUEBA DE IMPRESION^FS
^FO0,80^A0N,22,22^FDFecha:^FS
^FO350,80^FB226,1,0,R^A0N,22,22^FD${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}^FS
^FO0,110^A0N,22,22^FDEstado:^FS
^FO350,110^FB226,1,0,R^A0N,22,22^FDImpresora Bluetooth OK^FS
^XZ
''';
        data = latin1.encode(zpl);
      } else {
        // ESC/POS test
        data = Uint8List.fromList([
          ...utf8.encode('PRUEBA DE IMPRESION\n'),
          ...utf8.encode(
            'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}\n',
          ),
          ...utf8.encode('Impresora Bluetooth OK\n\n'),
          // Cut paper
          0x1D, 0x56, 0x42, 0x00,
        ]);
      }
      print('Enviando ${data.length} bytes');
      final res = await FlutterBluetoothPrinter.printBytes(
        address: address,
        data: data,
        keepConnected: true,
      );
      print('Prueba imprimida exitosamente. Res: $res');
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      print('Error imprimiendo prueba: $e');
      return false;
    }
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

  // Send ZPL data to printer
  Future<void> _sendZPLToPrinter(String zpl, String address) async {
    try {
      final data = latin1.encode(zpl);
      await FlutterBluetoothPrinter.printBytes(
        address: address,
        data: data,
        keepConnected: true,
      );
    } catch (e) {
      print('Error sending ZPL to printer: $e');
      throw e;
    }
  }

  // Generar ESC/POS para ticket de entrada
  List<int> _generateEntryTicketESC(AccessModel booking) {
    List<int> bytes = [];
    // Initialize
    bytes.addAll([0x1B, 0x40]); // ESC @
    // Center align
    bytes.addAll([0x1B, 0x61, 0x01]); // ESC a 1
    // Bold
    bytes.addAll([0x1B, 0x45, 0x01]); // ESC E 1
    bytes.addAll(utf8.encode('${booking.parking.name.toUpperCase()}\n'));
    bytes.addAll(utf8.encode('${booking.parking.address ?? ''}\n'));
    bytes.addAll(utf8.encode('TICKET DE ENTRADA\n'));
    // Normal
    bytes.addAll([0x1B, 0x45, 0x00]); // ESC E 0
    bytes.addAll([0x1B, 0x61, 0x00]); // ESC a 0
    bytes.addAll(
      utf8.encode('Placa: ${booking.vehicle.plate.toUpperCase()}\n'),
    );
    bytes.addAll(
      utf8.encode(
        'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(booking.entryTime)}\n',
      ),
    );
    bytes.addAll(utf8.encode('\n\n'));
    // Cut
    bytes.addAll([0x1D, 0x56, 0x42, 0x00]); // GS V B 0
    return bytes;
  }

  // Send ESC/POS data to printer
  Future<void> _sendESCToPrinter(List<int> escPos, String address) async {
    try {
      await FlutterBluetoothPrinter.printBytes(
        address:address,
        data: Uint8List.fromList(escPos),
        keepConnected: true,
      );
    } catch (e) {
      print('Error sending ESC/POS to printer: $e');
      throw e;
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
    final vehicleInfo = <MapEntry<String, String>>[
      MapEntry('Placa', booking.vehicle.plate.isNotEmpty ? booking.vehicle.plate.toUpperCase() : '--'),
      MapEntry('Tipo', booking.vehicle.type.isNotEmpty ? _formatVehicleType(booking.vehicle.type) : '--'),
      MapEntry('Inicio', DateFormat('dd/MM/yyyy HH:mm').format(booking.startDate)),
      MapEntry('Fin', DateFormat('dd/MM/yyyy HH:mm').format(booking.endDate ?? DateTime.now())),
      MapEntry('Duracion', '${booking.duration?.inHours ?? 0} horas'),
    ];

    if (booking.spotId?.isNotEmpty == true) {
      vehicleInfo.add(MapEntry('Espacio', booking.spotId!));
    }

    final data = TicketData(
      title: 'RESERVA DE ESTACIONAMIENTO',
      parkingName: booking.parking.name,
      ticketNumber: booking.number?.toString().padLeft(6, '0') ?? '000000',
      dateLabel: 'Fecha de reserva:',
      dateTime: DateTime.now(),
      vehicleInfo: vehicleInfo,
      footerMessage: 'Presente este ticket al llegar, la reserva expira 15 min despues',
    );
    return data.generatePDF();
  }

  Future<Uint8List> generateSubscriptionReceiptPDF(SubscriptionModel subscription) async {
    final vehicleInfo = <MapEntry<String, String>>[
      MapEntry('Placa', subscription.vehicle.plate.isNotEmpty ? subscription.vehicle.plate.toUpperCase() : '--'),
      MapEntry('Inicio', DateFormat('dd/MM/yyyy').format(subscription.startDate)),
      MapEntry('Fin', DateFormat('dd/MM/yyyy').format(subscription.endDate ?? DateTime.now())),
    ];

    final paymentInfo = <MapEntry<String, String>>[
      MapEntry('Monto', CurrencyConstants.formatAmountForPdf(subscription.amount, subscription.parking.params?.currency ?? 'BOB', subscription.parking.params?.decimalPlaces ?? 2)),
      MapEntry('Metodo', 'Efectivo'),
      MapEntry('Estado', 'Pagado'),
    ];

    final data = TicketData(
      title: 'RECIBO DE SUSCRIPCION',
      parkingName: subscription.parking.name,
      ticketNumber: subscription.number?.toString().padLeft(6, '0') ?? '000000',
      dateLabel: 'Fecha de emision:',
      dateTime: DateTime.now(),
      vehicleInfo: vehicleInfo,
      paymentInfo: paymentInfo,
      footerMessage: 'Recibo oficial conserve este documento',
    );
    return data.generatePDF();
  }

  Future<Uint8List> generateTestPrintPDF() async {
    final data = TicketData(
      title: 'PRUEBA DE IMPRESION',
      parkingName: 'ParKar',
      ticketNumber: '000000',
      dateLabel: 'Fecha:',
      dateTime: DateTime.now(),
      vehicleInfo: [
        MapEntry('Estado', 'Impresora OK'),
      ],
      footerMessage: 'Prueba completada exitosamente',
    );
    return data.generatePDF();
  }
}
