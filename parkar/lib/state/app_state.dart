import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_theme/system_theme.dart';

import '../models/cash_register_model.dart';
import '../models/employee_model.dart';
import '../models/parking_model.dart';
import '../models/printer_model.dart';
import '../models/user_model.dart';

class AppState extends ChangeNotifier {
  // Token and user state
  UserModel? _currentUser;
  EmployeeModel? _employee;
  ParkingModel? _currentParking;
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
  static const String _selectedAreaIdKey = 'selected_area_id';
  static const String _printSettingsKey = 'print_settings';

  Color? _color;
  ThemeMode _mode = ThemeMode.light;
  TextDirection _textDirection = TextDirection.ltr;
  Locale? _locale;

  // Printing preferences
  PrintSettings _printSettings = PrintSettings(); // Default settings

  // User state getters
  UserModel? get currentUser => _currentUser;
  EmployeeModel? get employee => _employee;
  ParkingModel? get currentParking => _currentParking;
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

  // Current user role getter
  String get currentRole {
    print('employee: ${employee ?? "unknown"}');
    if (currentParking?.isOwner == true) return 'owner';
    if (employee != null) return employee!.role;

    return 'owner'; // default
  }

  // Constructor
  AppState() {
    // loadState() will be called in main()
  }

  bool get isTokenExpired {
    if (_authToken == null) return true;

    final payload = _decodeJwtPayload(_authToken!);
    if (payload == null) return true;

    final exp = payload['exp'];
    if (exp == null) return true;

    // exp is in seconds since epoch
    final expirationTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    final now = DateTime.now();

    return now.isAfter(expirationTime);
  }

  /// Decode JWT token payload
  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode the payload (second part)
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));

      return json.decode(decoded) as Map<String, dynamic>;
    } catch (e) {
      print('Error decoding JWT token: $e');
      return null;
    }
  }

  // Cargar el estado desde SharedPreferences
  Future<void> loadState() async {
    final prefs = await SharedPreferences.getInstance();

    // Sync with AuthManager
    _authToken = prefs.getString('authToken');
    _refreshToken = prefs.getString('refreshToken');
    _currentUser = prefs.getString('currentUser') != null
        ? UserModel.fromJson(jsonDecode(prefs.getString('currentUser')!))
        : null;
    _currentParking = prefs.getString('currentParking') != null
        ? ParkingModel.fromJson(jsonDecode(prefs.getString('currentParking')!))
        : null;

    // Cargar otros datos
    _selectedAreaId = prefs.getString(_selectedAreaIdKey);

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

    final printSettingsJson = prefs.getString(_printSettingsKey);
    if (printSettingsJson != null) {
      _printSettings = PrintSettings.fromJson(jsonDecode(printSettingsJson));
    }

    notifyListeners();
  }

  // Guardar el estado en SharedPreferences (tokens)
  Future<void> saveState() async {
    final prefs = await SharedPreferences.getInstance();

    // Guardar tokens
    await prefs.setString('authToken', _authToken ?? '');
    await prefs.setString('refreshToken', _refreshToken ?? '');
    if (_currentUser != null) {
      await prefs.setString('currentUser', jsonEncode(_currentUser?.toJson()));
    } else {
      await prefs.remove('currentUser');
    }

    if (_currentParking != null) {
      await prefs.setString(
        'currentParking',
        jsonEncode(_currentParking?.toJson()),
      );
    } else {
      await prefs.remove('currentParking');
    }
    if (_selectedAreaId != null) {
      await prefs.setString(_selectedAreaIdKey, _selectedAreaId!);
    } else {
      await prefs.remove(_selectedAreaIdKey);
    }
    await prefs.setString(
      _printSettingsKey,
      jsonEncode(_printSettings.toJson()),
    );
    await _savePrintSettings();
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
    await prefs.setString(
      _printSettingsKey,
      jsonEncode(_printSettings.toJson()),
    );
  }

  // User state setters
  Future<void> setCurrentUser(UserModel? currentUser) async {
    _currentUser = currentUser;
    await saveState();
    notifyListeners();
  }

  Future<void> setCurrentParking(
    ParkingModel parking,
    EmployeeModel? employee,
  ) async {
    _currentParking = parking;
    _employee = employee;
    _selectedAreaId = null;
    await saveState();
    notifyListeners();
  }

  Future<void> setCurrentArea(String areaId) async {
    _selectedAreaId = areaId;
    await saveState();
    notifyListeners();
  }

  Future<void> setCurrentCashRegister(CashRegisterModel? cashRegister) async {
    _currentCashRegister = cashRegister;
    await saveState();
    notifyListeners();
  }

  Future<void> setAccessToken(String? authToken) async {
    _authToken = authToken;
    await saveState();
    notifyListeners();
  }

  Future<void> setRefreshToken(String? refreshToken) async {
    _refreshToken = refreshToken;
    await saveState();
    notifyListeners();
  }

  Future<void> setPrinterSettings(PrintSettings settings) async {
    _printSettings = settings;
    notifyListeners();
    await saveState();
  }

  Future<void> logout() async {
    _currentUser = null;
    _employee = null;
    _currentParking = null;
    _currentCashRegister = null;
    _authToken = null;
    _refreshToken = null;
    _selectedAreaId = null;
    await saveState();

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
