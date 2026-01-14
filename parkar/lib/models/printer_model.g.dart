// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'printer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BluetoothPrinterDevice _$BluetoothPrinterDeviceFromJson(
  Map<String, dynamic> json,
) => BluetoothPrinterDevice(
  address: json['address'] as String,
  name: json['name'] as String,
  printerType: $enumDecode(_$PrinterTypeEnumMap, json['printerType']),
);

Map<String, dynamic> _$BluetoothPrinterDeviceToJson(
  BluetoothPrinterDevice instance,
) => <String, dynamic>{
  'address': instance.address,
  'name': instance.name,
  'printerType': _$PrinterTypeEnumMap[instance.printerType]!,
};

const _$PrinterTypeEnumMap = {
  PrinterType.generic: 'generic',
  PrinterType.zebra: 'zebra',
};

PrintSettings _$PrintSettingsFromJson(Map<String, dynamic> json) =>
    PrintSettings(
      processingMode:
          $enumDecodeNullable(
            _$ProcessingModeEnumMap,
            json['processingMode'],
          ) ??
          ProcessingMode.view,
      printMethod:
          $enumDecodeNullable(_$PrintMethodEnumMap, json['printMethod']) ??
          PrintMethod.native,
      bluetoothDevice: json['bluetoothDevice'] == null
          ? null
          : BluetoothPrinterDevice.fromJson(
              json['bluetoothDevice'] as Map<String, dynamic>,
            ),
      printerType:
          $enumDecodeNullable(_$PrinterTypeEnumMap, json['printerType']) ??
          PrinterType.generic,
    );

Map<String, dynamic> _$PrintSettingsToJson(PrintSettings instance) =>
    <String, dynamic>{
      'processingMode': _$ProcessingModeEnumMap[instance.processingMode]!,
      'printMethod': _$PrintMethodEnumMap[instance.printMethod]!,
      'printerType': _$PrinterTypeEnumMap[instance.printerType]!,
      'bluetoothDevice': instance.bluetoothDevice,
    };

const _$ProcessingModeEnumMap = {
  ProcessingMode.view: 'view',
  ProcessingMode.silent: 'silent',
};

const _$PrintMethodEnumMap = {
  PrintMethod.native: 'native',
  PrintMethod.bluetooth: 'bluetooth',
};
