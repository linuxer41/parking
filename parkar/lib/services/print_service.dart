import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import '../models/booking_model.dart';
import '../models/access_model.dart';
import '../models/cash_register_model.dart';
import '../models/movement_model.dart';
import '../models/subscription_model.dart';
import 'document_service.dart';
import '../state/app_state_container.dart';
import 'package:parkar/widgets/pdf_viewer.dart';
import '../models/printer_model.dart';

enum TicketType { entry, exit, reservation, subscription, test }

class PrintService {
  final DocumentService _documentService = DocumentService();

  Future<void> _sendZPLToPrinter(String zpl, String address) async {
    final data = latin1.encode(zpl);
    await FlutterBluetoothPrinter.printBytes(
      address: address,
      data: data,
      keepConnected: true,
    );
  }

  Future<void> _sendESCToPrinter(List<int> escPos, String address) async {
    await FlutterBluetoothPrinter.printBytes(
      address: address,
      data: Uint8List.fromList(escPos),
      keepConnected: true,
    );
  }

  // Método unificado para manejar la impresión de tickets
  Future<void> _handlePrint({
    required TicketType type,
    required dynamic model,
    required BuildContext context,
    required bool forceView,
    String? bluetoothAddress,
  }) async {
    final appState = AppStateContainer.of(context);
    final settings = appState.printSettings;

    String title;
    String filename;
    Future<Uint8List> pdfDataFuture;
    Future<bool> Function() bluetoothPrinter;

    switch (type) {
      case TicketType.entry:
        final access = model as AccessModel;
        title = 'Ticket de Entrada';
        filename = 'entrada_${access.vehicle.plate.replaceAll(' ', '_')}';
        pdfDataFuture = _documentService.generateEntryTicketPDF(access);
        bluetoothPrinter = () async {
          final address = bluetoothAddress ?? appState.printSettings.bluetoothDevice?.address;
          if (address == null) throw Exception("No se ha seleccionado una impresora Bluetooth");
          if (settings.printerType == PrinterType.zebra) {
            final zpl = _documentService.generateEntryTicketZPL(access);
            await _sendZPLToPrinter(zpl, address);
          } else {
            final esc = _documentService.generateEntryTicketESC(access);
            await _sendESCToPrinter(esc, address);
          }
          return true;
        };
        break;
      case TicketType.exit:
        final access = model as AccessModel;
        title = 'Ticket de Salida';
        filename = 'salida_${access.vehicle.plate.replaceAll(' ', '_')}';
        pdfDataFuture = _documentService.generateExitTicketPDF(access);
        bluetoothPrinter = () async {
          final address = bluetoothAddress ?? appState.printSettings.bluetoothDevice?.address;
          if (address == null) throw Exception("No se ha seleccionado una impresora Bluetooth");
          if (settings.printerType == PrinterType.zebra) {
            final zpl = _documentService.generateExitTicketZPL(access);
            await _sendZPLToPrinter(zpl, address);
          } else {
            final esc = _documentService.generateExitTicketESC(access);
            await _sendESCToPrinter(esc, address);
          }
          return true;
        };
        break;
      case TicketType.reservation:
        final booking = model as BookingModel;
        title = 'Reserva de Estacionamiento';
        filename = 'reserva_${booking.vehicle.plate.replaceAll(' ', '_')}';
        pdfDataFuture = _documentService.generateReservationTicketPDF(booking);
        bluetoothPrinter = () async {
          final address = bluetoothAddress ?? appState.printSettings.bluetoothDevice?.address;
          if (address == null) throw Exception("No se ha seleccionado una impresora Bluetooth");
          if (settings.printerType == PrinterType.zebra) {
            final zpl = _documentService.generateReservationTicketZPL(booking);
            await _sendZPLToPrinter(zpl, address);
          } else {
            final esc = _documentService.generateReservationTicketESC(booking);
            await _sendESCToPrinter(esc, address);
          }
          return true;
        };
        break;
      case TicketType.subscription:
        final subscription = model as SubscriptionModel;
        title = 'Recibo de Suscripción';
        filename = 'suscripcion_${subscription.vehicle.plate.replaceAll(' ', '_')}';
        pdfDataFuture = _documentService.generateSubscriptionReceiptPDF(subscription);
        bluetoothPrinter = () async {
          final address = bluetoothAddress ?? appState.printSettings.bluetoothDevice?.address;
          if (address == null) throw Exception("No se ha seleccionado una impresora Bluetooth");
          if (settings.printerType == PrinterType.zebra) {
            final zpl = _documentService.generateSubscriptionReceiptZPL(subscription);
            await _sendZPLToPrinter(zpl, address);
          } else {
            final esc = _documentService.generateSubscriptionReceiptESC(subscription);
            await _sendESCToPrinter(esc, address);
          }
          return true;
        };
        break;
      case TicketType.test:
        title = 'Prueba de Impresión';
        filename = 'prueba_impresion';
        pdfDataFuture = _documentService.generateTestPrintPDF();
        bluetoothPrinter = () async {
          final address = bluetoothAddress ?? appState.printSettings.bluetoothDevice?.address;
          if (address == null) throw Exception("No se ha seleccionado una impresora Bluetooth");
          if (settings.printerType == PrinterType.zebra) {
            final zpl = _documentService.generateTestZPL();
            await _sendZPLToPrinter(zpl, address);
          } else {
            final esc = _documentService.generateTestESC();
            await _sendESCToPrinter(esc, address);
          }
          return true;
        };
        break;
    }

    if (forceView || settings.processingMode == ProcessingMode.view) {
      // Mostrar PDF
      try {
        final pdfData = await pdfDataFuture.timeout(
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
          final pdfData = await pdfDataFuture.timeout(
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
    await _handlePrint(
      type: TicketType.entry,
      model: access,
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
    await _handlePrint(
      type: TicketType.exit,
      model: access,
      context: context,
      forceView: forceView,
    );
  }

  // Métodos para gestión de impresora Bluetooth
  Future<bool> connectToBluetoothPrinter(String address) async {
    return await _documentService.connectToDevice(address);
  }

  Future<void> disconnectBluetoothPrinter(String address) async {
    await _documentService.disconnect(address);
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
    await _handlePrint(
      type: TicketType.reservation,
      model: booking,
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
    await _handlePrint(
      type: TicketType.subscription,
      model: subscription,
      context: context,
      forceView: forceView,
    );
  }

  // Imprimir prueba
  Future<void> printTest({
    required BuildContext context,
    String? bluetoothAddress,
  }) async {
    await _handlePrint(
      type: TicketType.test,
      model: null,
      context: context,
      forceView: false,
      bluetoothAddress: bluetoothAddress,
    );
  }

  // Imprimir recibo de caja
  Future<void> printCashRegisterReceipt({
    required BuildContext context,
    required CashRegisterModel cashRegister,
    required List<MovementModel> movements,
  }) async {
    final appState = AppStateContainer.of(context);
    final parkingName = appState.currentParking?.name ?? 'ParKar';

    try {
      final pdfData = await _documentService.generateCashRegisterReport(
        cashRegister: cashRegister,
        movements: movements,
        parkingName: parkingName,
      );

      if (context.mounted) {
        PdfViewer.show(
          context,
          pdfData: pdfData,
          title: 'Recibo de Caja',
          filename: 'recibo_caja_${cashRegister.number}',
          onPrintPressed: appState.printSettings.printMethod == PrintMethod.bluetooth
              ? () async {
                  // For Bluetooth printing, we could implement sending the PDF or generating ZPL
                  // For now, show a message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Impresión Bluetooth disponible desde el visor PDF')),
                  );
                }
              : null,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar recibo: $e')),
        );
      }
    }
  }
}
