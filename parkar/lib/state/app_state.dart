import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:system_theme/system_theme.dart';

import '../models/employee_model.dart';
import '../models/parking_model.dart';
import '../models/user_model.dart';
import '../models/cash_register_model.dart';
import '../services/print_service.dart';
import '../services/print_service.dart'; // For PrintSettings

class AppState extends ChangeNotifier {
  // Token and user state
  UserModel? _currentUser;
  EmployeeModel? _employee;
  ParkingModelDetailed? _currentParking;
  CashRegisterModel? _currentCashRegister;
  String? _authToken;
  String? _refreshToken;
  String? _selectedAreaId;

  // Theme state
  static const String _colorKey = 'app_theme_color';
  static const String _modeKey = 'app_theme_mode';
  static const String _textDirectionKey = 'app_theme_text_direction';
  static const String _localeLanguageKey = 'app_theme_locale_language';
  static const String _localeCountryKey = 'app_theme_locale_country';

  // Printing preferences
  static const String _processingModeKey = 'processing_mode';
  static const String _printMethodKey = 'print_method';
  static const String _printerTypeKey = 'printer_type';

  Color? _color;
  ThemeMode _mode = ThemeMode.light;
  TextDirection _textDirection = TextDirection.ltr;
  Locale? _locale;

  // Printing preferences
  PrintSettings _printSettings = PrintSettings(); // Default settings

  // User state getters
  UserModel? get currentUser => _currentUser;
  EmployeeModel? get employee => _employee;
  ParkingModelDetailed? get currentParking => _currentParking;
  CashRegisterModel? get currentCashRegister => _currentCashRegister;
  String? get authToken => _authToken;
  String? get refreshToken => _refreshToken;
  String? get selectedAreaId => _selectedAreaId;

  // Theme getters and setters
  Color get color => _color ?? systemAccentColor;
  set color(Color color) {
    _color = color;
    _saveColor();
    notifyListeners();
  }

  ThemeMode get mode => _mode;
  set mode(ThemeMode mode) {
    _mode = mode;
    _saveMode();
    notifyListeners();
  }

  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection direction) {
    _textDirection = direction;
    _saveTextDirection();
    notifyListeners();
  }

  Locale? get locale => _locale;
  set locale(Locale? locale) {
    _locale = locale;
    _saveLocale();
    notifyListeners();
  }

  // Printing preferences getters and setters
  PrintSettings get printSettings => _printSettings;
  set printSettings(PrintSettings settings) {
    _printSettings = settings;
    _savePrintSettings();
    notifyListeners();
  }

  // For compatibility
  ProcessingMode get processingMode => _printSettings.processingMode;
  set processingMode(ProcessingMode mode) {
    _printSettings.processingMode = mode;
    _savePrintSettings();
    notifyListeners();
  }

  PrintMethod get printMethod => _printSettings.printMethod;
  set printMethod(PrintMethod method) {
    _printSettings.printMethod = method;
    _savePrintSettings();
    notifyListeners();
  }

  PrinterType get printerType => _printSettings.printerType;
  set printerType(PrinterType type) {
    _printSettings.printerType = type;
    _savePrintSettings();
    notifyListeners();
  }

  // Constructor
  AppState() {
    loadState();
  }

  // Cargar el estado desde SharedPreferences
  Future<void> loadState() async {
    final prefs = await SharedPreferences.getInstance();

    // Cargar tokens y datos del usuario
    _authToken = prefs.getString('authToken');
    _refreshToken = prefs.getString('refreshToken');
    _selectedAreaId = prefs.getString('selectedAreaId');

    // Cargar configuración del tema
    final colorValue = prefs.getInt(_colorKey);
    if (colorValue != null) {
      _color = Color(colorValue);
    }

    final modeIndex = prefs.getInt(_modeKey);
    if (modeIndex != null) {
      _mode = ThemeMode.values[modeIndex];
    }

    final directionIndex = prefs.getInt(_textDirectionKey);
    if (directionIndex != null) {
      _textDirection = TextDirection.values[directionIndex];
    }

    final language = prefs.getString(_localeLanguageKey);
    final country = prefs.getString(_localeCountryKey);
    if (language != null) {
      _locale = Locale(language, country);
    }

    // Load printing preferences
    final processingModeIndex = prefs.getInt(_processingModeKey);
    final printMethodIndex = prefs.getInt(_printMethodKey);
    final printerTypeIndex = prefs.getInt(_printerTypeKey);

    _printSettings = PrintSettings(
      processingMode: processingModeIndex != null
          ? ProcessingMode.values[processingModeIndex]
          : ProcessingMode.viewPdf,
      printMethod: printMethodIndex != null
          ? PrintMethod.values[printMethodIndex]
          : PrintMethod.native,
      printerType: printerTypeIndex != null
          ? PrinterType.values[printerTypeIndex]
          : PrinterType.generic,
    );

    notifyListeners();
  }

  // Guardar el estado en SharedPreferences (tokens)
  Future<void> saveState() async {
    final prefs = await SharedPreferences.getInstance();

    // Guardar tokens
    await prefs.setString('authToken', _authToken ?? '');
    await prefs.setString('refreshToken', _refreshToken ?? '');
    if (_selectedAreaId != null) {
      await prefs.setString('selectedAreaId', _selectedAreaId!);
    } else {
      await prefs.remove('selectedAreaId');
    }
  }

  // Métodos para guardar configuración de tema
  Future<void> _saveColor() async {
    final prefs = await SharedPreferences.getInstance();
    if (_color != null) {
      await prefs.setInt(_colorKey, _color!.value);
    }
  }

  Future<void> _saveMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_modeKey, _mode.index);
  }

  Future<void> _saveTextDirection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_textDirectionKey, _textDirection.index);
  }

  Future<void> _saveLocale() async {
    final prefs = await SharedPreferences.getInstance();
    if (_locale != null) {
      await prefs.setString(_localeLanguageKey, _locale!.languageCode);
      if (_locale!.countryCode != null) {
        await prefs.setString(_localeCountryKey, _locale!.countryCode!);
      } else {
        await prefs.remove(_localeCountryKey);
      }
    } else {
      await prefs.remove(_localeLanguageKey);
      await prefs.remove(_localeCountryKey);
    }
  }

  Future<void> _savePrintSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_processingModeKey, _printSettings.processingMode.index);
    await prefs.setInt(_printMethodKey, _printSettings.printMethod.index);
    await prefs.setInt(_printerTypeKey, _printSettings.printerType.index);
  }

  // User state setters
  void setCurrentUser(UserModel? currentUser) {
    _currentUser = currentUser;
    notifyListeners();
  }

  void setEmployee(EmployeeModel? employee) {
    _employee = employee;
    notifyListeners();
  }

  void setCurrentParking(ParkingModelDetailed parking) {
    _currentParking = parking;
    _selectedAreaId = null;
    notifyListeners();
  }

  void setCurrentArea(String areaId) {
    _selectedAreaId = areaId;
    saveState();
    notifyListeners();
  }

  void setCurrentCashRegister(CashRegisterModel? cashRegister) {
    _currentCashRegister = cashRegister;
    notifyListeners();
  }

  void setAccessToken(String? authToken) {
    _authToken = authToken;
    saveState();
    notifyListeners();
  }

  void setRefreshToken(String? refreshToken) {
    _refreshToken = refreshToken;
    saveState();
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _employee = null;
    _currentParking = null;
    _currentCashRegister = null;
    _authToken = null;
    _refreshToken = null;
    _selectedAreaId = null;
    saveState();
    notifyListeners();
  }
}

// Función auxiliar para obtener el color del sistema
Color get systemAccentColor {
  if ((defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.android) &&
      !kIsWeb) {
    return SystemTheme.accentColor.accent;
  }
  return Colors.blue;
}
