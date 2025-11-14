import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';
import '../../services/api_exception.dart';
import '../../state/app_state_container.dart';
import '../../widgets/auth/auth_layout.dart';
import '../../widgets/custom_input_field.dart';
import '../../widgets/custom_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'test@example.com');
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
        print('Token recibido en login: ${authResponse.auth.token}');
        appState.setAccessToken(authResponse.auth.token);
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
      } on ApiException catch (e) {
        String errorMessage;

        if (e.isValidationError) {
          // Manejar errores de validación específicamente
          errorMessage = _parseValidationError(e);
        } else {
          // Manejar otros errores de API
          switch (e.statusCode) {
            case 401:
              errorMessage =
                  'Credenciales incorrectas. Verifica tu email y contraseña.';
              break;
            case 404:
              errorMessage = 'Usuario no encontrado. Verifica tu email.';
              break;
            case 500:
              errorMessage =
                  'Error del servidor. Intenta nuevamente más tarde.';
              break;
            default:
              errorMessage = e.message;
          }
        }

        setState(() {
          _errorMessage = errorMessage;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error inesperado: ${e.toString()}';
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

  /// Parse validation errors from API response
  String _parseValidationError(ApiException e) {
    if (e.errors != null) {
      // Buscar errores específicos en la respuesta de validación
      final errors = e.errors!;

      // Si hay un resumen del error, usarlo
      if (errors['summary'] != null) {
        return errors['summary'] as String;
      }

      // Si hay un mensaje específico, usarlo
      if (errors['message'] != null) {
        return errors['message'] as String;
      }

      // Si hay una lista de errores, procesar el primero
      if (errors['errors'] != null && errors['errors'] is List) {
        final errorList = errors['errors'] as List;
        if (errorList.isNotEmpty) {
          final firstError = errorList.first;
          if (firstError is Map<String, dynamic>) {
            if (firstError['summary'] != null) {
              return firstError['summary'] as String;
            }
            if (firstError['message'] != null) {
              return firstError['message'] as String;
            }
          }
        }
      }
    }

    // Fallback al mensaje general
    return e.message;
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
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ConditionalMessageWidget(
                message: _errorMessage,
                type: MessageType.error,
                onClose: () {
                  setState(() {
                    _errorMessage = null;
                  });
                },
              ),
              // Campo de Email moderno y compacto
              CustomFormInputField(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'ejemplo@correo.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Por favor ingresa un email válido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Campo de Contraseña moderno y compacto
              CustomFormInputField(
                controller: _passwordController,
                labelText: 'Contraseña',
                hintText: '********',
                prefixIcon: Icons.lock_outline,
                obscureText: !_showPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu contraseña';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                onSubmitted: () {
                  if (!_isLoading) {
                    _submitForm();
                  }
                },
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
