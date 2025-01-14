import 'package:flutter/material.dart' as material;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:window_manager/window_manager.dart';

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
    // Obtener el tema de Fluent UI
    final theme = FluentTheme.of(context);

    return Container(
      color: theme.micaBackgroundColor, // Usar el color de fondo del tema
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: theme.cardColor, // Usar el color de superficie del tema
                    borderRadius: BorderRadius.circular(8),
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
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.inactiveColor, // Usar el color de texto del tema
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
          ),
        ],
      ),
    );
  }
}