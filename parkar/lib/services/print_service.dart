import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../models/access_model.dart';
import '../models/subscription_model.dart';
import 'document_service.dart';
import '../state/app_state_container.dart';
import 'package:parkar/widgets/pdf_viewer.dart';
import '../models/printer_model.dart';

class PrintService {
  final DocumentService _documentService = DocumentService();

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

    if (forceView || settings.processingMode == ProcessingMode.view) {
      // Mostrar PDF
      try {
        final pdfData = await pdfGenerator().timeout(
          const Duration(seconds: 10),
          onTimeout: () => Uint8List(0),
        );
        if (pdfData.isEmpty) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error: El ticket generado está vacío o timeout'),
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
                    final success = await bluetoothPrinter().timeout(
                      const Duration(seconds: 5),
                      onTimeout: () => false,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Ticket enviado a impresora Bluetooth'
                                : 'Error al imprimir vía Bluetooth',
                          ),
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
        final success = await bluetoothPrinter().timeout(
          const Duration(seconds: 5),
          onTimeout: () => false,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'Ticket enviado a impresora Bluetooth'
                    : 'Error al imprimir vía Bluetooth',
              ),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      } else {
        // Para nativo silencioso, mostrar PDF
        try {
          final pdfData = await pdfGenerator().timeout(
            const Duration(seconds: 10),
            onTimeout: () => Uint8List(0),
          );
          if (pdfData.isEmpty) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Error: El ticket generado está vacío o timeout',
                  ),
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
                      final success = await bluetoothPrinter().timeout(
                        const Duration(seconds: 5),
                        onTimeout: () => false,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Ticket enviado a impresora Bluetooth'
                                  : 'Error al imprimir vía Bluetooth',
                            ),
                            backgroundColor: success
                                ? Colors.green
                                : Colors.red,
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
    required AccessModel access,
    required BuildContext context,
    bool isSimpleMode = false,
    bool forceView = false,
  }) async {
    final appState = AppStateContainer.of(context);
    await _handlePrint(
      pdfGenerator: () => _pdfService.generateEntryTicket(access: access),
      bluetoothPrinter: () async {
        print("Imprimiendo ticket de entrada vía Bluetooth");
        if (appState.printSettings.bluetoothDevice == null) {
          throw Exception("No se ha seleccionado una impresora Bluetooth");
        }
        return await _bluetoothService.printEntryTicket(
          access,
          appState.printSettings.bluetoothDevice!.address,
          appState.printSettings.printerType,
        );
      },
      title: 'Ticket de Entrada',
      filename: 'entrada_${access.vehicle.plate.replaceAll(' ', '_')}',
      context: context,
      forceView: forceView,
    );
  }

  // Imprimir ticket de salida
  Future<void> printExitTicket({
    required AccessModel access,
    required BuildContext context,
    bool isSimpleMode = false,
    bool forceView = false,
  }) async {
    final appState = AppStateContainer.of(context);
    await _handlePrint(
      pdfGenerator: () => _pdfService.generateExitTicket(access: access),
      bluetoothPrinter: () async {
        print("Imprimiendo ticket de salida vía Bluetooth");
        if (appState.printSettings.bluetoothDevice == null) {
          throw Exception("No se ha seleccionado una impresora Bluetooth");
        }
        return await _bluetoothService.printExitTicket(
          access,
          appState.printSettings.bluetoothDevice!.address,
          appState.printSettings.printerType,
        );
      },
      title: 'Ticket de Salida',
      filename: 'salida_${access.vehicle.plate.replaceAll(' ', '_')}',
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

  Future<bool> get isBluetoothConnected async =>
      await _documentService.isConnected;

  // Imprimir ticket de reserva
  Future<void> printReservationTicket({
    required BookingModel booking,
    required BuildContext context,
    bool isSimpleMode = false,
    bool forceView = false,
  }) async {
    final appState = AppStateContainer.of(context);
    await _handlePrint(
      pdfGenerator: () =>
          _pdfService.generateReservationTicket(booking: booking),
      bluetoothPrinter: () => _bluetoothService.printReservationTicket(
        booking,
        appState.printSettings.bluetoothDevice!.address,
        appState.printSettings.printerType,
      ),
      title: 'Reserva de Estacionamiento',
      filename: 'reserva_${booking.vehicle.plate.replaceAll(' ', '_')}',
      context: context,
      forceView: forceView,
    );
  }

  // Imprimir recibo de suscripción
  Future<void> printSubscriptionReceipt({
    required SubscriptionModel subscription,
    required BuildContext context,
    bool forceView = false,
  }) async {
    final appState = AppStateContainer.of(context);
    await _handlePrint(
      pdfGenerator: () =>
          _pdfService.generateSubscriptionReceipt(subscription: subscription),
      bluetoothPrinter: () => _bluetoothService.printSubscriptionReceipt(
        subscription,
        appState.printSettings.bluetoothDevice!.address,
        appState.printSettings.printerType,
      ),
      title: 'Recibo de Suscripción',
      filename:
          'suscripcion_${subscription.vehicle.plate.replaceAll(' ', '_')}',
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

    if (settings.processingMode == ProcessingMode.view) {
      if (settings.printMethod == PrintMethod.bluetooth &&
          bluetoothAddress != null) {
        // Para Bluetooth en modo visualización, imprimir directamente térmica
        final success = await _bluetoothService.printTest(
          bluetoothAddress,
          settings.printerType,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'Prueba enviada a impresora Bluetooth'
                    : 'Error al imprimir prueba vía Bluetooth',
              ),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      } else {
        // Mostrar PDF de prueba para nativo
        final pdfData = await _documentService.generateTestPrintPDF();

        if (context.mounted) {
          PdfViewer.show(
            context,
            pdfData: pdfData,
            title: 'Prueba de Impresión',
            filename: 'prueba_impresion',
            onPrintPressed:
                settings.printMethod == PrintMethod.bluetooth &&
                    bluetoothAddress != null
                ? () async {
                    final success = await _bluetoothService.printTest(
                      bluetoothAddress!,
                      settings.printerType,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Prueba enviada a impresora Bluetooth'
                                : 'Error al imprimir prueba vía Bluetooth',
                          ),
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
          final success = await _bluetoothService.printTest(
            bluetoothAddress,
            settings.printerType,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? 'Prueba enviada a impresora Bluetooth'
                      : 'Error al imprimir prueba vía Bluetooth',
                ),
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
        final pdfData = await _documentService.generateTestPrintPDF();

        if (context.mounted) {
          PdfViewer.show(
            context,
            pdfData: pdfData,
            title: 'Prueba de Impresión',
            filename: 'prueba_impresion',
            onPrintPressed:
                settings.printMethod == PrintMethod.bluetooth &&
                    bluetoothAddress != null
                ? () async {
                    final success = await _bluetoothService.printTest(
                      bluetoothAddress!,
                      settings.printerType,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Prueba enviada a impresora Bluetooth'
                                : 'Error al imprimir prueba vía Bluetooth',
                          ),
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
