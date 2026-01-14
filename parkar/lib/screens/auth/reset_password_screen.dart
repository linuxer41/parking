import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/auth/auth_layout.dart';
import '../../services/auth_service.dart';
import '../../state/app_state_container.dart';
import '../../widgets/custom_input_field.dart';
import '../../widgets/custom_snackbar.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authService = AppStateContainer.di(context).resolve<AuthService>();

      try {
        await authService.resetPassword(
          widget.email,
          _codeController.text,
          _passwordController.text,
        );

        if (!mounted) return;

        // Show success message and navigate to login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contraseña actualizada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to login
        context.go('/login');
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Error al restablecer contraseña: $e';
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
      title: 'Restablecer Contraseña',
      subtitle: 'Ingresa el código y tu nueva contraseña',
      children: [
        Text(
          'Hemos enviado un código de 6 dígitos a ${widget.email}. Ingresa el código y establece tu nueva contraseña.',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ConditionalMessageWidget(
          message: _errorMessage,
          type: MessageType.error,
          onClose: () {
            setState(() {
              _errorMessage = null;
            });
          },
        ),
        Form(
          key: _formKey,
          child: Column(
            children: [
              CustomFormInputField(
                controller: _codeController,
                labelText: 'Código de verificación',
                hintText: '123456',
                prefixIcon: Icons.lock_clock,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el código';
                  }
                  if (value.length != 6) {
                    return 'El código debe tener 6 dígitos';
                  }
                  if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                    return 'El código debe contener solo números';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomFormInputField(
                controller: _passwordController,
                labelText: 'Nueva contraseña',
                hintText: 'Mínimo 8 caracteres',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una contraseña';
                  }
                  if (value.length < 8) {
                    return 'La contraseña debe tener al menos 8 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomFormInputField(
                controller: _confirmPasswordController,
                labelText: 'Confirmar contraseña',
                hintText: 'Repite la nueva contraseña',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor confirma la contraseña';
                  }
                  if (value != _passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
                onSubmitted: () {
                  if (!_isLoading) {
                    _submitForm();
                  }
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _submitForm,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  disabledBackgroundColor: colorScheme.primary.withValues(
                    alpha: 102,
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
                        'Restablecer contraseña',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onPrimary,
                        ),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () {
            context.go('/forgot-password');
          },
          icon: Icon(Icons.arrow_back, size: 16, color: colorScheme.primary),
          label: Text(
            'Volver',
            style: textTheme.labelMedium?.copyWith(color: colorScheme.primary),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ],
    );
  }
}