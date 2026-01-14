// import 'dart:typed_data';
// import 'package:flutter/services.dart';
// import 'package:parkar/constants/constants.dart';
// import 'package:parkar/models/booking_model.dart';
// import 'package:parkar/models/access_model.dart';
// import 'package:parkar/models/subscription_model.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:intl/intl.dart';

// class PdfService {
//   // Función para crear un ticket con diseño unificado
//   Future<Uint8List> _createUnifiedTicket({
//     required String title,
//     required String parkingName,
//     required String ticketNumber,
//     required String dateLabel,
//     required DateTime dateTime,
//     required List<MapEntry<String, String>> vehicleInfo,
//     List<MapEntry<String, String>>? paymentInfo,
//     required String footerMessage,
//     bool showPaymentHeader = true,
//   }) async {
//     final pdf = pw.Document();

//     // Cargar fuentes
//     final font = pw.Font.helvetica();
//     final fontBold = pw.Font.helveticaBold();

//     // Crear página con formato de ticket
//     pdf.addPage(
//       pw.Page(
//         pageFormat: const PdfPageFormat(
//           80 * PdfPageFormat.mm,
//           200 * PdfPageFormat.mm,
//           marginAll: 5,
//         ),
//         build: (pw.Context context) {
//           return pw.Container(
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.center,
//               children: [
//                 // Título
//                 pw.Text(
//                   title.toUpperCase(),
//                   style: pw.TextStyle(font: fontBold, fontSize: 14),
//                   textAlign: pw.TextAlign.center,
//                 ),
//                 pw.SizedBox(height: 8),
//                 // Nombre del parqueo
//                 pw.Text(
//                   parkingName.toUpperCase(),
//                   style: pw.TextStyle(font: fontBold, fontSize: 12),
//                   textAlign: pw.TextAlign.center,
//                 ),
//                 pw.SizedBox(height: 8),
//                 // Número de ticket
//                 pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Text(
//                       'Nro:',
//                       style: pw.TextStyle(font: fontBold, fontSize: 10),
//                     ),
//                     pw.Text(
//                       ticketNumber,
//                       style: pw.TextStyle(font: fontBold, fontSize: 10),
//                     ),
//                   ],
//                 ),
//                 pw.SizedBox(height: 8),
//                 // Fecha
//                 pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Text(
//                       '$dateLabel',
//                       style: pw.TextStyle(font: fontBold, fontSize: 10),
//                     ),
//                     pw.Text(
//                       DateFormat('dd/MM/yyyy HH:mm').format(dateTime),
//                       style: pw.TextStyle(font: fontBold, fontSize: 10),
//                     ),
//                   ],
//                 ),
//                 pw.SizedBox(height: 8),
//                 // Separador
//                 pw.Divider(thickness: 1, color: PdfColors.black),
//                 pw.SizedBox(height: 8),

//                 // Información del vehículo
//                 ...vehicleInfo.map(
//                   (entry) => pw.Column(
//                     children: [
//                       pw.Row(
//                         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                         children: [
//                           pw.Text(
//                             '${entry.key}:',
//                             style: pw.TextStyle(font: fontBold, fontSize: 10),
//                           ),
//                           pw.Text(
//                             entry.value,
//                             style: pw.TextStyle(font: fontBold, fontSize: 10),
//                           ),
//                         ],
//                       ),
//                       pw.SizedBox(height: 4),
//                     ],
//                   ),
//                 ),

//                 // Información de pago si existe
//                 if (paymentInfo != null && paymentInfo.isNotEmpty) ...[
//                   if (showPaymentHeader) ...[
//                     pw.SizedBox(height: 8),
//                     pw.Divider(thickness: 1, color: PdfColors.black),
//                     pw.SizedBox(height: 8),
//                     pw.Text(
//                       'PAGO',
//                       style: pw.TextStyle(font: fontBold, fontSize: 12),
//                       textAlign: pw.TextAlign.center,
//                     ),
//                     pw.SizedBox(height: 8),
//                   ],
//                   ...paymentInfo.map(
//                     (entry) => pw.Column(
//                       children: [
//                         pw.Row(
//                           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                           children: [
//                             pw.Text(
//                               '${entry.key}:',
//                               style: pw.TextStyle(font: fontBold, fontSize: 12),
//                             ),
//                             pw.Text(
//                               entry.value,
//                               style: pw.TextStyle(font: fontBold, fontSize: 12),
//                             ),
//                           ],
//                         ),
//                         pw.SizedBox(height: 4),
//                       ],
//                     ),
//                   ),
//                 ],

//                 // Separador
//                 pw.SizedBox(height: 8),
//                 pw.Divider(thickness: 1, color: PdfColors.black),
//                 pw.SizedBox(height: 8),

//                 // Mensaje
//                 pw.Text(
//                   footerMessage,
//                   style: pw.TextStyle(font: fontBold, fontSize: 10),
//                   textAlign: pw.TextAlign.center,
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );

//     return pdf.save();
//   }

//   // Función para crear filas de información
//   pw.Widget _buildInfoRow(
//     String label,
//     String value,
//     pw.Font fontBold,
//     pw.Font font,
//   ) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.symmetric(vertical: 2),
//       child: pw.Row(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.SizedBox(
//             width: 60,
//             child: pw.Text(
//               '$label:',
//               style: pw.TextStyle(font: fontBold, fontSize: 8),
//             ),
//           ),
//           pw.Expanded(
//             child: pw.Text(value, style: pw.TextStyle(font: font, fontSize: 8)),
//           ),
//         ],
//       ),
//     );
//   }

//   // Método para estandarizar los tipos de acceso
//   String _standardizeAccessType(String? accessType) {
//     if (accessType == null) return 'Normal';

//     final lowercaseType = accessType.toLowerCase();
//     if (lowercaseType.contains('reserv')) {
//       return 'Reserva';
//     } else if (lowercaseType.contains('suscri') ||
//         lowercaseType.contains('subscri')) {
//       return 'Suscripción';
//     } else {
//       return 'Normal';
//     }
//   }

//   // Generar ticket de entrada
//   Future<Uint8List> generateEntryTicket({required AccessModel access}) async {
//     // Información básica del vehículo
//     final vehicleInfo = <MapEntry<String, String>>[
//       MapEntry('Placa', access.vehicle.plate.isNotEmpty
//           ? access.vehicle.plate.toUpperCase()
//           : '--'),
//       MapEntry('Tipo', access.vehicle.type.isNotEmpty
//           ? _formatVehicleType(access.vehicle.type)
//           : '--'),
//       MapEntry('Color', access.vehicle.color?.isNotEmpty == true
//           ? access.vehicle.color!
//           : '--'),
//     ];

//     // Solo agregar información del espacio si no está vacío
//     if (access.spot?.id != null) {
//       vehicleInfo.add(MapEntry('Espacio', access.spot?.name ?? '--'));
//     }

//     return _createUnifiedTicket(
//       title: 'TICKET DE ENTRADA',
//       parkingName: access.parking.name,
//       ticketNumber: access.number?.toString().padLeft(6, '0') ?? '000000',
//       dateLabel: 'Fecha de ingreso:',
//       dateTime: access.entryTime,
//       vehicleInfo: vehicleInfo,
//       footerMessage: 'Conserve este ticket requerido para la salida',
//     );
//   }

//   // Generar ticket de reserva
//   Future<Uint8List> generateReservationTicket({
//     required BookingModel booking,
//   }) async {
//     // Información del vehículo y reserva
//     final vehicleInfo = <MapEntry<String, String>>[
//       MapEntry('Placa', booking.vehicle.plate.isNotEmpty
//           ? booking.vehicle.plate.toUpperCase()
//           : '--'),
//       MapEntry('Tipo', booking.vehicle.type.isNotEmpty
//           ? _formatVehicleType(booking.vehicle.type)
//           : '--'),
//       MapEntry('Inicio', DateFormat('dd/MM/yyyy HH:mm').format(booking.startDate)),
//       MapEntry('Fin', DateFormat('dd/MM/yyyy HH:mm').format(booking.endDate ?? DateTime.now())),
//       MapEntry('Duración', '${booking.duration?.inHours ?? 0} horas'),
//     ];

//     // Solo agregar información del espacio si no está vacío
//     if (booking.spotId?.isNotEmpty == true) {
//       vehicleInfo.add(MapEntry('Espacio', booking.spotId!));
//     }

//     return _createUnifiedTicket(
//       title: 'RESERVA DE ESTACIONAMIENTO',
//       parkingName: booking.parking.name,
//       ticketNumber: booking.number?.toString().padLeft(6, '0') ?? '000000',
//       dateLabel: 'Fecha de reserva:',
//       dateTime: DateTime.now(),
//       vehicleInfo: vehicleInfo,
//       footerMessage: 'Presente este ticket al llegar la reserva expira 15 min despues',
//     );
//   }

//   // Generar recibo de suscripción
//   Future<Uint8List> generateSubscriptionReceipt({
//     required SubscriptionModel subscription,
//   }) async {
//     // Información de la suscripción
//     final vehicleInfo = <MapEntry<String, String>>[
//       MapEntry('Placa', subscription.vehicle.plate.isNotEmpty
//           ? subscription.vehicle.plate.toUpperCase()
//           : '--'),
//       MapEntry('Inicio', DateFormat('dd/MM/yyyy').format(subscription.startDate)),
//       MapEntry('Fin', DateFormat('dd/MM/yyyy').format(subscription.endDate ?? DateTime.now())),
//     ];

//     // Información de pago
//     final paymentInfo = <MapEntry<String, String>>[
//       MapEntry('Monto', CurrencyConstants.formatAmountForPdf(
//         subscription.amount,
//         subscription.parking.params?.currency ?? 'BOB',
//         subscription.parking.params?.decimalPlaces ?? 2,
//       )),
//       MapEntry('Metodo', 'Efectivo'),
//       MapEntry('Estado', 'Pagado'),
//     ];

//     return _createUnifiedTicket(
//       title: 'RECIBO DE SUSCRIPCION',
//       parkingName: subscription.parking.name,
//       ticketNumber: subscription.number?.toString().padLeft(6, '0') ?? '000000',
//       dateLabel: 'Fecha de emision:',
//       dateTime: DateTime.now(),
//       vehicleInfo: vehicleInfo,
//       paymentInfo: paymentInfo,
//       footerMessage: 'Recibo oficial conserve este documento',
//     );
//   }

//   // Generar ticket de salida
//   Future<Uint8List> generateExitTicket({required AccessModel access}) async {
//     final exitTime = access.exitTime ?? DateTime.now();
//     final duration = exitTime.difference(access.entryTime);

//     // Información del vehículo y estancia
//     final vehicleInfo = <MapEntry<String, String>>[
//       MapEntry('Placa', access.vehicle.plate.isNotEmpty
//           ? access.vehicle.plate.toUpperCase()
//           : '--'),
//       MapEntry('Entrada', DateFormat('dd/MM/yyyy HH:mm').format(access.entryTime)),
//       MapEntry('Salida', DateFormat('dd/MM/yyyy HH:mm').format(exitTime)),
//       MapEntry('Duracion', _formatDuration(duration)),
//     ];

//     // Solo agregar información del espacio si no está vacío
//     if (access.spot?.id.isNotEmpty == true) {
//       vehicleInfo.add(MapEntry('Espacio', access.spot?.name ?? ''));
//     }

//     // Información de pago
//     final paymentInfo = <MapEntry<String, String>>[
//       MapEntry('Tarifa', CurrencyConstants.formatAmountForPdf(
//         access.amount,
//         access.parking.params?.currency ?? 'BOB',
//         access.parking.params?.decimalPlaces ?? 2,
//       )),
//     ];

//     final attendedBy = access.employee?.name.isNotEmpty == true
//         ? access.employee!.name
//         : '--';

//     return _createUnifiedTicket(
//       title: 'TICKET DE SALIDA',
//       parkingName: access.parking.name,
//       ticketNumber: access.number?.toString().padLeft(6, '0') ?? '000000',
//       dateLabel: 'Fecha de salida:',
//       dateTime: exitTime,
//       vehicleInfo: vehicleInfo,
//       paymentInfo: paymentInfo,
//       footerMessage: 'Atendido por: $attendedBy gracias por su visita este documento es comprobante de pago',
//       showPaymentHeader: false,
//     );
//   }

//   // Método para formatear el tipo de vehículo
//   String _formatVehicleType(String vehicleType) {
//     switch (vehicleType) {
//       case 'car':
//         return 'Automóvil';
//       case 'motorcycle':
//         return 'Motocicleta';
//       case 'truck':
//         return 'Camioneta';
//       default:
//         return vehicleType;
//     }
//   }

//   // Método para formatear el tipo de suscripción
//   String _formatSubscriptionType(String subscriptionType) {
//     switch (subscriptionType) {
//       case 'weekly':
//         return 'Semanal';
//       case 'monthly':
//         return 'Mensual';
//       case 'annual':
//         return 'Anual';
//       default:
//         return subscriptionType;
//     }
//   }

//   // Método para formatear la duración
//   String _formatDuration(Duration duration) {
//     final hours = duration.inHours;
//     final minutes = duration.inMinutes % 60;

//     if (hours > 0) {
//       return '$hours h ${minutes.toString().padLeft(2, '0')} m';
//     } else {
//       return '${minutes.toString().padLeft(2, '0')} m';
//     }
//   }

//   // Generar reporte de accesos en PDF
//   Future<Uint8List> generateAccessReport({
//     required List<AccessModel> accesses,
//     required String periodType,
//     required String parkingName,
//     DateTime? startDate,
//     DateTime? endDate,
//   }) async {
//     final pdf = pw.Document();

//     // Cargar fuentes
//     final font = pw.Font.helvetica();
//     final fontBold = pw.Font.helveticaBold();

//     // Calcular estadísticas
//     final totalAccesses = accesses.length;
//     final totalRevenue = accesses.fold<double>(0, (sum, access) => sum + access.amount);
//     final activeAccesses = accesses.where((a) => a.exitTime == null).length;
//     final completedAccesses = totalAccesses - activeAccesses;

//     // Formatear período
//     String periodText;
//     switch (periodType) {
//       case 'daily':
//         periodText = 'Diario - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}';
//         break;
//       case 'weekly':
//         final monday = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
//         final sunday = monday.add(const Duration(days: 6));
//         periodText = 'Semanal - ${DateFormat('dd/MM/yyyy').format(monday)} al ${DateFormat('dd/MM/yyyy').format(sunday)}';
//         break;
//       case 'monthly':
//         periodText = 'Mensual - ${DateFormat('MMMM yyyy').format(DateTime.now())}';
//         break;
//       case 'custom':
//         periodText = 'Personalizado - ${DateFormat('dd/MM/yyyy').format(startDate!)} al ${DateFormat('dd/MM/yyyy').format(endDate!)}';
//         break;
//       default:
//         periodText = 'Período no especificado';
//     }

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(32),
//         build: (pw.Context context) {
//           return [
//             // Encabezado
//             pw.Header(
//               level: 0,
//               child: pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Text(
//                     'REPORTE DE ACCESOS',
//                     style: pw.TextStyle(font: fontBold, fontSize: 20),
//                   ),
//                   pw.SizedBox(height: 8),
//                   pw.Text(
//                     parkingName,
//                     style: pw.TextStyle(font: font, fontSize: 14),
//                   ),
//                   pw.SizedBox(height: 4),
//                   pw.Text(
//                     'Período: $periodText',
//                     style: pw.TextStyle(font: font, fontSize: 12),
//                   ),
//                   pw.SizedBox(height: 4),
//                   pw.Text(
//                     'Generado: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
//                     style: pw.TextStyle(font: font, fontSize: 10),
//                   ),
//                 ],
//               ),
//             ),

//             pw.SizedBox(height: 20),

//             // Estadísticas
//             pw.Container(
//               padding: const pw.EdgeInsets.all(16),
//               decoration: pw.BoxDecoration(
//                 border: pw.Border.all(color: PdfColors.grey),
//                 borderRadius: pw.BorderRadius.circular(8),
//               ),
//               child: pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
//                 children: [
//                   _buildStatItem('Total Accesos', totalAccesses.toString(), font, fontBold),
//                   _buildStatItem('Activos', activeAccesses.toString(), font, fontBold),
//                   _buildStatItem('Completados', completedAccesses.toString(), font, fontBold),
//                   _buildStatItem('Ingresos Totales',
//                     CurrencyConstants.formatAmountForPdf(totalRevenue, 'BOB', 2),
//                     font, fontBold),
//                 ],
//               ),
//             ),

//             pw.SizedBox(height: 20),

//             // Tabla de accesos
//             pw.Text(
//               'DETALLE DE ACCESOS',
//               style: pw.TextStyle(font: fontBold, fontSize: 14),
//             ),
//             pw.SizedBox(height: 10),

//             pw.Table(
//               border: pw.TableBorder.all(color: PdfColors.grey),
//               columnWidths: {
//                 0: const pw.FlexColumnWidth(1), // Fecha/Hora
//                 1: const pw.FlexColumnWidth(1), // Placa
//                 2: const pw.FlexColumnWidth(1), // Tipo
//                 3: const pw.FlexColumnWidth(2), // Propietario
//                 4: const pw.FlexColumnWidth(1), // Monto
//                 5: const pw.FlexColumnWidth(1), // Estado
//               },
//               children: [
//                 // Header
//                 pw.TableRow(
//                   decoration: const pw.BoxDecoration(color: PdfColors.grey200),
//                   children: [
//                     _buildTableHeader('Fecha/Hora', fontBold),
//                     _buildTableHeader('Placa', fontBold),
//                     _buildTableHeader('Tipo', fontBold),
//                     _buildTableHeader('Propietario', fontBold),
//                     _buildTableHeader('Monto', fontBold),
//                     _buildTableHeader('Estado', fontBold),
//                   ],
//                 ),
//                 // Data rows
//                 ...accesses.map((access) => pw.TableRow(
//                   children: [
//                     _buildTableCell(DateFormat('dd/MM/yyyy HH:mm').format(access.entryTime), font),
//                     _buildTableCell(access.vehicle.plate.toUpperCase(), font),
//                     _buildTableCell(_formatVehicleType(access.vehicle.type), font),
//                     _buildTableCell(access.vehicle.ownerName ?? '--', font),
//                     _buildTableCell(CurrencyConstants.formatAmountForPdf(access.amount, 'BOB', 2), font),
//                     _buildTableCell(access.exitTime == null ? 'Activo' : 'Completado', font),
//                   ],
//                 )),
//               ],
//             ),

//             pw.SizedBox(height: 20),

//             // Footer
//             pw.Footer(
//               leading: pw.Text(
//                 '© ${DateTime.now().year} ParKar - Reporte generado automáticamente',
//                 style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey),
//               ),
//             ),
//           ];
//         },
//       ),
//     );

//     return pdf.save();
//   }

//   pw.Widget _buildStatItem(String label, String value, pw.Font font, pw.Font fontBold) {
//     return pw.Column(
//       children: [
//         pw.Text(
//           value,
//           style: pw.TextStyle(font: fontBold, fontSize: 16),
//         ),
//         pw.Text(
//           label,
//           style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700),
//         ),
//       ],
//     );
//   }

//   pw.Widget _buildTableHeader(String text, pw.Font font) {
//     return pw.Container(
//       padding: const pw.EdgeInsets.all(8),
//       child: pw.Text(
//         text,
//         style: pw.TextStyle(font: font, fontSize: 10, fontWeight: pw.FontWeight.bold),
//         textAlign: pw.TextAlign.center,
//       ),
//     );
//   }

//   pw.Widget _buildTableCell(String text, pw.Font font) {
//     return pw.Container(
//       padding: const pw.EdgeInsets.all(6),
//       child: pw.Text(
//         text,
//         style: pw.TextStyle(font: font, fontSize: 9),
//       ),
//     );
//   }

//   // Generar PDF de prueba
//   Future<Uint8List> generateTestPrint() async {
//     final pdf = pw.Document();

//     // Cargar fuentes
//     final font = pw.Font.helvetica();
//     final fontBold = pw.Font.helveticaBold();

//     pdf.addPage(
//       pw.Page(
//         pageFormat: const PdfPageFormat(
//           80 * PdfPageFormat.mm,
//           100 * PdfPageFormat.mm,
//           marginAll: 5,
//         ),
//         build: (pw.Context context) {
//           return pw.Container(
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.center,
//               children: [
//                 pw.Text(
//                   'PRUEBA DE IMPRESIÓN',
//                   style: pw.TextStyle(font: fontBold, fontSize: 14),
//                 ),
//                 pw.SizedBox(height: 10),
//                 pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Text(
//                       'Fecha:',
//                       style: pw.TextStyle(font: fontBold, fontSize: 10),
//                     ),
//                     pw.Text(
//                       DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
//                       style: pw.TextStyle(font: font, fontSize: 10),
//                     ),
//                   ],
//                 ),
//                 pw.SizedBox(height: 10),
//                 pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Text(
//                       'Estado:',
//                       style: pw.TextStyle(font: fontBold, fontSize: 12),
//                     ),
//                     pw.Text(
//                       'Impresión Nativa OK',
//                       style: pw.TextStyle(font: fontBold, fontSize: 12),
//                     ),
//                   ],
//                 ),
//                 pw.SizedBox(height: 20),
//                 pw.Text(
//                   '© ${DateTime.now().year} ParKar',
//                   style: pw.TextStyle(font: font, fontSize: 8),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );

//     return pdf.save();
//   }
// }
