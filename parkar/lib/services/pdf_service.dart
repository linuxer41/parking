import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:parkar/models/booking_model.dart';
import 'package:parkar/models/access_model.dart';
import 'package:parkar/models/subscription_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class PdfService {
  // Función para crear un ticket con diseño unificado
  Future<Uint8List> _createUnifiedTicket({
    required String title,
    required String parkingName,
    required String parkingAddress,
    required String ticketNumber,
    required DateTime dateTime,
    required Map<String, String> vehicleInfo,
    Map<String, String>? ownerInfo,
    Map<String, String>? paymentInfo,
    required String footerMessage,
  }) async {
    final pdf = pw.Document();

    // Cargar fuentes
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();
    final fontItalic = pw.Font.helveticaOblique();

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
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Encabezado: Título, nombre del parqueo, dirección, número de ticket y fecha
                pw.Center(
                  child: pw.Text(
                    title.toUpperCase(),
                    style: pw.TextStyle(font: fontBold, fontSize: 12),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Center(
                  child: pw.Text(
                    parkingName.toUpperCase(),
                    style: pw.TextStyle(font: fontBold, fontSize: 10),
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Center(
                  child: pw.Text(
                    parkingAddress,
                    style: pw.TextStyle(font: font, fontSize: 8),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Ticket: $ticketNumber',
                      style: pw.TextStyle(font: font, fontSize: 8),
                    ),
                    pw.Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(dateTime),
                      style: pw.TextStyle(font: font, fontSize: 8),
                    ),
                  ],
                ),

                // Primer separador
                pw.SizedBox(height: 5),
                pw.Divider(thickness: 1, color: PdfColors.black),
                pw.SizedBox(height: 5),

                // Información del vehículo
                pw.Text(
                  'INFORMACIÓN DEL VEHÍCULO',
                  style: pw.TextStyle(font: fontBold, fontSize: 9),
                ),
                pw.SizedBox(height: 3),
                ...vehicleInfo.entries.map(
                  (entry) =>
                      _buildInfoRow(entry.key, entry.value, fontBold, font),
                ),

                // Información del propietario si existe
                if (ownerInfo != null && ownerInfo.isNotEmpty) ...[
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'INFORMACIÓN DEL PROPIETARIO',
                    style: pw.TextStyle(font: fontBold, fontSize: 9),
                  ),
                  pw.SizedBox(height: 3),
                  ...ownerInfo.entries.map(
                    (entry) =>
                        _buildInfoRow(entry.key, entry.value, fontBold, font),
                  ),
                ],

                // Información de pago si existe
                if (paymentInfo != null && paymentInfo.isNotEmpty) ...[
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'INFORMACIÓN DE PAGO',
                    style: pw.TextStyle(font: fontBold, fontSize: 9),
                  ),
                  pw.SizedBox(height: 3),
                  ...paymentInfo.entries.map(
                    (entry) =>
                        _buildInfoRow(entry.key, entry.value, fontBold, font),
                  ),
                ],

                // Segundo separador
                pw.SizedBox(height: 5),
                pw.Divider(thickness: 1, color: PdfColors.black),
                pw.SizedBox(height: 5),

                // Mensaje y copyright
                pw.Center(
                  child: pw.Text(
                    footerMessage,
                    style: pw.TextStyle(font: fontBold, fontSize: 8),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    '© ${DateTime.now().year} ParKar - Todos los derechos reservados',
                    style: pw.TextStyle(font: fontItalic, fontSize: 6),
                    textAlign: pw.TextAlign.center,
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

  // Función para crear filas de información
  pw.Widget _buildInfoRow(
    String label,
    String value,
    pw.Font fontBold,
    pw.Font font,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 60,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(font: fontBold, fontSize: 8),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value, style: pw.TextStyle(font: font, fontSize: 8)),
          ),
        ],
      ),
    );
  }

  // Método para estandarizar los tipos de acceso
  String _standardizeAccessType(String? accessType) {
    if (accessType == null) return 'Normal';

    final lowercaseType = accessType.toLowerCase();
    if (lowercaseType.contains('reserv')) {
      return 'Reserva';
    } else if (lowercaseType.contains('suscri') ||
        lowercaseType.contains('subscri')) {
      return 'Suscripción';
    } else {
      return 'Normal';
    }
  }

  // Generar ticket de entrada
  Future<Uint8List> generateEntryTicket({
    required AccessModel booking,
  }) async {
    // Generar número de ticket único basado en timestamp
    final ticketNumber =
        'E${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    // Información básica del vehículo (solo facturación)
    final vehicleInfo = <String, String>{
      'Placa': booking.vehicle.plate.isNotEmpty ? booking.vehicle.plate.toUpperCase() : '--',
      'Tipo': booking.vehicle.type.isNotEmpty ? _formatVehicleType(booking.vehicle.type) : '--',
      'Color': booking.vehicle.color?.isNotEmpty == true ? booking.vehicle.color! : '--',
    };

    // Solo agregar información del espacio si no está vacío
    if (booking.spotId != null && booking.spotId!.isNotEmpty) {
      vehicleInfo['Espacio'] = booking.spotId!;
    }

    return _createUnifiedTicket(
      title: 'TICKET DE ENTRADA',
      parkingName: booking.parking.name,
      parkingAddress: booking.parking.address ?? '',
      ticketNumber: ticketNumber,
      dateTime: booking.entryTime,
      vehicleInfo: vehicleInfo,
      footerMessage:
          'CONSERVE ESTE TICKET\nRequerido para la salida del vehículo',
    );
  }

  // Generar ticket de reserva
  Future<Uint8List> generateReservationTicket({
    required BookingModel booking,
  }) async {
    // Generar número de ticket único basado en timestamp
    final ticketNumber =
        'R${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    // Información del vehículo y reserva
    final vehicleInfo = <String, String>{
      'Placa': booking.vehicle.plate.isNotEmpty ? booking.vehicle.plate.toUpperCase() : '--',
      'Tipo': booking.vehicle.type.isNotEmpty ? _formatVehicleType(booking.vehicle.type) : '--',
      'Acceso': 'Reserva',
      'Inicio': DateFormat('dd/MM/yyyy HH:mm').format(booking.startDate),
      'Fin': DateFormat('dd/MM/yyyy HH:mm').format(booking.endDate ?? DateTime.now()),
      'Duración': '${booking.duration?.inHours ?? 0} horas',
    };

    // Solo agregar información del espacio si no está vacío
    if (booking.spotId?.isNotEmpty == true) {
      vehicleInfo['Espacio'] = booking.spotId!;
    }

    // Información del propietario (siempre mostrar, usar "--" para valores nulos)
    final ownerInfo = <String, String>{
      'Nombre': booking.vehicle.ownerName?.isNotEmpty == true ? booking.vehicle.ownerName! : '--',
      'Documento': booking.vehicle.ownerDocument?.isNotEmpty == true ? booking.vehicle.ownerDocument! : '--',
      'Teléfono': booking.vehicle.ownerPhone?.isNotEmpty == true ? booking.vehicle.ownerPhone! : '--',
    };

    return _createUnifiedTicket(
      title: 'RESERVA DE ESTACIONAMIENTO',
      parkingName: booking.parking.name,
      parkingAddress: booking.parking.address ?? '',
      ticketNumber: ticketNumber,
      dateTime: DateTime.now(),
      vehicleInfo: vehicleInfo,
      ownerInfo: ownerInfo,
      footerMessage:
          'PRESENTE ESTE TICKET AL LLEGAR\nLa reserva expira 15 minutos después de la hora indicada',
    );
  }

  // Generar recibo de suscripción
  Future<Uint8List> generateSubscriptionReceipt({
    required SubscriptionModel booking,
  }) async {
    // Generar número de ticket único basado en timestamp
    final ticketNumber =
        'S${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    // Información de la suscripción
    final vehicleInfo = {
      'Placa': booking.vehicle.plate.isNotEmpty ? booking.vehicle.plate.toUpperCase() : '--',
      'Acceso': 'Suscripción',
      // 'Plan': booking.subscription?.plan.isNotEmpty == true ? _formatSubscriptionType(booking.subscription!.plan) : '--',
      'Inicio': DateFormat('dd/MM/yyyy').format(booking.startDate),
      'Fin': DateFormat('dd/MM/yyyy').format(booking.endDate ?? DateTime.now()),
    };

    // Información del propietario (siempre mostrar, usar "--" para valores nulos)
    final ownerInfo = <String, String>{
      'Nombre': booking.vehicle.ownerName?.isNotEmpty == true ? booking.vehicle.ownerName! : '--',
      'Documento': booking.vehicle.ownerDocument?.isNotEmpty == true ? booking.vehicle.ownerDocument! : '--',
      'Teléfono': booking.vehicle.ownerPhone?.isNotEmpty == true ? booking.vehicle.ownerPhone! : '--',
    };

    // Información de pago
    final paymentInfo = {
      'Monto': '\$${booking.amount.toStringAsFixed(2)}',
      'Método': 'Efectivo',
      'Estado': 'Pagado',
    };

    return _createUnifiedTicket(
      title: 'RECIBO DE SUSCRIPCIÓN',
      parkingName: booking.parking.name,
      parkingAddress: booking.parking.address ?? '',
      ticketNumber: ticketNumber,
      dateTime: DateTime.now(),
      vehicleInfo: vehicleInfo,
      ownerInfo: ownerInfo,
      paymentInfo: paymentInfo,
      footerMessage:
          'RECIBO OFICIAL\nConserve este documento para cualquier aclaración',
    );
  }

  // Generar ticket de salida
  Future<Uint8List> generateExitTicket({
    required AccessModel booking,
  }) async {
    // Generar número de ticket único basado en timestamp
    final ticketNumber =
        'S${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    // Estandarizar el tipo de acceso
    final standardAccessType = _standardizeAccessType('access'); // Always 'access' for exits

    // Información del vehículo y estancia
    final vehicleInfo = <String, String>{
      'Placa': booking.vehicle.plate.isNotEmpty ? booking.vehicle.plate.toUpperCase() : '--',
      'Acceso': standardAccessType,
      'Entrada': DateFormat('dd/MM/yyyy HH:mm').format(booking.entryTime),
      'Salida': DateFormat('dd/MM/yyyy HH:mm').format(booking.exitTime ?? DateTime.now()),
      'Duración': _formatDuration(booking.duration ?? Duration.zero),
    };

    // Solo agregar información del espacio si no está vacío
    if (booking.spotId?.isNotEmpty == true) {
      vehicleInfo['Espacio'] = booking.spotId!;
    }

    // Información de pago
    final paymentInfo = {
      'Tarifa': '\$${booking.amount.toStringAsFixed(2)}',
    };

    // Añadir empleado (siempre mostrar, usar "--" si no está disponible)
    paymentInfo['Atendido por'] = booking.employee?.name.isNotEmpty == true ? booking.employee!.name : '--';

    return _createUnifiedTicket(
      title: 'TICKET DE SALIDA',
      parkingName: booking.parking.name,
      parkingAddress: booking.parking.address ?? '',
      ticketNumber: ticketNumber,
      dateTime: booking.exitTime ?? DateTime.now(),
      vehicleInfo: vehicleInfo,
      paymentInfo: paymentInfo,
      footerMessage:
          'GRACIAS POR SU VISITA\nEste documento es un comprobante de pago',
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

  // Método para formatear el tipo de suscripción
  String _formatSubscriptionType(String subscriptionType) {
    switch (subscriptionType) {
      case 'weekly':
        return 'Semanal';
      case 'monthly':
        return 'Mensual';
      case 'annual':
        return 'Anual';
      default:
        return subscriptionType;
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

  // Generar PDF de prueba
  Future<Uint8List> generateTestPrint() async {
    final pdf = pw.Document();

    // Cargar fuentes
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          80 * PdfPageFormat.mm,
          100 * PdfPageFormat.mm,
          marginAll: 5,
        ),
        build: (pw.Context context) {
          return pw.Container(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'PRUEBA DE IMPRESIÓN',
                  style: pw.TextStyle(font: fontBold, fontSize: 14),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                  style: pw.TextStyle(font: font, fontSize: 10),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Impresión Nativa OK',
                  style: pw.TextStyle(font: fontBold, fontSize: 12),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  '© ${DateTime.now().year} ParKar',
                  style: pw.TextStyle(font: font, fontSize: 8),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
