import 'package:flutter/material.dart';

/// Pantalla base para todas las pantallas de detalle del panel de control
/// Proporciona un layout consistente con un AppBar y un botón para volver atrás
class BaseDetailScreen extends StatelessWidget {
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
  const BaseDetailScreen({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    // Contenido principal con AppBar y botón de regreso
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontSize:
                18, // Tamaño fijo para evitar diferencias entre plataformas
            fontWeight: FontWeight.w600,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : colorScheme.onSurface,
          ),
        ),
        // Solo mostrar el botón de volver en vista móvil
        leading: isDesktop
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Volver',
              ),
        actions: actions,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      body: SafeArea(
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
