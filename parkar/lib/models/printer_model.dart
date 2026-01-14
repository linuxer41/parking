// Enum para métodos de impresión
import 'package:json_annotation/json_annotation.dart';
part 'printer_model.g.dart';

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
  view, // Mostrar PDF y permitir elegir impresión
  silent, // Imprimir directamente según configuración
}

@JsonSerializable()
class BluetoothPrinterDevice {
  String address;
  String name;
  PrinterType printerType;
  BluetoothPrinterDevice({
    required this.address,
    required this.name,
    required this.printerType,
  });
  factory BluetoothPrinterDevice.fromJson(Map<String, dynamic> json) =>
      _$BluetoothPrinterDeviceFromJson(json);
  Map<String, dynamic> toJson() => _$BluetoothPrinterDeviceToJson(this);
}

@JsonSerializable()
// Clase para configuración de impresión
class PrintSettings {
  ProcessingMode processingMode;
  PrintMethod printMethod;
  PrinterType printerType;
  BluetoothPrinterDevice? bluetoothDevice;

  PrintSettings({
    this.processingMode = ProcessingMode.view,
    this.printMethod = PrintMethod.native,
    this.bluetoothDevice,
    this.printerType = PrinterType.generic,
  });

  Map<String, dynamic> toJson() => _$PrintSettingsToJson(this);
  factory PrintSettings.fromJson(Map<String, dynamic> json) =>
      _$PrintSettingsFromJson(json);
  
  PrintSettings copyWith({
    ProcessingMode? processingMode,
    PrintMethod? printMethod,
    PrinterType? printerType,
    BluetoothPrinterDevice? bluetoothDevice,
  }) {
    return PrintSettings(
      processingMode: processingMode ?? this.processingMode,
      printMethod: printMethod ?? this.printMethod,
      printerType: printerType ?? this.printerType,
      bluetoothDevice: bluetoothDevice,
    );
  }
}
