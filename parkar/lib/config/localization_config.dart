import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Configuración de localización para la aplicación
class LocalizationConfig {
  /// Locale por defecto (Español de España)
  static const Locale defaultLocale = Locale('es', 'ES');

  /// Lista de locales soportados
  static const List<Locale> supportedLocales = [
    Locale('es', 'ES'), // Español de España
    Locale('es', 'MX'), // Español de México
    Locale('es', 'AR'), // Español de Argentina
    Locale('es', 'CO'), // Español de Colombia
    Locale('es', 'PE'), // Español de Perú
    Locale('es', 'VE'), // Español de Venezuela
    Locale('es', 'CL'), // Español de Chile
    Locale('es', 'EC'), // Español de Ecuador
    Locale('es', 'GT'), // Español de Guatemala
    Locale('es', 'CU'), // Español de Cuba
    Locale('es', 'BO'), // Español de Bolivia
    Locale('es', 'DO'), // Español de República Dominicana
    Locale('es', 'HN'), // Español de Honduras
    Locale('es', 'PY'), // Español de Paraguay
    Locale('es', 'SV'), // Español de El Salvador
    Locale('es', 'NI'), // Español de Nicaragua
    Locale('es', 'CR'), // Español de Costa Rica
    Locale('es', 'PA'), // Español de Panamá
    Locale('es', 'UY'), // Español de Uruguay
    Locale('es', 'GQ'), // Español de Guinea Ecuatorial
    Locale('en', 'US'), // Inglés como fallback
  ];

  /// Delegados de localización
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  /// Mapa de nombres de países en español
  static const Map<String, String> countryNames = {
    'ES': 'España',
    'MX': 'México',
    'AR': 'Argentina',
    'CO': 'Colombia',
    'PE': 'Perú',
    'VE': 'Venezuela',
    'CL': 'Chile',
    'EC': 'Ecuador',
    'GT': 'Guatemala',
    'CU': 'Cuba',
    'BO': 'Bolivia',
    'DO': 'República Dominicana',
    'HN': 'Honduras',
    'PY': 'Paraguay',
    'SV': 'El Salvador',
    'NI': 'Nicaragua',
    'CR': 'Costa Rica',
    'PA': 'Panamá',
    'UY': 'Uruguay',
    'GQ': 'Guinea Ecuatorial',
    'US': 'Estados Unidos',
  };

  /// Obtener el nombre del país en español
  static String getCountryName(String countryCode) {
    return countryNames[countryCode.toUpperCase()] ?? countryCode;
  }

  /// Verificar si un locale está soportado
  static bool isSupported(Locale locale) {
    return supportedLocales.any(
      (supported) =>
          supported.languageCode == locale.languageCode &&
          (supported.countryCode == null ||
              supported.countryCode == locale.countryCode),
    );
  }

  /// Obtener el locale más cercano soportado
  static Locale getClosestSupportedLocale(Locale locale) {
    // Buscar coincidencia exacta
    final exactMatch = supportedLocales.firstWhere(
      (supported) =>
          supported.languageCode == locale.languageCode &&
          supported.countryCode == locale.countryCode,
      orElse: () => defaultLocale,
    );

    if (exactMatch != defaultLocale) {
      return exactMatch;
    }

    // Buscar coincidencia de idioma
    final languageMatch = supportedLocales.firstWhere(
      (supported) => supported.languageCode == locale.languageCode,
      orElse: () => defaultLocale,
    );

    return languageMatch;
  }

  /// Configurar la codificación UTF-8 para caracteres especiales
  static void configureUtf8() {
    // En Flutter, la codificación UTF-8 está habilitada por defecto
    // pero podemos asegurarnos de que esté configurada correctamente
    WidgetsFlutterBinding.ensureInitialized();
  }
}
