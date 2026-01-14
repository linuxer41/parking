import 'package:flutter/material.dart';

/// Componente reutilizable para diálogos modales
class ModalDialog extends StatelessWidget {
  final String title;
  final double? width;
  final List<Widget> children;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? insetPadding;
  final bool barrierDismissible;
  final bool useRootNavigator;

  const ModalDialog({
    super.key,
    required this.title,
    this.width,
    required this.children,
    this.actions,
    this.insetPadding,
    this.barrierDismissible = true,
    this.useRootNavigator = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      insetPadding: insetPadding as EdgeInsets? ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: width ?? double.infinity,
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header con título
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                ],
              ),
            ),
            // Contenido scrollable
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: children,
                ),
              ),
            ),
            // Botones de acción fijos en la parte inferior
            if (actions != null && actions!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Método estático para mostrar el diálogo
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    double? width,
    required List<Widget> children,
    List<Widget>? actions,
    EdgeInsetsGeometry? insetPadding,
    bool barrierDismissible = true,
    bool useRootNavigator = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      useRootNavigator: useRootNavigator,
      builder: (context) => ModalDialog(
        title: title,
        width: width,
        children: children,
        actions: actions,
        insetPadding: insetPadding,
        barrierDismissible: barrierDismissible,
        useRootNavigator: useRootNavigator,
      ),
    );
  }
}