import 'package:flutter/material.dart';

/// Widget wrapper que maneja la presentación responsive de pantallas del panel
/// En móvil: pantalla completa
/// En PC: modal centrado con ancho máximo
class PanelScreenWrapper extends StatelessWidget {
  /// Widget de la pantalla a mostrar
  final Widget child;

  /// Título de la pantalla
  final String title;

  /// Ancho máximo para pantallas de escritorio (por defecto 800px)
  final double maxWidth;

  /// Altura máxima para pantallas de escritorio (por defecto 90% de la pantalla)
  final double maxHeight;

  const PanelScreenWrapper({
    super.key,
    required this.child,
    required this.title,
    this.maxWidth = 800,
    this.maxHeight = 0.9,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    // En móvil, mostrar pantalla completa
    if (mediaQuery.isMobile) {
      return child;
    }

    // En PC, mostrar como modal centrado
    return _buildDesktopModal(context);
  }

  Widget _buildDesktopModal(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final mediaQuery = MediaQuery.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: mediaQuery.size.height * maxHeight,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header del modal
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.surfaceVariant.withOpacity(
                        0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contenido del modal
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extensión para MediaQuery para facilitar la detección de tamaños de pantalla
extension ResponsiveExtension on MediaQueryData {
  /// Verifica si es una pantalla móvil (< 600px)
  bool get isMobile => size.width < 600;

  /// Verifica si es una tablet (600px - 900px)
  bool get isTablet => size.width >= 600 && size.width < 900;

  /// Verifica si es una pantalla de escritorio (> 900px)
  bool get isDesktop => size.width >= 900;
}
