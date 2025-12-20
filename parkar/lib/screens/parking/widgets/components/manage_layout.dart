import 'package:flutter/material.dart';
import '../../../../widgets/custom_snackbar.dart';

/// Layout común para todos los bottom sheets modales
class ManageLayout extends StatelessWidget {
  /// Título principal del modal
  final String title;

  /// Subtítulo o descripción adicional
  final String subtitle;

  /// Icono para mostrar junto al título
  final IconData icon;

  /// Color de fondo del contenedor del icono
  final Color? iconBackgroundColor;

  /// Color del icono
  final Color? iconColor;

  /// Contenido principal del modal
  final Widget content;

  /// Botones de acción en la parte inferior (puede ser una lista o un widget personalizado)
  final dynamic actions;

  /// Widget opcional para mostrar en la parte superior derecha (ej: botón de cancelar)
  final Widget? headerAction;

  /// Mensaje de error opcional
  final String? errorMessage;

  /// Altura relativa del modal (porcentaje de la altura de la pantalla)
  final double heightFactor;

  const ManageLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.content,
    required this.actions,
    this.iconBackgroundColor,
    this.iconColor,
    this.headerAction,
    this.errorMessage,
    this.heightFactor = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            // Indicador de arrastre
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Encabezado con título e icono
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color:
                          iconBackgroundColor ??
                          Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor ?? Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (headerAction != null) headerAction!,
                ],
              ),
            ),

            // Mensaje de error si existe
            ConditionalMessageWidget(
              message: errorMessage,
              type: MessageType.error,
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            ),

            // Contenido principal
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: content,
              ),
            ),

            // Botones de acción
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: actions is List<Widget>
                  ? Row(
                      children: [
                        for (int i = 0; i < actions.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(child: actions[i]),
                        ],
                      ],
                    )
                  : actions as Widget,
            ),
          ],
        ),
      ),
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    // si el mobil mostrar btotonseet sino mostrar como especio de modal pequeño
    if (isMobile) {
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        builder: (context) => child,
      );
    } else {
      return showDialog<T>(
        context: context,
        builder: (context) =>
            Dialog(backgroundColor: Colors.transparent, child: child),
      );
    }
  }
}
