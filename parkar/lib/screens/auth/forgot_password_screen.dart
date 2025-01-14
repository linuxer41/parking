import 'package:flutter/material.dart' as material;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/auth/auth_layout.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Recuperar Contraseña',
      children: [
        const TextBox(
          placeholder: 'Email',
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () {
            // Lógica para enviar el correo de recuperación
          },
          child: const Text('Enviar'),
        ),
        const SizedBox(height: 8),
        material.TextButton(
          onPressed: () {
            context.go('/login');
          },
          child: const Text('Volver a Iniciar Sesión'),
        ),
      ],
    );
  }
}