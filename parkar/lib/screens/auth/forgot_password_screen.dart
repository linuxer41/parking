import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/auth/auth_layout.dart';
import '../../services/auth_service.dart';
import '../../state/app_state_container.dart';
import '../../widgets/custom_input_field.dart';
import '../../widgets/custom_snackbar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _successMessage = null;
      });

      final authService = AppStateContainer.di(context).resolve<AuthService>();

      try {
        final response = await authService.forgotPassword(
          _emailController.text,
        );

        if (!mounted) return;

        setState(() {
          _successMessage =
              'Se ha enviado un correo con las instrucciones para recuperar tu contraseña.';
        });
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Error al enviar el correo: $e';
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
      title: 'Recuperar Contraseña',
      subtitle: 'Te enviaremos instrucciones a tu correo',
      children: [
        Text(
          'Ingresa tu correo electrónico y te enviaremos instrucciones para recuperar tu contraseña.',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        CustomMessageWidget(
          message: _errorMessage ?? '',
          type: MessageType.error,
          onClose: () {
            setState(() {
              _errorMessage = null;
            });
          },
        ),
        CustomMessageWidget(
          message: _successMessage ?? '',
          type: MessageType.success,
          onClose: () {
            setState(() {
              _successMessage = null;
            });
          },
        ),
        Form(
          key: _formKey,
          child: Column(
            children: [
              CustomFormInputField(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'ejemplo@correo.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Por favor ingresa un email válido';
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
                        'Enviar instrucciones',
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
            context.go('/login');
          },
          icon: Icon(Icons.arrow_back, size: 16, color: colorScheme.primary),
          label: Text(
            'Volver a Iniciar Sesión',
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
