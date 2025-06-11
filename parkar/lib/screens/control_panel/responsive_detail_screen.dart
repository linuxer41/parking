import 'package:flutter/material.dart';
import 'base_detail_screen.dart';

/// Pantalla de detalle que se adapta a la vista (móvil o escritorio)
/// En escritorio, no muestra título para evitar duplicación con el panel derecho
class ResponsiveDetailScreen extends StatelessWidget {
  /// Título que se muestra en la AppBar (solo en móvil)
  final String title;

  /// Contenido principal de la pantalla
  final Widget body;

  /// Acciones adicionales para la AppBar (opcional)
  final List<Widget>? actions;

  /// Botón flotante (opcional)
  final Widget? floatingActionButton;

  /// Posición del botón flotante (opcional)
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Constructor
  const ResponsiveDetailScreen({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    // Aplicar padding adicional en modo escritorio para mejor legibilidad
    final paddedBody = isDesktop
        ? Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: body,
          )
        : body;

    return BaseDetailScreen(
      title: title, // Título vacío en escritorio para evitar duplicación
      body: isDesktop? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Formulario centrado
            SizedBox(
              width: 450,
              child: paddedBody,
            ),
          ],
        ) : paddedBody,
      actions: actions,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
