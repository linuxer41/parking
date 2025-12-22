import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Componente list para manejar la presentación responsiva de páginas
/// En móvil: página completa con AppBar
/// En desktop: contenido centrado
class PageLayout extends StatelessWidget {
  /// Título de la página
  final String title;

  /// Contenido principal de la página
  final Widget body;

  /// Acciones de la AppBar (opcional)
  final List<Widget>? actions;

  /// Botón flotante (opcional)
  final Widget? floatingActionButton;

  /// Posición del botón flotante (opcional)
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Indica si centrar el contenido en desktop (opcional)
  final bool centerContent;

  /// Ancho máximo del contenido centrado (opcional)
  final double? maxContentWidth;

  /// Widget personalizado para el leading del AppBar (opcional)
  final Widget? leading;

  const PageLayout({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.centerContent = true,
    this.maxContentWidth,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    // Ajustar el brillo de los iconos de la barra de estado
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      statusBarBrightness: theme.brightness == Brightness.dark ? Brightness.dark : Brightness.light,
    ));

    // Contenido con centrado opcional en desktop
    final content = centerContent && isDesktop
        ? Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth ?? 600),
              child: body,
            ),
          )
        : body;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            // letterSpacing: -0.5,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: leading == null,
        leading: leading,
        actions: actions,
      ),
      body: SafeArea(child: content),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
