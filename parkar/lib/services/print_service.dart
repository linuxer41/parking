import 'package:flutter/material.dart';
import 'pdf_service.dart';
import '../widgets/pdf_viewer.dart';

class PrintService {
  final PdfService _pdfService = PdfService();
  
  // Imprimir ticket de entrada
  Future<void> printEntryTicket({
    required String plate,
    required String spotLabel,
    required DateTime entryTime,
    required String vehicleType,
    required String color,
    required String parkingName,
    String parkingAddress = "Dirección no disponible",
    String? ownerName,
    String? ownerDocument,
    String? ownerPhone,
    String? accessType,
    required BuildContext context,
  }) async {
    final pdfData = await _pdfService.generateEntryTicket(
      parkingName: parkingName,
      parkingAddress: parkingAddress,
      plate: plate,
      spotLabel: spotLabel,
      entryTime: entryTime,
      vehicleType: vehicleType,
      color: color,
      ownerName: ownerName,
      ownerDocument: ownerDocument,
      ownerPhone: ownerPhone,
      accessType: accessType,
    );
    
    if (context.mounted) {
      PdfViewer.show(
        context,
        pdfData: pdfData,
        title: 'Ticket de Entrada',
        filename: 'entrada_${plate.replaceAll(' ', '_')}',
      );
    }
  }
  
  // Imprimir ticket de salida
  Future<void> printExitTicket({
    required String plate,
    required String spotLabel,
    required DateTime entryTime,
    required DateTime exitTime,
    required Duration duration,
    required double cost,
    required String parkingName,
    String parkingAddress = "Dirección no disponible",
    String? employeeName,
    required BuildContext context,
    String? accessType,
  }) async {
    final pdfData = await _pdfService.generateExitTicket(
      parkingName: parkingName,
      parkingAddress: parkingAddress,
      plate: plate,
      spotLabel: spotLabel,
      entryTime: entryTime,
      exitTime: exitTime,
      duration: duration,
      cost: cost,
      employeeName: employeeName,
      accessType: accessType,
    );
    
    if (context.mounted) {
      PdfViewer.show(
        context,
        pdfData: pdfData,
        title: 'Ticket de Salida',
        filename: 'salida_${plate.replaceAll(' ', '_')}',
      );
    }
  }
  
  // Imprimir ticket de reserva
  Future<void> printReservationTicket({
    required String plate,
    required String spotLabel,
    required DateTime reservationDate,
    required int durationHours,
    required String vehicleType,
    required String parkingName,
    String parkingAddress = "Dirección no disponible",
    String? ownerName,
    String? ownerDocument,
    String? ownerPhone,
    required BuildContext context,
  }) async {
    final pdfData = await _pdfService.generateReservationTicket(
      parkingName: parkingName,
      parkingAddress: parkingAddress,
      plate: plate,
      spotLabel: spotLabel,
      reservationDate: reservationDate,
      durationHours: durationHours,
      vehicleType: vehicleType,
      ownerName: ownerName,
      ownerDocument: ownerDocument,
      ownerPhone: ownerPhone,
    );
    
    if (context.mounted) {
      PdfViewer.show(
        context,
        pdfData: pdfData,
        title: 'Reserva de Estacionamiento',
        filename: 'reserva_${plate.replaceAll(' ', '_')}',
      );
    }
  }
  
  // Imprimir recibo de suscripción
  Future<void> printSubscriptionReceipt({
    required String plate,
    required String subscriptionType,
    required DateTime startDate,
    required DateTime endDate,
    required double amount,
    required String parkingName,
    String parkingAddress = "Dirección no disponible",
    String? ownerName,
    String? ownerDocument,
    String? ownerPhone,
    required BuildContext context,
  }) async {
    final pdfData = await _pdfService.generateSubscriptionReceipt(
      parkingName: parkingName,
      parkingAddress: parkingAddress,
      plate: plate,
      subscriptionType: subscriptionType,
      startDate: startDate,
      endDate: endDate,
      amount: amount,
      ownerName: ownerName,
      ownerDocument: ownerDocument,
      ownerPhone: ownerPhone,
    );
    
    if (context.mounted) {
      PdfViewer.show(
        context,
        pdfData: pdfData,
        title: 'Recibo de Suscripción',
        filename: 'suscripcion_${plate.replaceAll(' ', '_')}',
      );
    }
  }
} 