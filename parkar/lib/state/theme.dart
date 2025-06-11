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
    _updateSystemUIOverlayStyle();
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

  // Idioma
  Locale? _locale;
  Locale? get locale => _locale;
  set locale(Locale? locale) {
    _locale = locale;
    _savePreferences();
    notifyListeners();
  }

  // Constructor
  AppTheme() {
    _loadPreferences();
    // Asegurar que el modo edge-to-edge esté habilitado desde el inicio
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    _updateSystemUIOverlayStyle();
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
    _updateSystemUIOverlayStyle();
  }

  // Método para actualizar el estilo de la barra de estado
  void _updateSystemUIOverlayStyle() {
    final isDark = mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);

    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      // Barra de estado
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,

      // Barra de navegación
      systemNavigationBarColor: backgroundColor,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ));

    // Configurar el color de fondo y el comportamiento de la barra de navegación
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
  }

  // Método para guardar preferencias
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (_color != null) {
      prefs.setInt('theme_color', _color!.value);
    }
    prefs.setString('theme_mode', _mode.toString());
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

    notifyListeners();
  }

  // Método para obtener el ThemeData del tema claro
  ThemeData getLightTheme() {
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: color,
      brightness: Brightness.light,
      // Ajustar colores para un diseño más moderno
      primary: color,
      primaryContainer: color.withOpacity(0.12),
      secondary: color.withBlue(min(color.blue + 20, 255)),
      surface: Colors.white,
      background: Colors.grey[50]!,
      surfaceVariant: Colors.grey[100]!,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: baseColorScheme,
      // Usar una fuente moderna y más ligera
      fontFamily: 'Roboto',
      // Reducir tamaños de texto por defecto
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.5),
        displayMedium: TextStyle(
            fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.5),
        displaySmall: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.5),
        headlineLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
        bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
        labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      // Configuraciones para pantalla completa
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: baseColorScheme.onSurface),
        iconTheme: IconThemeData(color: baseColorScheme.onSurface, size: 22),
      ),
      // Estilos más modernos para tarjetas
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        color: Colors.white,
        margin: EdgeInsets.zero,
      ),
      // Botones más planos y modernos
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: baseColorScheme.primary,
          foregroundColor: baseColorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: baseColorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: baseColorScheme.outline, width: 1),
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: baseColorScheme.primary,
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          textStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
        ),
      ),
      // Iconos pequeños y nítidos
      iconTheme: IconThemeData(
        size: 22,
        color: baseColorScheme.onSurface,
      ),
      // Inputs más modernos
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: baseColorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: baseColorScheme.primary, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: TextStyle(
            fontSize: 14,
            color: baseColorScheme.onSurfaceVariant.withOpacity(0.7)),
        labelStyle:
            TextStyle(fontSize: 14, color: baseColorScheme.onSurfaceVariant),
      ),
      // Chips más compactos
      chipTheme: ChipThemeData(
        backgroundColor: baseColorScheme.surfaceContainerHighest,
        labelStyle: const TextStyle(fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      // Tabs más compactos
      tabBarTheme: const TabBarTheme(
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        unselectedLabelStyle:
            TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        indicatorSize: TabBarIndicatorSize.label,
      ),
      // Diseño compacto para Dialogs
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle:
            const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        contentTextStyle: const TextStyle(fontSize: 14),
      ),
      // Snackbars más compactos y modernos
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentTextStyle: const TextStyle(fontSize: 13),
        actionTextColor: baseColorScheme.primary,
      ),
      // Ajustes para checkboxes y switches
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: const BorderSide(width: 1.5),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return baseColorScheme.primary;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return baseColorScheme.primary.withOpacity(0.3);
          }
          return null;
        }),
      ),
    );
  }

  // Método para obtener el ThemeData del tema oscuro
  ThemeData getDarkTheme() {
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: color,
      brightness: Brightness.dark,
      // Ajustar colores para un diseño más moderno
      primary: color.withOpacity(0.9),
      primaryContainer: color.withOpacity(0.2),
      secondary: color.withBlue(min(color.blue + 20, 255)).withOpacity(0.9),
      surface: const Color(0xFF1E1E1E),
      background: const Color(0xFF121212),
      surfaceVariant: const Color(0xFF2C2C2C),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: baseColorScheme,
      // Usar una fuente moderna y más ligera
      fontFamily: 'Roboto',
      // Reducir tamaños de texto por defecto
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.5),
        displayMedium: TextStyle(
            fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.5),
        displaySmall: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.5),
        headlineLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
        bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
        labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      // Configuraciones para pantalla completa
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: baseColorScheme.onSurface),
        iconTheme: IconThemeData(color: baseColorScheme.onSurface, size: 22),
      ),
      // Estilos más modernos para tarjetas
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2C2C2C), width: 1),
        ),
        color: baseColorScheme.surface,
        margin: EdgeInsets.zero,
      ),
      // Botones más planos y modernos
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: baseColorScheme.primary,
          foregroundColor: baseColorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: baseColorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: baseColorScheme.outline, width: 1),
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: baseColorScheme.primary,
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          textStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
        ),
      ),
      // Iconos pequeños y nítidos
      iconTheme: IconThemeData(
        size: 22,
        color: baseColorScheme.onSurface,
      ),
      // Inputs más modernos
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: baseColorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: baseColorScheme.primary, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: TextStyle(
            fontSize: 14,
            color: baseColorScheme.onSurfaceVariant.withOpacity(0.7)),
        labelStyle:
            TextStyle(fontSize: 14, color: baseColorScheme.onSurfaceVariant),
      ),
      // Chips más compactos
      chipTheme: ChipThemeData(
        backgroundColor: baseColorScheme.surfaceContainerHighest,
        labelStyle: const TextStyle(fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      // Tabs más compactos
      tabBarTheme: const TabBarTheme(
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        unselectedLabelStyle:
            TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        indicatorSize: TabBarIndicatorSize.label,
      ),
      // Diseño compacto para Dialogs
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle:
            const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        contentTextStyle: const TextStyle(fontSize: 14),
      ),
      // Snackbars más compactos y modernos
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentTextStyle: const TextStyle(fontSize: 13),
        actionTextColor: baseColorScheme.primary,
      ),
      // Ajustes para checkboxes y switches
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: const BorderSide(width: 1.5),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return baseColorScheme.primary;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return baseColorScheme.primary.withOpacity(0.3);
          }
          return null;
        }),
      ),
    );
  }

  @override
  String toString() {
    return 'AppTheme(mode: $_mode)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppTheme &&
        other._mode == _mode &&
        other.color.value == color.value &&
        other.locale == _locale;
  }

  @override
  int get hashCode => Object.hash(_mode, color, _locale);
}

Color get systemAccentColor {
  if ((defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.android) &&
      !kIsWeb) {
    return SystemTheme.accentColor.accent;
  }
  return Colors.blue;
}

// Función auxiliar para min
int min(int a, int b) => a < b ? a : b;
