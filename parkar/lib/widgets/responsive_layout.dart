import 'package:flutter/material.dart';

/// Widget que proporciona un layout responsivo para toda la aplicación
/// Permite definir diferentes layouts según el tamaño de la pantalla
class ResponsiveLayout extends StatelessWidget {
  /// Widget a mostrar en pantallas móviles (< 600px)
  final Widget mobile;

  /// Widget a mostrar en tablets (600px - 900px)
  final Widget? tablet;

  /// Widget a mostrar en pantallas de escritorio (> 900px)
  final Widget? desktop;

  /// Constructor
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          // Vista de escritorio
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 600) {
          // Vista de tablet
          return tablet ?? mobile;
        } else {
          // Vista móvil
          return mobile;
        }
      },
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
