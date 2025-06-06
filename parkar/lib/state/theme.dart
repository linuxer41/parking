import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_theme/system_theme.dart';

class AppTheme extends ChangeNotifier {
  // Color primario
  Color? _color;
  Color get color => _color ?? systemAccentColor;
  set color(Color color) {
    _color = color;
    _savePreferences();
    notifyListeners();
  }

  // Modo de tema
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;
  set mode(ThemeMode mode) {
    _mode = mode;
    _savePreferences();
    notifyListeners();
  }

  // Dirección del texto
  TextDirection _textDirection = TextDirection.ltr;
  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection direction) {
    _textDirection = direction;
    _savePreferences();
    notifyListeners();
  }

  // Idioma
  Locale? _locale;
  Locale? get locale => _locale;
  set locale(Locale? locale) {
    _locale = locale;
    _savePreferences();
    notifyListeners();
  }

  // Tamaño de fuente para accesibilidad
  double _textScaleFactor = 1.0;
  double get textScaleFactor => _textScaleFactor;
  set textScaleFactor(double scale) {
    _textScaleFactor = scale;
    _savePreferences();
    notifyListeners();
  }

  // Alto contraste para accesibilidad
  bool _highContrast = false;
  bool get highContrast => _highContrast;
  set highContrast(bool value) {
    _highContrast = value;
    _savePreferences();
    notifyListeners();
  }

  // Reducir animaciones para accesibilidad
  bool _reduceAnimations = false;
  bool get reduceAnimations => _reduceAnimations;
  set reduceAnimations(bool value) {
    _reduceAnimations = value;
    _savePreferences();
    notifyListeners();
  }

  // Constructor
  AppTheme() {
    _loadPreferences();
  }

  // Método para alternar entre modos de tema
  void toggleThemeMode() {
    switch (_mode) {
      case ThemeMode.light:
        mode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        mode = ThemeMode.system;
        break;
      case ThemeMode.system:
        mode = ThemeMode.light;
        break;
    }
  }

  // Método para aumentar el tamaño de la fuente
  void increaseTextSize() {
    if (_textScaleFactor < 1.5) {
      _textScaleFactor += 0.1;
      _savePreferences();
      notifyListeners();
    }
  }

  // Método para disminuir el tamaño de la fuente
  void decreaseTextSize() {
    if (_textScaleFactor > 0.8) {
      _textScaleFactor -= 0.1;
      _savePreferences();
      notifyListeners();
    }
  }

  // Método para guardar preferencias
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (_color != null) {
      prefs.setInt('theme_color', _color!.value);
    }
    prefs.setString('theme_mode', _mode.toString());
    prefs.setString('text_direction', _textDirection.toString());
    prefs.setDouble('text_scale_factor', _textScaleFactor);
    prefs.setBool('high_contrast', _highContrast);
    prefs.setBool('reduce_animations', _reduceAnimations);
    if (_locale != null) {
      prefs.setString('locale', _locale.toString());
    }
  }
  
  // Método público para guardar preferencias inmediatamente
  Future<void> savePreferencesNow() async {
    await _savePreferences();
  }

  // Método para cargar preferencias
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    final colorValue = prefs.getInt('theme_color');
    if (colorValue != null) {
      _color = Color(colorValue);
    }
    
    final modeString = prefs.getString('theme_mode');
    if (modeString != null) {
      if (modeString.contains('ThemeMode.light')) {
        _mode = ThemeMode.light;
      } else if (modeString.contains('ThemeMode.dark')) {
        _mode = ThemeMode.dark;
      } else {
        _mode = ThemeMode.system;
      }
    }
    
    final dirString = prefs.getString('text_direction');
    if (dirString != null) {
      _textDirection = dirString.contains('rtl') 
          ? TextDirection.rtl 
          : TextDirection.ltr;
    }
    
    _textScaleFactor = prefs.getDouble('text_scale_factor') ?? 1.0;
    _highContrast = prefs.getBool('high_contrast') ?? false;
    _reduceAnimations = prefs.getBool('reduce_animations') ?? false;
    
    notifyListeners();
  }

  // Método para obtener el ThemeData del tema claro
  ThemeData getLightTheme() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: Brightness.light,
      ),
      fontFamily: 'Roboto',
      // Configuraciones para pantalla completa
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
      ),
    );
    
    return _applyAccessibilitySettings(baseTheme);
  }

  // Método para obtener el ThemeData del tema oscuro
  ThemeData getDarkTheme() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: Brightness.dark,
      ),
      fontFamily: 'Roboto',
      // Configuraciones para pantalla completa
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
      ),
    );
    
    return _applyAccessibilitySettings(baseTheme);
  }

  // Aplicar configuraciones de accesibilidad al tema
  ThemeData _applyAccessibilitySettings(ThemeData baseTheme) {
    var theme = baseTheme;
    
    // Aplicar alto contraste si está activado
    if (_highContrast) {
      final colorScheme = theme.colorScheme;
      theme = theme.copyWith(
        colorScheme: colorScheme.copyWith(
          // Aumentar el contraste entre fondo y texto
          onBackground: colorScheme.brightness == Brightness.dark 
              ? Colors.white 
              : Colors.black,
          surface: colorScheme.brightness == Brightness.dark 
              ? Colors.black 
              : Colors.white,
          onSurface: colorScheme.brightness == Brightness.dark 
              ? Colors.white 
              : Colors.black,
        ),
      );
    }
    
    // Aplicar reducción de animaciones
    if (_reduceAnimations) {
      theme = theme.copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
        // Reducir duración de las animaciones
        splashFactory: InkRipple.splashFactory,
      );
    }
    
    return theme;
  }

  @override
  String toString() {
    return 'AppTheme(mode: $_mode)';
  }
}

Color get systemAccentColor {
  if ((defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.android) &&
      !kIsWeb) {
    return SystemTheme.accentColor.accent;
  }
  return Colors.blue;
}