import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/auth/auth_layout.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Recuperar Contraseña',
      children: [
        const TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Lógica para enviar el correo de recuperación
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Enviar'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            context.go('/login');
          },
          child: const Text('Volver a Iniciar Sesión'),
        ),
      ],
    );
  }
}