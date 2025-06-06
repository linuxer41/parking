import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AuthLayout extends StatelessWidget {
  final String title; // Título de la pantalla
  final List<Widget> children; // Contenido específico de cada pantalla

  const AuthLayout({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener el tema de Material Design
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface, // Usar el color de fondo del tema
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest, // Usar el color de superficie del tema
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // Sombra sutil
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Lottie.network(
                  'https://lottie.host/f9c194d5-1f86-434f-8f70-464d9778b1f9/7PqNtExetZ.json',
                  height: 100,
                  width: 100,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface, // Usar el color de texto del tema
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ...children, // Contenido específico de cada pantalla
              ],
            ),
          ),
        ),
      ),
    );
  }
}