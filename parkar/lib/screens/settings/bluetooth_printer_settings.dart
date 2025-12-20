import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:flutter_bluetooth_printer_platform_interface/flutter_bluetooth_printer_platform_interface.dart';
import '../../services/print_service.dart';
import '../../widgets/print_method_dialog.dart';
import '../../state/app_state.dart';
import '../../state/app_state_container.dart';

class BluetoothPrinterSettings extends StatefulWidget {
  const BluetoothPrinterSettings({super.key});

  @override
  State<BluetoothPrinterSettings> createState() => _BluetoothPrinterSettingsState();
}

class _BluetoothPrinterSettingsState extends State<BluetoothPrinterSettings> {
  String? _selectedPrinterAddress;
  String? _selectedPrinterName;
  bool _isConnecting = false;
  String _connectionStatus = 'Desconectado';
  late AppState _appState;

  @override
  void initState() {
    super.initState();
    _checkConnectionStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appState = AppStateContainer.of(context);
  }

  Future<void> _checkConnectionStatus() async {
    final printService = PrintService();
    final isConnected = await printService.isBluetoothConnected;
    setState(() {
      _connectionStatus = isConnected ? 'Conectado' : 'Desconectado';
    });
  }

  Future<void> _connectToPrinter(String address) async {
    setState(() {
      _isConnecting = true;
      _connectionStatus = 'Conectando...';
    });

    try {
      final printService = PrintService();
      final success = await printService.connectToBluetoothPrinter(address);

      setState(() {
        _isConnecting = false;
        _connectionStatus = success ? 'Conectado' : 'Error de conexión';
        if (success) {
          _selectedPrinterAddress = address;
          // Find the device name from the current devices
          // For now, set a placeholder, will be updated in the list
          _selectedPrinterName = 'Impresora';
        }
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impresora conectada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al conectar la impresora'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isConnecting = false;
        _connectionStatus = 'Error: $e';
      });
    }
  }

  Future<void> _disconnectPrinter() async {
    setState(() {
      _connectionStatus = 'Desconectando...';
    });

    try {
      final printService = PrintService();
      if (_selectedPrinterAddress != null) {
        await printService.disconnectBluetoothPrinter(_selectedPrinterAddress!);
      }

      setState(() {
        _selectedPrinterAddress = null;
        _selectedPrinterName = null;
        _connectionStatus = 'Desconectado';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impresora desconectada'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      setState(() {
        _connectionStatus = 'Error al desconectar';
      });
    }
  }

  Future<void> _selectDevice() async {
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
            final devices = state is DiscoveryResult ? state.devices : <BluetoothDevice>[];

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
                          
                          final result = await FlutterBluetoothPrinter.connect(device.address);
                          print("Conection result: $result");
                          if (result) {
                            setState(() {
                              _selectedPrinterAddress = device.address;
                              _selectedPrinterName = device.name ?? 'Sin nombre';
                              _connectionStatus = 'Seleccionado';
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error al conectar la impresora'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
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

  Future<void> _testPrint() async {
    final printService = PrintService();

    // Ejecutar la impresión de prueba con el método seleccionado
    await printService.printTest(
      context: context,
      bluetoothAddress: _appState.printMethod == PrintMethod.bluetooth ? _selectedPrinterAddress : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Impresora'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
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
                    SwitchListTile(
                      title: const Text('Modo de Procesamiento'),
                      subtitle: const Text('Visualizar PDF o imprimir directamente'),
                      value: _appState.processingMode == ProcessingMode.viewPdf,
                      onChanged: (bool value) {
                        setState(() {
                          _appState.processingMode = value ? ProcessingMode.viewPdf : ProcessingMode.silentPrint;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Modo: ${value ? 'Visualizar PDF' : 'Imprimir directamente'}'),
                            backgroundColor: Colors.green,
                          ),
                        );
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
                          groupValue: _appState.printMethod,
                          onChanged: (PrintMethod? value) {
                            if (value != null) {
                              setState(() {
                                _appState.printMethod = value;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Método guardado'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                        ),
                        RadioListTile<PrintMethod>(
                          title: const Text('Impresora Bluetooth'),
                          subtitle: const Text('Directo a térmica'),
                          value: PrintMethod.bluetooth,
                          groupValue: _appState.printMethod,
                          onChanged: (PrintMethod? value) {
                            if (value != null) {
                              setState(() {
                                _appState.printMethod = value;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Método guardado'),
                                  backgroundColor: Colors.green,
                                ),
                              );
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
            if (_appState.printMethod == PrintMethod.bluetooth) ...[
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
                            groupValue: _appState.printerType,
                            onChanged: (PrinterType? value) {
                              if (value != null) {
                                setState(() {
                                  _appState.printerType = value;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Tipo guardado'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                          ),
                          RadioListTile<PrinterType>(
                            title: const Text('Zebra (ZPL)'),
                            subtitle: const Text('Impresoras Zebra'),
                            value: PrinterType.zebra,
                            groupValue: _appState.printerType,
                            onChanged: (PrinterType? value) {
                              if (value != null) {
                                setState(() {
                                  _appState.printerType = value;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Tipo guardado'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
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
                color: _selectedPrinterAddress != null ? Colors.green.shade50 : Colors.grey.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            _selectedPrinterAddress != null ? Icons.bluetooth : Icons.bluetooth_disabled,
                            color: _selectedPrinterAddress != null ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _selectedPrinterAddress != null
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Impresora Seleccionada',
                                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${_selectedPrinterName ?? 'Sin nombre'} - ${_selectedPrinterAddress}',
                                        style: TextStyle(color: Colors.green.shade700),
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
                                onPressed: _selectDevice,
                                child: Text(
                                  _selectedPrinterAddress != null ? 'Cambiar' : 'Seleccionar',
                                  style: TextStyle(
                                    color: _selectedPrinterAddress != null ? Colors.blue : Colors.green,
                                  ),
                                ),
                              ),
                              if (_selectedPrinterAddress != null)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedPrinterAddress = null;
                                      _selectedPrinterName = null;
                                      _connectionStatus = 'Desconectado';
                                    });
                                  },
                                  child: const Text('Quitar', style: TextStyle(color: Colors.red)),
                                ),
                            ],
                          ),
                        ],
                      ),
                      if (_selectedPrinterAddress != null) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _testPrint,
                            icon: const Icon(Icons.print, size: 18),
                            label: const Text('Probar Impresión'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
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
                    Text('• La impresión Bluetooth requiere que la impresora esté correctamente emparejada'),
                    Text('• Si tiene problemas, reinicie la impresora y el dispositivo móvil'),
                    Text('• La impresión nativa (PDF) funciona sin configuración adicional'),
                    Text('• Puede cambiar entre métodos de impresión en cualquier momento'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}