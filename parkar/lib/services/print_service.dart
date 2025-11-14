import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import 'pdf_service.dart';
import '../widgets/pdf_viewer.dart';

class PrintService {
  final PdfService _pdfService = PdfService();

  // Imprimir ticket de entrada
  Future<void> printEntryTicket({
    required BookingModel booking,
    required BuildContext context,
    bool isSimpleMode = false,
  }) async {
    final pdfData = await _pdfService.generateEntryTicket(
      booking: booking,
    );

    if (context.mounted) {
      PdfViewer.show(
        context,
        pdfData: pdfData,
        title: 'Ticket de Entrada',
        filename: 'entrada_${booking.vehicle.plate.replaceAll(' ', '_')}',
      );
    }
  }

  // Imprimir ticket de salida
  Future<void> printExitTicket({
    required BookingModel booking,
    required BuildContext context,
    bool isSimpleMode = false,
  }) async {
    final pdfData = await _pdfService.generateExitTicket(
      booking: booking,
    );

    if (context.mounted) {
      PdfViewer.show(
        context,
        pdfData: pdfData,
        title: 'Ticket de Salida',
        filename: 'salida_${booking.vehicle.plate.replaceAll(' ', '_')}',
      );
    }
  }

  // Imprimir ticket de reserva
  Future<void> printReservationTicket({
    required BookingModel booking,
    required BuildContext context,
    bool isSimpleMode = false,
  }) async {
    final pdfData = await _pdfService.generateReservationTicket(
      booking: booking,
    );

    if (context.mounted) {
      PdfViewer.show(
        context,
        pdfData: pdfData,
        title: 'Reserva de Estacionamiento',
        filename: 'reserva_${booking.vehicle.plate.replaceAll(' ', '_')}',
      );
    }
  }

  // Imprimir recibo de suscripción
  Future<void> printSubscriptionReceipt({
    required BookingModel booking,
    required BuildContext context,
  }) async {
    final pdfData = await _pdfService.generateSubscriptionReceipt(
      booking: booking,
    );

    if (context.mounted) {
      PdfViewer.show(
        context,
        pdfData: pdfData,
        title: 'Recibo de Suscripción',
        filename: 'suscripcion_${booking.vehicle.plate.replaceAll(' ', '_')}',
      );
    }
  }
}
