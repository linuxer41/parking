import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:flutter_bluetooth_printer_platform_interface/flutter_bluetooth_printer_platform_interface.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/printer_model.dart';
import '../../services/print_service.dart';
import '../../state/app_state_container.dart';

class BluetoothPrinterSettings extends StatelessWidget {
  const BluetoothPrinterSettings({super.key});

  Future<void> _selectDevice(BuildContext context) async {
    final appState = AppStateContainer.of(context);
    // final device = await FlutterBluetoothPrinter.selectDevice(context);
    // if (device == null) return;

    // final permissionsGranted = await _requestBluetoothPermissions();
    // if (!permissionsGranted) return;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StreamBuilder<DiscoveryState>(
          stream: FlutterBluetoothPrinter.discovery,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Error al buscar dispositivos'),
              );
            }

            final state = snapshot.data;

            if (state is PermissionRestrictedState) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bluetooth_disabled,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Bluetooth no disponible',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Asegúrate de que Bluetooth esté activado y concede los permisos necesarios.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await openAppSettings();
                      },
                      child: const Text('Abrir Configuración'),
                    ),
                  ],
                ),
              );
            }

            final devices = state is DiscoveryResult
                ? state.devices
                : <BluetoothDevice>[];

            if (devices.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Buscando dispositivos…'),
                  ],
                ),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Seleccionar Impresora',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: devices.map((device) {
                      return ListTile(
                        leading: const Icon(Icons.print, color: Colors.blue),
                        title: Text(device.name ?? 'Sin nombre'),
                        subtitle: Text(device.address),
                        onTap: () async {
                          
                          // Crear una nueva instancia de PrintSettings con el dispositivo
                          final newSettings = appState.printSettings.copyWith(
                            bluetoothDevice: BluetoothPrinterDevice(
                              address: device.address,
                              name: device.name ?? 'Sin nombre',
                              printerType: appState.printSettings.printerType,
                            ),
                          );
                          appState.setPrinterSettings(newSettings);
                          Navigator.of(context).pop();
                          
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _testPrint(BuildContext context) async {
    final appState = AppStateContainer.of(context);
    final printService = PrintService();

    // Ejecutar la impresión de prueba con el método seleccionado
    await printService.printTest(
      context: context,
      bluetoothAddress: appState.printSettings.bluetoothDevice?.address,
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return ListenableBuilder(
      listenable: AppStateContainer.of(context),
      builder: (context, _) {
        final appState = AppStateContainer.of(context);
        final colorScheme = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(title: const Text('Configuración de Impresora')),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modo de procesamiento
                  Text(
                    'Modo de Procesamiento',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 16),
        
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Elige cómo procesar los tickets:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 16),
                          SegmentedButton<ProcessingMode>(
                            segments: [
                              ButtonSegment<ProcessingMode>(
                                value: ProcessingMode.view,
                                label: Text(
                                  'Vista Previa',
                                  style: TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              ButtonSegment<ProcessingMode>(
                                value: ProcessingMode.silent,
                                label: Text(
                                  'Impresión silenciosa',
                                  style: TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            selected: {appState.printSettings.processingMode},
                            onSelectionChanged: (Set<ProcessingMode> newSelection) {
                              final mode = newSelection.first;
                              final newSettings = appState.printSettings.copyWith(processingMode: mode);
                              appState.setPrinterSettings(newSettings);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
        
                  const SizedBox(height: 24),
        
                  // Configuración del método de impresión
                  Text(
                    'Método de Impresión',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 16),
        
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Método de impresión por defecto:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: [
                              RadioListTile<PrintMethod>(
                                title: const Text('Impresión Nativa (PDF)'),
                                subtitle: const Text('Diálogo del sistema'),
                                value: PrintMethod.native,
                                groupValue: appState.printSettings.printMethod,
                                onChanged: (PrintMethod? value) {
                                  if (value != null) {
                                    final newSettings = appState.printSettings.copyWith(printMethod: value);
                                    appState.setPrinterSettings(newSettings);
                                  }
                                },
                              ),
                              RadioListTile<PrintMethod>(
                                title: const Text('Impresora Bluetooth'),
                                subtitle: const Text('Directo a térmica'),
                                value: PrintMethod.bluetooth,
                                groupValue: appState.printSettings.printMethod,
                                onChanged: (PrintMethod? value) {
                                  if (value != null) {
                                    final newSettings = appState.printSettings.copyWith(printMethod: value);
                                    appState.setPrinterSettings(newSettings);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
        
                  // Mostrar configuración Bluetooth solo si está seleccionado
                  if (appState.printSettings.printMethod ==
                      PrintMethod.bluetooth) ...[
                    const SizedBox(height: 24),
        
                    // Tipo de impresora térmica
                    Text(
                      'Tipo de Impresora Térmica',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 16),
        
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tipo de impresora térmica:',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 16),
                            Column(
                              children: [
                                RadioListTile<PrinterType>(
                                  title: const Text('Genérica (ESC/POS)'),
                                  subtitle: const Text('Térmicas estándar'),
                                  value: PrinterType.generic,
                                  groupValue: appState.printSettings.printerType,
                                  onChanged: (PrinterType? value) {
                                    if (value != null) {
                                      final newSettings = appState.printSettings.copyWith(printerType: value);
                                      appState.setPrinterSettings(newSettings);
                                    }
                                  },
                                ),
                                RadioListTile<PrinterType>(
                                  title: const Text('Zebra (ZPL)'),
                                  subtitle: const Text('Impresoras Zebra'),
                                  value: PrinterType.zebra,
                                  groupValue: appState.printSettings.printerType,
                                  onChanged: (PrinterType? value) {
                                    if (value != null) {
                                      final currentDevice = appState.printSettings.bluetoothDevice;
                                      final newDevice = currentDevice != null ? BluetoothPrinterDevice(
                                        address: currentDevice.address,
                                        name: currentDevice.name,
                                        printerType: value,
                                      ) : null;
                                      final newSettings = appState.printSettings.copyWith(
                                        bluetoothDevice: newDevice,
                                        printerType: value,
                                      );
                                      appState.setPrinterSettings(newSettings);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
        
                    const SizedBox(height: 24),
        
                    // Impresora seleccionada
                    Card(
                      color: appState.printSettings.bluetoothDevice != null
                          ? Colors.green.shade50
                          : Colors.grey.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  appState.printSettings.bluetoothDevice != null
                                      ? Icons.bluetooth
                                      : Icons.bluetooth_disabled,
                                  color:
                                      appState.printSettings.bluetoothDevice !=
                                          null
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child:
                                      appState.printSettings.bluetoothDevice !=
                                          null
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Impresora Seleccionada',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '${appState.printSettings.bluetoothDevice!.name ?? 'Sin nombre'} - ${appState.printSettings.bluetoothDevice!.address}',
                                              style: TextStyle(
                                                color: Colors.green.shade700,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const Text(
                                          'No hay impresora seleccionada',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: () => _selectDevice(context),
                                      child: Text(
                                        appState.printSettings.bluetoothDevice !=
                                                null
                                            ? 'Cambiar'
                                            : 'Seleccionar',
                                        style: TextStyle(
                                          color:
                                              appState
                                                      .printSettings
                                                      .bluetoothDevice !=
                                                  null
                                              ? Colors.blue
                                              : Colors.green,
                                        ),
                                      ),
                                    ),
                                    if (appState.printSettings.bluetoothDevice !=
                                        null)
                                      TextButton(
                                        onPressed: () {
                                          final newSettings = appState.printSettings.copyWith(
                                            bluetoothDevice: null);
                                          appState.setPrinterSettings(newSettings);
                                          print('Bluetooth Device: ${newSettings.bluetoothDevice?.name ?? 'Sin nombre'}');
                                        },
                                        child: const Text(
                                          'Quitar',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            if (appState.printSettings.bluetoothDevice !=
                                null) ...[
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _testPrint(context),
                                  icon: const Icon(Icons.print, size: 18),
                                  label: const Text('Probar Impresión'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    backgroundColor: Colors.blue.shade100,
                                    foregroundColor: Colors.blue.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
        
                  // Información adicional
                  Card(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💡 Consejos:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• La impresión Bluetooth requiere que la impresora esté correctamente emparejada',
                          ),
                          Text(
                            '• Si tiene problemas, reinicie la impresora y el dispositivo móvil',
                          ),
                          Text(
                            '• La impresión nativa (PDF) funciona sin configuración adicional',
                          ),
                          Text(
                            '• Puede cambiar entre métodos de impresión en cualquier momento',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}
