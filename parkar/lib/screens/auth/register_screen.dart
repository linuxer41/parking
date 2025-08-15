import 'package:flutter/material.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = 'Las contraseñas no coinciden';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authService = AppStateContainer.di(context).resolve<AuthService>();

      try {
        final response = await authService.register(
          _emailController.text,
          _passwordController.text,
          _nameController.text,
          _phoneController.text,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Redirigir a la vista de creación de compañía
        if (mounted) {
          context.go('/login');
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Error al registrar usuario: $e';
          });
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

    return AuthLayout(
      title: 'Crear Cuenta',
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
              // Campo de Nombre
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre completo',
                  hintText: 'Juan Pérez',
                  prefixIcon: Icon(
                    Icons.person_outline,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
                style: textTheme.bodyMedium,
              ),

              const SizedBox(height: 16),

              // Campo de Email
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
                style: textTheme.bodyMedium,
              ),

              const SizedBox(height: 16),

              // Campo de Contraseña
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Mínimo 6 caracteres',
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
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una contraseña';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
                style: textTheme.bodyMedium,
              ),

              const SizedBox(height: 16),

              // Campo de Confirmar Contraseña
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmar contraseña',
                  hintText: 'Repite tu contraseña',
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      setState(() {
                        _showConfirmPassword = !_showConfirmPassword;
                      });
                    },
                  ),
                ),
                obscureText: !_showConfirmPassword,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor confirma tu contraseña';
                  }
                  if (value != _passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
                onFieldSubmitted: (_) {
                  if (!_isLoading) {
                    _submitForm();
                  }
                },
                style: textTheme.bodyMedium,
              ),

              const SizedBox(height: 24),

              // Botón de Registro
              FilledButton(
                onPressed: _isLoading ? null : _submitForm,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  disabledBackgroundColor:
                      colorScheme.primary.withValues(alpha: 102),
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
                        'Crear cuenta',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onPrimary,
                        ),
                      ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Link a Login
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¿Ya tienes una cuenta?',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            TextButton(
              onPressed: () {
                context.go('/login');
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Iniciar sesión',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary.withValues(alpha: 127),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
