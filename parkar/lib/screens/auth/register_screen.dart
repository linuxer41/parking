import 'package:flutter/material.dart' as material;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';
import '../../state/app_state_container.dart';
import '../../widgets/auth/auth_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _submitForm() async {
    if (_nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty) {
      if (_passwordController.text != _confirmPasswordController.text) {
        displayInfoBar(
          context,
          builder: (context, close) {
            return const InfoBar(
              title: Text('Error'),
              content: Text('Las contraseñas no coinciden.'),
              severity: InfoBarSeverity.error,
            );
          },
        );
        return;
      }

      final authService = AppStateContainer.di(context).resolve<AuthService>();

      try {
        final response = await authService.register(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
        );

        if (!mounted) return;

        displayInfoBar(
          context,
          builder: (context, close) {
            return InfoBar(
              title: const Text('Éxito'),
              content: Text(response['message']),
              severity: InfoBarSeverity.success,
            );
          },
        );

        // Redirigir a la vista de creación de compañía
        if (mounted) {
          context.go('/create-company');
        }
      } catch (e) {
        if (mounted) {
          displayInfoBar(
            context,
            builder: (context, close) {
              return InfoBar(
                title: const Text('Error'),
                content: Text('Error al registrarse: $e'),
                severity: InfoBarSeverity.error,
              );
            },
          );
        }
      }
    } else {
      displayInfoBar(
        context,
        builder: (context, close) {
          return const InfoBar(
            title: Text('Error'),
            content: Text('Todos los campos son obligatorios.'),
            severity: InfoBarSeverity.error,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Registro',
      children: [
        TextBox(
          controller: _nameController,
          placeholder: 'Nombre',
        ),
        const SizedBox(height: 16),
        TextBox(
          controller: _emailController,
          placeholder: 'Email',
        ),
        const SizedBox(height: 16),
        TextBox(
          controller: _passwordController,
          placeholder: 'Contraseña',
          obscureText: true,
        ),
        const SizedBox(height: 16),
        TextBox(
          controller: _confirmPasswordController,
          placeholder: 'Confirmar Contraseña',
          obscureText: true,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _submitForm,
          child: const Text('Registrarse'),
        ),
        const SizedBox(height: 16),
        material.TextButton(
          onPressed: () {
            context.go('/login');
          },
          child: const Text('¿Ya tienes una cuenta? Inicia Sesión'),
        ),
      ],
    );
  }
}