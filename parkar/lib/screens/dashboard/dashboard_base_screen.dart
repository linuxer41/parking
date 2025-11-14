import 'package:flutter/material.dart';
import '../../widgets/page_layout.dart';

/// Pantalla base para todas las pantallas del dashboard del panel de control
///
/// Proporciona un layout consistente con:
/// - AppBar con título y botón de regreso (solo en móvil)
/// - SafeArea para el contenido
/// - Soporte para acciones y botones flotantes
/// - Estilo map consistente
class DashboardBaseScreen extends StatelessWidget {
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
  const DashboardBaseScreen({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    // Usar PageLayout para consistencia
    return PageLayout(
      title: title,
      body: body,
      actions: actions,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
