import 'package:flutter/material.dart';

/// Muestra un snackbar personalizado y bonito que aparece en la parte superior
class CustomSnackbar {
  /// Muestra un snackbar personalizado
  static void show({
    required BuildContext context,
    required String message,
    bool isError = false,
    bool isSuccess = false,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    // Cerrar cualquier snackbar existente
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    // Determinar el color según el tipo
    final colorScheme = Theme.of(context).colorScheme;
    Color backgroundColor;
    Color textColor;
    IconData messageIcon;
    
    if (isError) {
      backgroundColor = Colors.red.shade700;
      textColor = Colors.white;
      messageIcon = icon ?? Icons.error_outline_rounded;
    } else if (isSuccess) {
      backgroundColor = Colors.green.shade600;
      textColor = Colors.white;
      messageIcon = icon ?? Icons.check_circle_outline_rounded;
    } else {
      backgroundColor = colorScheme.primary;
      textColor = colorScheme.onPrimary;
      messageIcon = icon ?? Icons.info_outline_rounded;
    }
    
    // Mostrar el snackbar personalizado
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            messageIcon,
            color: textColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                onAction();
              },
              style: TextButton.styleFrom(
                foregroundColor: textColor,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionLabel,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.fixed,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      duration: duration,
      dismissDirection: DismissDirection.horizontal,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  
  /// Muestra un snackbar de éxito
  static void showSuccess({
    required BuildContext context,
    required String message,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    show(
      context: context,
      message: message,
      isSuccess: true,
      icon: icon,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }
  
  /// Muestra un snackbar de error
  static void showError({
    required BuildContext context,
    required String message,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    show(
      context: context,
      message: message,
      isError: true,
      icon: icon,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }
  
  /// Muestra un snackbar informativo
  static void showInfo({
    required BuildContext context,
    required String message,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    show(
      context: context,
      message: message,
      icon: icon,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }
} 