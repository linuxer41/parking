import 'package:flutter/material.dart' as material;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:parkar/services/parking_service.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../state/app_state_container.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth/auth_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(
    text: 'admin@example.com',
  );
  final _passwordController = TextEditingController(
    text: 'password123',
  );
  bool _obscurePassword = true;

  Future<void> _submitForm() async {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      final appState = AppStateContainer.of(context);
      final authService = AppStateContainer.di(context).resolve<AuthService>();
      final userService = AppStateContainer.di(context).resolve<UserService>();
      final parkingService = AppStateContainer.di(context).resolve<ParkingService>();
      try {
        final response = await authService.login(
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
        final user = UserModel.fromJson(response['data']['user']);
        appState.setAccessToken(response['data']['authToken']);
        appState.setRefreshToken(response['data']['refreshToken']);
        appState.setUser(user);

        final companies = await userService.getCompanies(user.id);
        // if has only one company, set it as the default company
        if (companies.length == 1) {
          // if has only one branch, set it as the default branch
          if (companies.first.parkings.length == 1) {
            appState.setCompany(companies.first);
            final targetParking = companies.first.parkings.first;
            final detailedParkig = await parkingService.getDetailed(targetParking.id);
            appState.setParking(detailedParkig);
            // appState.setParking(companies.first.parkings.first);
            if (mounted) context.go('/home');
            return;
          }
        }
        if (mounted) context.go('/init');
      } catch (e) {
        if (mounted) {
          displayInfoBar(
            context,
            builder: (context, close) {
              return InfoBar(
                title: const Text('Error'),
                content: Text('Error al iniciar sesión: $e'),
                severity: InfoBarSeverity.error,
              );
            },
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Iniciar Sesión',
      children: [
        TextBox(
          controller: _emailController,
          placeholder: 'Email',
        ),
        const SizedBox(height: 16),
        TextBox(
          controller: _passwordController,
          placeholder: 'Contraseña',
          obscureText: _obscurePassword,
          suffix: IconButton(
            icon: Icon(_obscurePassword ? FluentIcons.view : FluentIcons.hide3),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _submitForm,
          child: const Text('Iniciar Sesión'),
        ),
        const SizedBox(height: 16),
        material.TextButton(
          onPressed: () {
            context.go('/forgot-password');
          },
          child: const Text('¿Olvidaste tu contraseña?'),
        ),
        const SizedBox(height: 8),
        material.TextButton(
          onPressed: () {
            context.go('/register');
          },
          child: const Text('Registrarse'),
        ),
      ],
    );
  }
}
