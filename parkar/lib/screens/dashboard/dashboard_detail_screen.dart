import 'package:flutter/material.dart';
import '../../widgets/page_layout.dart';

/// Pantalla de detalle del dashboard que se adapta automáticamente al tamaño de pantalla
///
/// En pantallas grandes (desktop), centra el contenido y aplica padding adicional
/// En pantallas pequeñas (móvil), muestra el contenido normal
///
/// Características:
/// - Diseño responsivo automático
/// - Centrado de contenido en desktop
/// - Padding adaptativo
/// - Soporte para acciones y botones flotantes
class DashboardDetailScreen extends StatelessWidget {
  /// Título que se muestra en la AppBar
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
  const DashboardDetailScreen({
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: body,
          )
        : body;

    // En desktop, centrar el contenido y limitar el ancho
    final responsiveBody = isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [SizedBox(width: 450, child: paddedBody)],
          )
        : paddedBody;

    return PageLayout(
      title: title,
      body: responsiveBody,
      actions: actions,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
