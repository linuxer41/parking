import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';
import '../../state/app_state_container.dart';
import '../../widgets/auth/auth_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@example.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _showPassword = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final appState = AppStateContainer.of(context);
      final authService = AppStateContainer.di(context).resolve<AuthService>();

      try {
        final authResponse = await authService.login(
          _emailController.text,
          _passwordController.text,
        );

        if (!mounted) return;

        // Usar el modelo de respuesta de autenticación
        print('Token recibido en login: ${authResponse.token}');
        appState.setAccessToken(authResponse.token);
        print('Token después de setAccessToken: ${appState.authToken}');
        appState.setCurrentUser(authResponse.user);

        // Los parkings ahora vienen en la respuesta
        final parkings = authResponse.parkings;
        print('Parkings recibidos: ${parkings.length}');

        // Si solo hay un estacionamiento, seleccionarlo por defecto
        if (parkings.length == 1) {
          appState.setCurrentParking(parkings.first);
          if (mounted) context.go('/home');
          return;
        }

        // Si hay múltiples estacionamientos, ir a la pantalla de selección
        if (parkings.length > 1) {
          if (mounted) context.go('/select');
          return;
        }

        // Si no hay estacionamientos, ir directamente al home
        if (mounted) context.go('/home');
      } catch (e) {
        setState(() {
          _errorMessage = 'Error al iniciar sesión: $e';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage ?? 'Error desconocido'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return AuthLayout(
      title: 'Iniciar Sesión',
      subtitle: 'Ingresa tus credenciales para acceder',
      children: [
        if (_errorMessage != null)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 127),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: colorScheme.error, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo de Email moderno y compacto
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'ejemplo@correo.com',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Por favor ingresa un email válido';
                  }
                  return null;
                },
                autocorrect: false,
                enableSuggestions: true,
                style: textTheme.bodyMedium,
              ),

              const SizedBox(height: 20),

              // Campo de Contraseña moderno y compacto
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: '********',
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                ),
                obscureText: !_showPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu contraseña';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (!_isLoading) {
                    _submitForm();
                  }
                },
                style: textTheme.bodyMedium,
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    context.go('/forgot-password');
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary.withValues(alpha: 127),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Botón de Iniciar Sesión moderno y minimalista
              FilledButton(
                onPressed: _isLoading ? null : _submitForm,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: colorScheme.primary.withValues(
                    alpha: 60,
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : Text(
                        'Iniciar Sesión',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onPrimary,
                        ),
                      ),
              ),

              // Link de regreso a bienvenida
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      context.go('/welcome');
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 0,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      '← Volver al inicio',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
