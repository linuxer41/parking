import 'dart:typed_data';
import 'package:flutter/services.dart';
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
        pageFormat: const PdfPageFormat(80 * PdfPageFormat.mm, 200 * PdfPageFormat.mm, marginAll: 5),
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
                ...vehicleInfo.entries.map((entry) => _buildInfoRow(entry.key, entry.value, fontBold, font)),
                
                // Información del propietario si existe
                if (ownerInfo != null && ownerInfo.isNotEmpty) ...[
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'INFORMACIÓN DEL PROPIETARIO',
                    style: pw.TextStyle(font: fontBold, fontSize: 9),
                  ),
                  pw.SizedBox(height: 3),
                  ...ownerInfo.entries.map((entry) => _buildInfoRow(entry.key, entry.value, fontBold, font)),
                ],
                
                // Información de pago si existe
                if (paymentInfo != null && paymentInfo.isNotEmpty) ...[
            pw.SizedBox(height: 5),
                  pw.Text(
                    'INFORMACIÓN DE PAGO',
                    style: pw.TextStyle(font: fontBold, fontSize: 9),
                  ),
            pw.SizedBox(height: 3),
                  ...paymentInfo.entries.map((entry) => _buildInfoRow(entry.key, entry.value, fontBold, font)),
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
  pw.Widget _buildInfoRow(String label, String value, pw.Font fontBold, pw.Font font) {
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
            child: pw.Text(
              value,
              style: pw.TextStyle(font: font, fontSize: 8),
            ),
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
    } else if (lowercaseType.contains('suscri') || lowercaseType.contains('subscri')) {
      return 'Suscripción';
    } else {
      return 'Normal';
    }
  }

  // Generar ticket de entrada
  Future<Uint8List> generateEntryTicket({
    required String parkingName,
    required String parkingAddress,
    required String plate,
    required String spotLabel,
    required DateTime entryTime,
    required String vehicleType,
    required String color,
    String? ownerName,
    String? ownerDocument,
    String? ownerPhone,
    String? accessType,
  }) async {
    // Generar número de ticket único basado en timestamp
    final ticketNumber = 'E${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    
    // Estandarizar el tipo de acceso
    final standardAccessType = _standardizeAccessType(accessType);
    
    // Información del vehículo
    final vehicleInfo = {
      'Placa': plate.toUpperCase(),
      'Espacio': spotLabel,
      'Tipo': _formatVehicleType(vehicleType),
      'Color': color,
      'Acceso': standardAccessType,
    };
    
    // Información del propietario si está disponible
    final ownerInfo = <String, String>{};
    if (ownerName != null && ownerName.isNotEmpty) {
      ownerInfo['Nombre'] = ownerName;
    }
    if (ownerDocument != null && ownerDocument.isNotEmpty) {
      ownerInfo['Documento'] = ownerDocument;
    }
    if (ownerPhone != null && ownerPhone.isNotEmpty) {
      ownerInfo['Teléfono'] = ownerPhone;
    }
    
    return _createUnifiedTicket(
            title: 'TICKET DE ENTRADA',
            parkingName: parkingName,
      parkingAddress: parkingAddress,
      ticketNumber: ticketNumber,
            dateTime: entryTime,
      vehicleInfo: vehicleInfo,
      ownerInfo: ownerInfo.isNotEmpty ? ownerInfo : null,
      footerMessage: 'CONSERVE ESTE TICKET\nRequerido para la salida del vehículo',
    );
  }
  
  // Generar ticket de reserva
  Future<Uint8List> generateReservationTicket({
    required String parkingName,
    required String parkingAddress,
    required String plate,
    required String spotLabel,
    required DateTime reservationDate,
    required int durationHours,
    required String vehicleType,
    String? ownerName,
    String? ownerDocument,
    String? ownerPhone,
  }) async {
    // Generar número de ticket único basado en timestamp
    final ticketNumber = 'R${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    
    // Calcular fecha de fin
    final endDate = reservationDate.add(Duration(hours: durationHours));
    
    // Información del vehículo y reserva
    final vehicleInfo = {
      'Placa': plate.toUpperCase(),
      'Espacio': spotLabel,
      'Tipo': _formatVehicleType(vehicleType),
      'Acceso': 'Reserva',
      'Inicio': DateFormat('dd/MM/yyyy HH:mm').format(reservationDate),
      'Fin': DateFormat('dd/MM/yyyy HH:mm').format(endDate),
      'Duración': '$durationHours horas',
    };
    
    // Información del propietario si está disponible
    final ownerInfo = <String, String>{};
    if (ownerName != null && ownerName.isNotEmpty) {
      ownerInfo['Nombre'] = ownerName;
    }
    if (ownerDocument != null && ownerDocument.isNotEmpty) {
      ownerInfo['Documento'] = ownerDocument;
    }
    if (ownerPhone != null && ownerPhone.isNotEmpty) {
      ownerInfo['Teléfono'] = ownerPhone;
    }
    
    return _createUnifiedTicket(
      title: 'RESERVA DE ESTACIONAMIENTO',
      parkingName: parkingName,
      parkingAddress: parkingAddress,
      ticketNumber: ticketNumber,
      dateTime: DateTime.now(),
      vehicleInfo: vehicleInfo,
      ownerInfo: ownerInfo.isNotEmpty ? ownerInfo : null,
      footerMessage: 'PRESENTE ESTE TICKET AL LLEGAR\nLa reserva expira 15 minutos después de la hora indicada',
    );
  }
  
  // Generar recibo de suscripción
  Future<Uint8List> generateSubscriptionReceipt({
    required String parkingName,
    required String parkingAddress,
    required String plate,
    required String subscriptionType,
    required DateTime startDate,
    required DateTime endDate,
    required double amount,
    String? ownerName,
    String? ownerDocument,
    String? ownerPhone,
  }) async {
    // Generar número de ticket único basado en timestamp
    final ticketNumber = 'S${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    
    // Información de la suscripción
    final vehicleInfo = {
      'Placa': plate.toUpperCase(),
      'Acceso': 'Suscripción',
      'Plan': _formatSubscriptionType(subscriptionType),
      'Inicio': DateFormat('dd/MM/yyyy').format(startDate),
      'Fin': DateFormat('dd/MM/yyyy').format(endDate),
    };
    
    // Información del propietario si está disponible
    final ownerInfo = <String, String>{};
    if (ownerName != null && ownerName.isNotEmpty) {
      ownerInfo['Nombre'] = ownerName;
    }
    if (ownerDocument != null && ownerDocument.isNotEmpty) {
      ownerInfo['Documento'] = ownerDocument;
    }
    if (ownerPhone != null && ownerPhone.isNotEmpty) {
      ownerInfo['Teléfono'] = ownerPhone;
    }
    
    // Información de pago
    final paymentInfo = {
      'Monto': '\$${amount.toStringAsFixed(2)}',
      'Método': 'Efectivo',
      'Estado': 'Pagado',
    };
    
    return _createUnifiedTicket(
      title: 'RECIBO DE SUSCRIPCIÓN',
      parkingName: parkingName,
      parkingAddress: parkingAddress,
      ticketNumber: ticketNumber,
      dateTime: DateTime.now(),
      vehicleInfo: vehicleInfo,
      ownerInfo: ownerInfo.isNotEmpty ? ownerInfo : null,
      paymentInfo: paymentInfo,
      footerMessage: 'RECIBO OFICIAL\nConserve este documento para cualquier aclaración',
    );
  }
  
  // Generar ticket de salida
  Future<Uint8List> generateExitTicket({
    required String parkingName,
    required String parkingAddress,
    required String plate,
    required String spotLabel,
    required DateTime entryTime,
    required DateTime exitTime,
    required Duration duration,
    required double cost,
    String? employeeName,
    String? accessType,
  }) async {
    // Generar número de ticket único basado en timestamp
    final ticketNumber = 'S${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    
    // Estandarizar el tipo de acceso
    final standardAccessType = _standardizeAccessType(accessType);
    
    // Información del vehículo y estancia
    final vehicleInfo = {
      'Placa': plate.toUpperCase(),
      'Espacio': spotLabel,
      'Acceso': standardAccessType,
      'Entrada': DateFormat('dd/MM/yyyy HH:mm').format(entryTime),
      'Salida': DateFormat('dd/MM/yyyy HH:mm').format(exitTime),
      'Duración': _formatDuration(duration),
    };
    
    // Información de pago
    final paymentInfo = {
      'Tarifa': standardAccessType == 'Suscripción' ? 'Sin cargo' : '\$${cost.toStringAsFixed(2)}',
    };
    
    // Añadir empleado si está disponible
    if (employeeName != null && employeeName.isNotEmpty) {
      paymentInfo['Atendido por'] = employeeName;
    }
    
    return _createUnifiedTicket(
      title: 'TICKET DE SALIDA',
      parkingName: parkingName,
      parkingAddress: parkingAddress,
      ticketNumber: ticketNumber,
      dateTime: exitTime,
      vehicleInfo: vehicleInfo,
      paymentInfo: paymentInfo,
      footerMessage: 'GRACIAS POR SU VISITA\nEste documento es un comprobante de pago',
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
} 