import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Clase de utilidad para manejar el tema en toda la aplicación
class ThemeHelper {
  /// Determina si el tema actual es oscuro
  static bool isDarkMode(BuildContext context) {
    // Primero verificamos si hay un tema explícito en el contexto
    final brightness = Theme.of(context).brightness;
    if (brightness != null) {
      return brightness == Brightness.dark;
    }
    
    // Si no hay un tema explícito, usamos la configuración del sistema
    return SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  }
  
  /// Obtiene el color de fondo apropiado según el tema actual
  static Color getBackgroundColor(BuildContext context) {
    return isDarkMode(context) 
        ? const Color(0xFF121212) 
        : Colors.white;
  }
  
  /// Obtiene el color de texto apropiado según el tema actual
  static Color getTextColor(BuildContext context) {
    return isDarkMode(context) 
        ? Colors.white 
        : const Color(0xFF1D1D1F);
  }
  
  /// Obtiene el color de acento apropiado según el tema actual
  static Color getAccentColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }
  
  /// Obtiene el color sutil para elementos secundarios
  static Color getSubtleColor(BuildContext context) {
    return isDarkMode(context) 
        ? Colors.grey.shade400 
        : const Color(0xFF86868B);
  }
  
  /// Obtiene el brillo de los iconos de la barra de estado apropiado para el tema
  static Brightness getStatusBarBrightness(BuildContext context) {
    return isDarkMode(context) ? Brightness.light : Brightness.dark;
  }
} 