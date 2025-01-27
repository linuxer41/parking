import 'package:flutter/material.dart';
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
    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: Colors.green,
          ),
        );

        final user = UserModel.fromJson(response['data']['user']);
        appState.setAccessToken(response['data']['authToken']);
        appState.setRefreshToken(response['data']['refreshToken']);
        appState.setUser(user);

        final companies = await userService.getCompanies(user.id);
        // Si solo hay una compañía, seleccionarla por defecto
        if (companies.length == 1) {
          // Si solo hay un parqueo, seleccionarlo por defecto
          if (companies.first.parkings.length == 1) {
            appState.setCompany(companies.first);
            final targetParking = companies.first.parkings.first;
            final detailedParking = await parkingService.getDetailed(targetParking.id);
            appState.setParking(detailedParking);
            appState.setLevel(detailedParking.levels.first);
            if (mounted) context.go('/home');
            return;
          }
        }
        if (mounted) context.go('/init');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al iniciar sesión: $e'),
              backgroundColor: Colors.red,
            ),
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
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          obscureText: _obscurePassword,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Iniciar Sesión'),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            context.go('/forgot-password');
          },
          child: const Text('¿Olvidaste tu contraseña?'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            context.go('/register');
          },
          child: const Text('Registrarse'),
        ),
      ],
    );
  }
}