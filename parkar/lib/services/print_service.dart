import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../models/access_model.dart';
import '../models/subscription_model.dart';
import 'pdf_service.dart';
import 'bluetooth_print_service.dart';
import '../state/app_state_container.dart';
import 'package:parkar/widgets/pdf_viewer.dart';

// Enum para métodos de impresión
enum PrintMethod {
  native, // Impresión nativa del sistema (PDF)
  bluetooth, // Impresión directa vía Bluetooth
}

// Enum para tipo de impresora térmica
enum PrinterType {
  generic, // ESC/POS
  zebra, // ZPL
}

// Enum para modo de procesamiento
enum ProcessingMode {
  viewPdf, // Mostrar PDF y permitir elegir impresión
  silentPrint, // Imprimir directamente según configuración
}

// Clase para configuración de impresión
class PrintSettings {
  ProcessingMode processingMode;
  PrintMethod printMethod;
  PrinterType printerType;

  PrintSettings({
    this.processingMode = ProcessingMode.viewPdf,
    this.printMethod = PrintMethod.native,
    this.printerType = PrinterType.generic,
  });

  // Para compatibilidad, getters
  ProcessingMode get mode => processingMode;
  set mode(ProcessingMode value) => processingMode = value;

  PrintMethod get method => printMethod;
  set method(PrintMethod value) => printMethod = value;

  PrinterType get type => printerType;
  set type(PrinterType value) => printerType = value;
}

class PrintService {
  final PdfService _pdfService = PdfService();
  final BluetoothPrintService _bluetoothService = BluetoothPrintService();

  // Método unificado para manejar la impresión de tickets de entrada
  Future<void> _handlePrint({
    required Future<Uint8List> Function() pdfGenerator,
    required Future<bool> Function() bluetoothPrinter,
    required String title,
    required String filename,
    required BuildContext context,
    required bool forceView,
  }) async {
    final appState = AppStateContainer.of(context);
    final settings = appState.printSettings;

    if (forceView || settings.processingMode == ProcessingMode.viewPdf) {
      // Mostrar PDF
      try {
        final pdfData = await pdfGenerator();
        if (pdfData.isEmpty) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error: El ticket generado está vacío'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        if (context.mounted) {
          PdfViewer.show(
            context,
            pdfData: pdfData,
            title: title,
            filename: filename,
            onPrintPressed: settings.printMethod == PrintMethod.bluetooth
                ? () async {
                    final success = await bluetoothPrinter();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? 'Ticket enviado a impresora Bluetooth'
                              : 'Error al imprimir vía Bluetooth'),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  }
                : null,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al generar el ticket: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // Imprimir directamente según configuración
      if (settings.printMethod == PrintMethod.bluetooth) {
        final success = await bluetoothPrinter();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success
                  ? 'Ticket enviado a impresora Bluetooth'
                  : 'Error al imprimir vía Bluetooth'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      } else {
        // Para nativo silencioso, mostrar PDF
        try {
          final pdfData = await pdfGenerator();
          if (context.mounted) {
            PdfViewer.show(
              context,
              pdfData: pdfData,
              title: title,
              filename: filename,
              onPrintPressed: settings.printMethod == PrintMethod.bluetooth
                  ? () async {
                      final success = await bluetoothPrinter();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? 'Ticket enviado a impresora Bluetooth'
                                : 'Error al imprimir vía Bluetooth'),
                            backgroundColor: success ? Colors.green : Colors.red,
                          ),
                        );
                      }
                    }
                  : null,
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al generar el ticket: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  // Imprimir ticket de entrada
  Future<void> printEntryTicket({
    required AccessModel booking,
    required BuildContext context,
    bool isSimpleMode = false,
    bool forceView = false,
  }) async {
    final appState = AppStateContainer.of(context);
    await _handlePrint(
      pdfGenerator: () => _pdfService.generateEntryTicket(booking: booking),
      bluetoothPrinter: () => _bluetoothService.printEntryTicket(booking, appState.printSettings.printerType),
      title: 'Ticket de Entrada',
      filename: 'entrada_${booking.vehicle.plate.replaceAll(' ', '_')}',
      context: context,
      forceView: forceView,
    );
  }

  // Imprimir ticket de salida
  Future<void> printExitTicket({
    required AccessModel booking,
    required BuildContext context,
    bool isSimpleMode = false,
    bool forceView = false,
  }) async {
    await _handlePrint(
      pdfGenerator: () => _pdfService.generateExitTicket(booking: booking),
      bluetoothPrinter: () => _bluetoothService.printExitTicket(booking),
      title: 'Ticket de Salida',
      filename: 'salida_${booking.vehicle.plate.replaceAll(' ', '_')}',
      context: context,
      forceView: forceView,
    );
  }

 // Métodos para gestión de impresora Bluetooth
 Future<bool> connectToBluetoothPrinter(String address) async {
   return await _bluetoothService.connectToDevice(address);
 }

 Future<void> disconnectBluetoothPrinter(String address) async {
   await _bluetoothService.disconnect(address);
 }

 Future<bool> get isBluetoothConnected async => await _bluetoothService.isConnected;

  // Imprimir ticket de reserva
  Future<void> printReservationTicket({
    required BookingModel booking,
    required BuildContext context,
    bool isSimpleMode = false,
    bool forceView = false,
  }) async {
    await _handlePrint(
      pdfGenerator: () => _pdfService.generateReservationTicket(booking: booking),
      bluetoothPrinter: () => _bluetoothService.printReservationTicket(booking),
      title: 'Reserva de Estacionamiento',
      filename: 'reserva_${booking.vehicle.plate.replaceAll(' ', '_')}',
      context: context,
      forceView: forceView,
    );
  }

  // Imprimir recibo de suscripción
  Future<void> printSubscriptionReceipt({
    required SubscriptionModel booking,
    required BuildContext context,
    bool forceView = false,
  }) async {
    await _handlePrint(
      pdfGenerator: () => _pdfService.generateSubscriptionReceipt(booking: booking),
      bluetoothPrinter: () => _bluetoothService.printSubscriptionReceipt(booking),
      title: 'Recibo de Suscripción',
      filename: 'suscripcion_${booking.vehicle.plate.replaceAll(' ', '_')}',
      context: context,
      forceView: forceView,
    );
  }

  // Imprimir prueba
  Future<void> printTest({
    required BuildContext context,
    String? bluetoothAddress,
  }) async {
    final appState = AppStateContainer.of(context);
    final settings = appState.printSettings;

    if (settings.processingMode == ProcessingMode.viewPdf) {
      if (settings.printMethod == PrintMethod.bluetooth && bluetoothAddress != null) {
        // Para Bluetooth en modo visualización, imprimir directamente térmica
        final success = await _bluetoothService.printTest(bluetoothAddress, settings.printerType);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success
                  ? 'Prueba enviada a impresora Bluetooth'
                  : 'Error al imprimir prueba vía Bluetooth'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      } else {
        // Mostrar PDF de prueba para nativo
        final pdfData = await _pdfService.generateTestPrint();

        if (context.mounted) {
          PdfViewer.show(
            context,
            pdfData: pdfData,
            title: 'Prueba de Impresión',
            filename: 'prueba_impresion',
            onPrintPressed: settings.printMethod == PrintMethod.bluetooth && bluetoothAddress != null
                ? () async {
                    final success = await _bluetoothService.printTest(bluetoothAddress!, settings.printerType);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? 'Prueba enviada a impresora Bluetooth'
                              : 'Error al imprimir prueba vía Bluetooth'),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  }
                : null,
          );
        }
      }
    } else {
      // Imprimir directamente
      if (settings.printMethod == PrintMethod.bluetooth) {
        if (bluetoothAddress != null) {
          final success = await _bluetoothService.printTest(bluetoothAddress, settings.printerType);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success
                    ? 'Prueba enviada a impresora Bluetooth'
                    : 'Error al imprimir prueba vía Bluetooth'),
                backgroundColor: success ? Colors.green : Colors.red,
              ),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No hay impresora Bluetooth seleccionada'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // Para nativo silencioso, mostrar PDF
        final pdfData = await _pdfService.generateTestPrint();

        if (context.mounted) {
          PdfViewer.show(
            context,
            pdfData: pdfData,
            title: 'Prueba de Impresión',
            filename: 'prueba_impresion',
            onPrintPressed: settings.printMethod == PrintMethod.bluetooth && bluetoothAddress != null
                ? () async {
                    final success = await _bluetoothService.printTest(bluetoothAddress!, settings.printerType);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? 'Prueba enviada a impresora Bluetooth'
                              : 'Error al imprimir prueba vía Bluetooth'),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  }
                : null,
          );
        }
      }
    }
  }
}
