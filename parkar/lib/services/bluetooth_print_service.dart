import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import '../models/booking_model.dart';
import '../models/access_model.dart';
import '../models/subscription_model.dart';
import 'package:intl/intl.dart';
import 'print_service.dart'; // For PrinterType

class BluetoothPrintService {
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
  String _generateEntryTicketZPL(AccessModel booking) {
    final ticketNumber = 'E${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    String zpl = '''
^XA
^CF0,25
^FO20,20^FD${booking.parking.name.toUpperCase()}^FS
^CF0,20
^FO20,50^FD${booking.parking.address ?? ''}^FS
^FO20,80^FDTICKET DE ENTRADA^FS
^FO20,110^FDNro: $ticketNumber^FS
^FO20,140^FD${DateFormat('dd/MM/yyyy HH:mm').format(booking.entryTime)}^FS
^FO20,180^FDVEHICULO:^FS
^FO20,210^FDPlaca: ${booking.vehicle.plate.toUpperCase()}^FS
^FO20,240^FDTipo: ${_formatVehicleType(booking.vehicle.type)}^FS
^FO20,270^FDColor: ${booking.vehicle.color ?? '--'}^FS
''';

    if (booking.spot?.name?.isNotEmpty == true) {
      zpl += '^FO20,300^FDEspacio: ${booking.spot?.name}^FS\n';
    }

    zpl += '''
^FO20,330^FDPROPIETARIO:^FS
^FO20,360^FDNombre: ${booking.vehicle.ownerName ?? '--'}^FS
^FO20,390^FDDoc: ${booking.vehicle.ownerDocument ?? '--'}^FS
^FO20,420^FDTel: ${booking.vehicle.ownerPhone ?? '--'}^FS
^FO20,460^FDCONSERVE ESTE TICKET^FS
^FO20,490^FDRequerido para la salida^FS
^XZ
''';

    return zpl;
  }

  // Generar ZPL para ticket de salida
  String _generateExitTicketZPL(AccessModel booking) {
    final ticketNumber = 'S${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final exitTime = booking.exitTime ?? DateTime.now();
    final duration = exitTime.difference(booking.entryTime);

    String zpl = '''
^XA
^CF0,25
^FO20,20^FD${booking.parking.name.toUpperCase()}^FS
^CF0,20
^FO20,50^FD${booking.parking.address ?? ''}^FS
^FO20,80^FDTICKET DE SALIDA^FS
^FO20,110^FDNro: $ticketNumber^FS
^FO20,140^FD${DateFormat('dd/MM/yyyy HH:mm').format(booking.exitTime ?? DateTime.now())}^FS
^FO20,180^FDVEHICULO:^FS
^FO20,210^FDPlaca: ${booking.vehicle.plate.toUpperCase()}^FS
^FO20,240^FDEntrada: ${DateFormat('dd/MM/yyyy HH:mm').format(booking.entryTime)}^FS
^FO20,270^FDSalida: ${DateFormat('dd/MM/yyyy HH:mm').format(booking.exitTime ?? DateTime.now())}^FS
^FO20,300^FDDuracion: ${_formatDuration(duration)}^FS
''';

    if (booking.spot?.id.isNotEmpty == true) {
      zpl += '^FO20,330^FDEspacio: ${booking.spot?.name}^FS\n';
    }

    zpl += '''
^FO20,360^FDPAGO:^FS
^FO20,390^FDTarifa: \$${booking.amount.toStringAsFixed(2)}^FS
^FO20,420^FDAtendido por: ${booking.employee?.name ?? '--'}^FS
^FO20,460^FDGRACIAS POR SU VISITA^FS
^FO20,490^FDEste documento es comprobante de pago^FS
^XZ
''';

    return zpl;
  }

  // Generar ZPL para reserva
  String _generateReservationTicketZPL(BookingModel booking) {
    final ticketNumber = 'R${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    String zpl = '''
^XA
^CF0,25
^FO20,20^FD${booking.parking.name.toUpperCase()}^FS
^CF0,20
^FO20,50^FD${booking.parking.address ?? ''}^FS
^FO20,80^FDRESERVA DE ESTACIONAMIENTO^FS
^FO20,110^FDNro: $ticketNumber^FS
^FO20,140^FD${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}^FS
^FO20,180^FDVEHICULO:^FS
^FO20,210^FDPlaca: ${booking.vehicle.plate.toUpperCase()}^FS
^FO20,240^FDTipo: ${_formatVehicleType(booking.vehicle.type)}^FS
^FO20,270^FDInicio: ${DateFormat('dd/MM/yyyy HH:mm').format(booking.startDate)}^FS
^FO20,300^FDFin: ${DateFormat('dd/MM/yyyy HH:mm').format(booking.endDate ?? DateTime.now())}^FS
^FO20,330^FDDuracion: ${booking.duration?.inHours ?? 0} horas^FS
''';

    if (booking.spotId?.isNotEmpty == true) {
      zpl += '^FO20,360^FDEspacio: ${booking.spotId}^FS\n';
    }

    zpl += '''
^FO20,390^FDPROPIETARIO:^FS
^FO20,420^FDNombre: ${booking.vehicle.ownerName ?? '--'}^FS
^FO20,450^FDDoc: ${booking.vehicle.ownerDocument ?? '--'}^FS
^FO20,480^FDTel: ${booking.vehicle.ownerPhone ?? '--'}^FS
^FO20,520^FDPRESENTE ESTE TICKET AL LLEGAR^FS
^FO20,550^FDLa reserva expira 15 min despues^FS
^XZ
''';

    return zpl;
  }

  // Generar ZPL para suscripción
  String _generateSubscriptionReceiptZPL(SubscriptionModel booking) {
    final ticketNumber = 'S${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    String zpl = '''
^XA
^CF0,25
^FO20,20^FD${booking.parking.name.toUpperCase()}^FS
^CF0,20
^FO20,50^FD${booking.parking.address ?? ''}^FS
^FO20,80^FDRECIBO DE SUSCRIPCION^FS
^FO20,110^FDNro: $ticketNumber^FS
^FO20,140^FD${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}^FS
^FO20,180^FDVEHICULO:^FS
^FO20,210^FDPlaca: ${booking.vehicle.plate.toUpperCase()}^FS
^FO20,240^FDInicio: ${DateFormat('dd/MM/yyyy').format(booking.startDate)}^FS
^FO20,270^FDFin: ${DateFormat('dd/MM/yyyy').format(booking.endDate ?? DateTime.now())}^FS
^FO20,300^FDPROPIETARIO:^FS
^FO20,330^FDNombre: ${booking.vehicle.ownerName ?? '--'}^FS
^FO20,360^FDDoc: ${booking.vehicle.ownerDocument ?? '--'}^FS
^FO20,390^FDTel: ${booking.vehicle.ownerPhone ?? '--'}^FS
^FO20,420^FDPAGO:^FS
^FO20,450^FDMonto: \$${booking.amount.toStringAsFixed(2)}^FS
^FO20,480^FDMetodo: Efectivo^FS
^FO20,510^FDEstado: Pagado^FS
^FO20,550^FDRECIBO OFICIAL^FS
^FO20,580^FDConserve este documento^FS
^XZ
''';

    return zpl;
  }

  // Imprimir ticket de entrada
  Future<bool> printEntryTicket(AccessModel booking, PrinterType printerType) async {
    if (!(await isConnected)) return false;

    try {
      if (printerType == PrinterType.zebra) {
        // Generate ZPL and send to printer
        final zpl = _generateEntryTicketZPL(booking);
        await _sendZPLToPrinter(zpl);
      } else {
        // Generate ESC/POS
        final escPos = _generateEntryTicketESC(booking);
        await _sendESCToPrinter(escPos);
      }
      return true;
    } catch (e) {
      print('Error imprimiendo ticket de entrada: $e');
      return false;
    }
  }

  // Imprimir ticket de salida
  Future<bool> printExitTicket(AccessModel booking) async {
    if (!(await isConnected)) return false;

    try {
      final zpl = _generateExitTicketZPL(booking);
      await _sendZPLToPrinter(zpl);
      return true;
    } catch (e) {
      print('Error imprimiendo ticket de salida: $e');
      return false;
    }
  }

  // Imprimir ticket de reserva
  Future<bool> printReservationTicket(BookingModel booking) async {
    if (!(await isConnected)) return false;

    try {
      final zpl = _generateReservationTicketZPL(booking);
      await _sendZPLToPrinter(zpl);
      return true;
    } catch (e) {
      print('Error imprimiendo ticket de reserva: $e');
      return false;
    }
  }

  // Imprimir recibo de suscripción
  Future<bool> printSubscriptionReceipt(SubscriptionModel booking) async {
    if (!(await isConnected)) return false;

    try {
      final zpl = _generateSubscriptionReceiptZPL(booking);
      await _sendZPLToPrinter(zpl);
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
        final zpl = '''
^XA
^CF0,30
^FO50,50^FDPRUEBA DE IMPRESION^FS
^FO50,100^FDFecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}^FS
^FO50,150^FDImpresora Bluetooth OK^FS
^XZ
''';
        data = latin1.encode(zpl);
      } else {
        // ESC/POS test
        data = Uint8List.fromList([
          ...utf8.encode('PRUEBA DE IMPRESION\n'),
          ...utf8.encode('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}\n'),
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
  Future<void> _sendZPLToPrinter(String zpl) async {
    try {
      final data = latin1.encode(zpl);
      await FlutterBluetoothPrinter.printBytes(
        address: '', // Use connected
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
    bytes.addAll(utf8.encode('Placa: ${booking.vehicle.plate.toUpperCase()}\n'));
    bytes.addAll(utf8.encode('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(booking.entryTime)}\n'));
    bytes.addAll(utf8.encode('\n\n'));
    // Cut
    bytes.addAll([0x1D, 0x56, 0x42, 0x00]); // GS V B 0
    return bytes;
  }

  // Send ESC/POS data to printer
  Future<void> _sendESCToPrinter(List<int> escPos) async {
    try {
      await FlutterBluetoothPrinter.printBytes(
        address: '', // Use connected
        data: Uint8List.fromList(escPos),
        keepConnected: true,
      );
    } catch (e) {
      print('Error sending ESC/POS to printer: $e');
      throw e;
    }
  }

  // Helper method for printing lines (placeholder)
  Future<void> _printLine(String text, {bool bold = false, bool center = false}) async {
    // TODO: Implement with correct API
    print('Print line: $text (bold: $bold, center: $center)');
  }

  // Helper method for cutting paper (placeholder)
  Future<void> _cutPaper() async {
    // TODO: Implement with correct API
    print('Cutting paper');
  }
}