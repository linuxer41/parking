import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar mensajes de error y éxito
class CustomMessageWidget extends StatelessWidget {
  /// Mensaje a mostrar
  final String message;

  /// Tipo de mensaje (error o success)
  final MessageType type;

  /// Función para cerrar el mensaje
  final VoidCallback? onClose;

  /// Margen inferior del widget
  final EdgeInsetsGeometry? margin;

  /// Padding interno del widget
  final EdgeInsetsGeometry? padding;

  const CustomMessageWidget({
    super.key,
    required this.message,
    required this.type,
    this.onClose,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Determinar colores y íconos según el tipo
    final Color backgroundColor;
    final Color textColor;
    final Color iconColor;
    final IconData icon;

    switch (type) {
      case MessageType.error:
        backgroundColor = colorScheme.errorContainer.withValues(alpha: 127);
        textColor = colorScheme.error;
        iconColor = colorScheme.error;
        icon = Icons.error_outline;
        break;
      case MessageType.success:
        backgroundColor = colorScheme.primaryContainer.withValues(alpha: 127);
        textColor = colorScheme.primary;
        iconColor = colorScheme.primary;
        icon = Icons.check_circle_outline;
        break;
      case MessageType.warning:
        backgroundColor = colorScheme.tertiaryContainer.withValues(alpha: 127);
        textColor = colorScheme.tertiary;
        iconColor = colorScheme.tertiary;
        icon = Icons.warning_outlined;
        break;
      case MessageType.info:
        backgroundColor = colorScheme.secondaryContainer.withValues(alpha: 127);
        textColor = colorScheme.secondary;
        iconColor = colorScheme.secondary;
        icon = Icons.info_outline;
        break;
    }

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 20),
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodySmall?.copyWith(color: textColor),
            ),
          ),
          if (onClose != null)
            IconButton(
              onPressed: onClose,
              icon: Icon(Icons.close, color: iconColor, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
        ],
      ),
    );
  }
}

/// Tipos de mensajes disponibles
enum MessageType { error, success, warning, info }

/// Widget condicional que solo se muestra si hay un mensaje
class ConditionalMessageWidget extends StatelessWidget {
  /// Mensaje a mostrar (puede ser null)
  final String? message;

  /// Tipo de mensaje
  final MessageType type;

  /// Función para cerrar el mensaje
  final VoidCallback? onClose;

  /// Margen inferior del widget
  final EdgeInsetsGeometry? margin;

  /// Padding interno del widget
  final EdgeInsetsGeometry? padding;

  const ConditionalMessageWidget({
    super.key,
    this.message,
    required this.type,
    this.onClose,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomMessageWidget(
      message: message!,
      type: type,
      onClose: onClose,
      margin: margin,
      padding: padding,
    );
  }
}
