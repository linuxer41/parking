import 'package:flutter/material.dart';

/// Contenedor para mostrar mensajes de error
class ErrorContainer extends StatelessWidget {
  /// Mensaje de error a mostrar
  final String message;
  
  /// Icono opcional para mostrar junto al mensaje
  final IconData icon;
  
  /// Color del icono y borde
  final Color? color;
  
  /// Tamaño del texto
  final double fontSize;
  
  /// Tamaño del icono
  final double iconSize;
  
  const ErrorContainer({
    super.key,
    required this.message,
    this.icon = Icons.error_outline,
    this.color,
    this.fontSize = 12,
    this.iconSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final errorColor = color ?? Colors.red;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, color: errorColor, size: iconSize),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: errorColor, fontSize: fontSize),
            ),
          ),
        ],
      ),
    );
  }
}

/// Contenedor para mostrar un mensaje de error a pantalla completa
class FullScreenErrorContainer extends StatelessWidget {
  /// Mensaje de error a mostrar
  final String message;
  
  /// Icono opcional para mostrar junto al mensaje
  final IconData icon;
  
  /// Color del icono
  final Color? color;
  
  /// Altura del contenedor
  final double height;
  
  const FullScreenErrorContainer({
    super.key,
    required this.message,
    this.icon = Icons.error_outline,
    this.color,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final errorColor = color ?? Theme.of(context).colorScheme.error;
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 