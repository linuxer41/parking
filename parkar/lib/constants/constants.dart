/// Currency constants and symbols for all countries
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import '../state/app_state_container.dart';

class UserRole {
  final String value;
  final String label;
  final IconData icon;

  UserRole({required this.value, required this.label, required this.icon});
}

class VehicleCategory {
  final int value;
  final String label;
  final IconData icon;
  final Color color;

  VehicleCategory({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
}

final List<UserRole> userRoles = [
  UserRole(value: 'owner', label: 'Propietario', icon: Icons.person),
  UserRole(
    value: 'admin',
    label: 'Administrador',
    icon: Icons.admin_panel_settings,
  ),
  UserRole(value: 'operator', label: 'Operador', icon: Icons.engineering),
  UserRole(value: 'cashier', label: 'Cajero', icon: Icons.point_of_sale),
];

final List<VehicleCategory> vehicleCategories = [
  VehicleCategory(
    value: 1,
    label: 'Bicicleta',
    icon: Icons.bike_scooter,
    color: Colors.green,
  ),
  VehicleCategory(
    value: 2,
    label: 'Moto',
    icon: Icons.motorcycle,
    color: Colors.red,
  ),
  VehicleCategory(
    value: 3,
    label: 'Vehículo',
    icon: Icons.directions_car,
    color: Colors.blue,
  ),
  VehicleCategory(
    value: 4,
    label: 'Camion',
    icon: Icons.directions_bus,
    color: Colors.orange,
  ),
];
String getVehicleCategoryLabel(String? type) {
  final value = int.tryParse(type ?? '');
  if (value == null) return type ?? 'No especificado';
  final category = vehicleCategories.firstWhere(
    (c) => c.value == value,
    orElse: () => VehicleCategory(value: value, label: 'Desconocido', icon: Icons.help, color: Colors.grey),
  );
  return category.label;
}

class CurrencyConstants {
  /// Map of currency codes to their symbols
  static const Map<String, String> currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'CNY': '¥',
    'KRW': '₩',
    'INR': '₹',
    'RUB': '₽',
    'BRL': 'R\$',
    'MXN': '\$',
    'CAD': 'C\$',
    'AUD': 'A\$',
    'CHF': 'CHF',
    'SEK': 'kr',
    'NOK': 'kr',
    'DKK': 'kr',
    'PLN': 'zł',
    'CZK': 'Kč',
    'HUF': 'Ft',
    'TRY': '₺',
    'ILS': '₪',
    'ZAR': 'R',
    'EGP': '£',
    'SAR': '﷼',
    'AED': 'د.إ',
    'THB': '฿',
    'VND': '₫',
    'IDR': 'Rp',
    'MYR': 'RM',
    'PHP': '₱',
    'SGD': 'S\$',
    'HKD': 'HK\$',
    'TWD': 'NT\$',
    'ARS': '\$',
    'CLP': '\$',
    'COP': '\$',
    'PEN': 'S/',
    'UYU': '\$',
    'PYG': '₲',
    'BOB': 'Bs.',
    'VES': 'Bs.',
    'GTQ': 'Q',
    'HNL': 'L',
    'SVC': '\$',
    'NIO': 'C\$',
    'CRC': '₡',
    'PAB': 'B/.',
    'CUC': '\$',
    'DOP': 'RD\$',
    'HTG': 'G',
    'JMD': 'J\$',
    'TTD': 'TT\$',
    'BBD': 'Bds\$',
    'BSD': 'B\$',
    'BZD': 'BZ\$',
    'KYD': 'CI\$',
    'XCD': 'EC\$',
    'FJD': 'FJ\$',
    'GYD': 'G\$',
    'SBD': 'SI\$',
    'SRD': 'Sr\$',
    'TVD': '\$',
    'VUV': 'VT',
    'WST': 'WS\$',
    'TOP': 'T\$',
    'PGK': 'K',
    'KID': '\$',
    'BDT': '৳',
    'LKR': 'Rs',
    'NPR': '₨',
    'PKR': '₨',
    'AFN': '؋',
    'TJS': 'ЅМ',
    'TMT': 'T',
    'UZS': 'so\'m',
    'KZT': '₸',
    'KGS': 'сом',
    'AZN': '₼',
    'GEL': '₾',
    'AMD': '֏',
    'BYN': 'Br',
    'MDL': 'L',
    'UAH': '₴',
    'BAM': 'KM',
    'HRK': 'kn',
    'RSD': 'дин',
    'MKD': 'ден',
    'ALL': 'L',
    'ISK': 'kr',
    'RON': 'lei',
    'BGN': 'лв',
    'EEK': 'kr',
    'LVL': 'Ls',
    'LTL': 'Lt',
    'MZN': 'MT',
    'AOA': 'Kz',
    'CVE': '\$',
    'GMD': 'D',
    'GHS': '₵',
    'KES': 'KSh',
    'MAD': 'د.م.',
    'TND': 'د.ت',
    'DZD': 'د.ج',
    'LYD': 'ل.د',
    'SDG': '£',
    'SOS': 'S',
    'TZS': 'TSh',
    'UGX': 'USh',
    'CDF': 'FC',
    'BIF': 'FBu',
    'DJF': 'Fdj',
    'ERN': 'Nfk',
    'ETB': 'Br',
    'RWF': 'RF',
    'SCR': '₨',
    'MUR': '₨',
    'LSL': 'L',
    'NAD': 'N\$',
    'SZL': 'E',
    'ZMW': 'ZK',
    'ZWD': 'Z\$',
    'BWP': 'P',
    'MGA': 'Ar',
    'KMF': 'CF',
    'STN': 'Db',
    'SLL': 'Le',
    'LRD': '\$',
    'GNF': 'FG',
    'MWK': 'MK',
    'BND': 'B\$',
    'KHR': '៛',
    'JOD': 'د.أ',
    'IQD': 'ع.د',
    'LBP': 'ل.ل',
    'YER': '﷼',
    'OMR': 'ر.ع.',
    'QAR': 'ر.ق',
    'BHD': '.د.ب',
    'KWD': 'د.ك',
    'ANG': 'ƒ',
    'AWG': 'ƒ',
    'BMD': '\$',
    'GGP': '£',
    'IMP': '£',
    'JEP': '£',
    'MRO': 'UM',
    'SSP': '£',
  };

  /// Get currency symbol for a given currency code
  static String getCurrencySymbol(String currencyCode) {
    return currencySymbols[currencyCode] ?? currencyCode;
  }

  /// Format amount with currency symbol
  static String formatAmount(
    double amount,
    String currencyCode, {
    int decimalPlaces = 2,
  }) {
    final symbol = getCurrencySymbol(currencyCode);
    return '$symbol${amount.toStringAsFixed(decimalPlaces)}';
  }

  /// Format amount using current parking parameters from context
  static String formatAmountWithParkingParams(
    BuildContext context,
    double amount,
  ) {
    final appState = AppStateContainer.of(context);
    final parking = appState.currentParking;
    if (parking == null) {
      // Fallback to USD with 2 decimals
      return formatAmount(amount, 'USD');
    }
    return formatAmount(
      amount,
      parking.params.currency,
      decimalPlaces: parking.params.decimalPlaces,
    );
  }

  /// Format amount for PDF generation (no context available)
  static String formatAmountForPdf(
    double amount,
    String currencyCode,
    int decimalPlaces,
  ) {
    return formatAmount(amount, currencyCode, decimalPlaces: decimalPlaces);
  }
}

/// Time zone constants
class TimeZoneConstants {
  static const List<String> commonTimeZones = [
    'America/New_York',
    'America/Chicago',
    'America/Denver',
    'America/Los_Angeles',
    'America/Mexico_City',
    'America/Sao_Paulo',
    'America/La_Paz',
    'America/Bogota',
    'America/Lima',
    'America/Caracas',
    'America/Guayaquil',
    'America/Asuncion',
    'America/Montevideo',
    'America/Guatemala',
    'America/Tegucigalpa',
    'America/El_Salvador',
    'America/Managua',
    'America/Costa_Rica',
    'America/Panama',
    'America/Havana',
    'America/Santo_Domingo',
    'America/Puerto_Rico',
    'America/Toronto',
    'Europe/London',
    'Europe/Paris',
    'Europe/Berlin',
    'Europe/Madrid',
    'Europe/Rome',
    'Europe/Moscow',
    'Asia/Tokyo',
    'Asia/Shanghai',
    'Asia/Seoul',
    'Asia/Singapore',
    'Asia/Hong_Kong',
    'Asia/Bangkok',
    'Australia/Sydney',
    'Australia/Melbourne',
    'Pacific/Auckland',
  ];
}

/// Country constants
class CountryConstants {
  static const Map<String, Map<String, String>> countries = {
    'US': {'code': 'US', 'name': 'Estados Unidos', 'currency': 'USD'},
    'MX': {'code': 'MX', 'name': 'México', 'currency': 'MXN'},
    'ES': {'code': 'ES', 'name': 'España', 'currency': 'EUR'},
    'AR': {'code': 'AR', 'name': 'Argentina', 'currency': 'ARS'},
    'BR': {'code': 'BR', 'name': 'Brasil', 'currency': 'BRL'},
    'CO': {'code': 'CO', 'name': 'Colombia', 'currency': 'COP'},
    'PE': {'code': 'PE', 'name': 'Perú', 'currency': 'PEN'},
    'CL': {'code': 'CL', 'name': 'Chile', 'currency': 'CLP'},
    'VE': {'code': 'VE', 'name': 'Venezuela', 'currency': 'VES'},
    'EC': {'code': 'EC', 'name': 'Ecuador', 'currency': 'USD'},
    'BO': {'code': 'BO', 'name': 'Bolivia', 'currency': 'BOB'},
    'PY': {'code': 'PY', 'name': 'Paraguay', 'currency': 'PYG'},
    'UY': {'code': 'UY', 'name': 'Uruguay', 'currency': 'UYU'},
    'GT': {'code': 'GT', 'name': 'Guatemala', 'currency': 'GTQ'},
    'HN': {'code': 'HN', 'name': 'Honduras', 'currency': 'HNL'},
    'SV': {'code': 'SV', 'name': 'El Salvador', 'currency': 'SVC'},
    'NI': {'code': 'NI', 'name': 'Nicaragua', 'currency': 'NIO'},
    'CR': {'code': 'CR', 'name': 'Costa Rica', 'currency': 'CRC'},
    'PA': {'code': 'PA', 'name': 'Panamá', 'currency': 'PAB'},
    'CU': {'code': 'CU', 'name': 'Cuba', 'currency': 'CUP'},
    'DO': {'code': 'DO', 'name': 'República Dominicana', 'currency': 'DOP'},
    'PR': {'code': 'PR', 'name': 'Puerto Rico', 'currency': 'USD'},
    'CA': {'code': 'CA', 'name': 'Canadá', 'currency': 'CAD'},
    'FR': {'code': 'FR', 'name': 'Francia', 'currency': 'EUR'},
    'DE': {'code': 'DE', 'name': 'Alemania', 'currency': 'EUR'},
    'IT': {'code': 'IT', 'name': 'Italia', 'currency': 'EUR'},
    'GB': {'code': 'GB', 'name': 'Reino Unido', 'currency': 'GBP'},
    'JP': {'code': 'JP', 'name': 'Japón', 'currency': 'JPY'},
    'CN': {'code': 'CN', 'name': 'China', 'currency': 'CNY'},
    'KR': {'code': 'KR', 'name': 'Corea del Sur', 'currency': 'KRW'},
    'AU': {'code': 'AU', 'name': 'Australia', 'currency': 'AUD'},
  };

  /// Get currency code for a country
  static String getCurrencyForCountry(String countryCode) {
    return countries[countryCode]?['currency'] ?? 'USD';
  }
}

/// DateTime constants and formatting functions
class DateTimeConstants {
  /// Format DateTime using current parking parameters from context
  static String formatDateTimeWithParkingParams(
    BuildContext context,
    DateTime dateTime, {
    String? format,
  }) {
    final appState = AppStateContainer.of(context);
    final parking = appState.currentParking;
    if (parking == null) {
      // Fallback to local timezone formatting
      final formatter = DateFormat(format ?? 'dd/MM/yyyy HH:mm', 'es');
      return formatter.format(dateTime.toLocal());
    }

    try {
      // Convert to parking's timezone
      final parkingLocation = tz.getLocation(parking.params.timeZone);
      final tzDateTime = tz.TZDateTime.from(dateTime, parkingLocation);

      // Format in parking's timezone
      final formatter = DateFormat(format ?? 'dd/MM/yyyy HH:mm', 'es');
      return formatter.format(tzDateTime);
    } catch (e) {
      // Fallback if timezone parsing fails
      final formatter = DateFormat(format ?? 'dd/MM/yyyy HH:mm', 'es');
      return formatter.format(dateTime.toLocal());
    }
  }

  /// Format DateTime for PDF generation (no context available)
  static String formatDateTimeForPdf(
    DateTime dateTime,
    String timeZone, {
    String? format,
  }) {
    try {
      // Convert to specified timezone
      final location = tz.getLocation(timeZone);
      final tzDateTime = tz.TZDateTime.from(dateTime, location);

      // Format in the timezone
      final formatter = DateFormat(format ?? 'dd/MM/yyyy HH:mm', 'es');
      return formatter.format(tzDateTime);
    } catch (e) {
      // Fallback
      final formatter = DateFormat(format ?? 'dd/MM/yyyy HH:mm', 'es');
      return formatter.format(dateTime.toLocal());
    }
  }

  /// Format time only (HH:mm)
  static String formatTimeWithParkingParams(
    BuildContext context,
    DateTime dateTime,
  ) {
    return formatDateTimeWithParkingParams(context, dateTime, format: 'HH:mm');
  }

  /// Format date only (dd/MM/yyyy)
  static String formatDateWithParkingParams(
    BuildContext context,
    DateTime dateTime,
  ) {
    return formatDateTimeWithParkingParams(
      context,
      dateTime,
      format: 'dd/MM/yyyy',
    );
  }
}
