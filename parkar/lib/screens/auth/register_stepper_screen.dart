import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/parking_service.dart';
import '../../state/app_state_container.dart';
import '../../widgets/auth/auth_layout.dart';
import '../../widgets/auth/phone_input_field.dart';
import '../../widgets/custom_operation_mode_selector.dart';

import '../../widgets/custom_address_input.dart';
import '../../models/parking_model.dart';
import '../../models/auth_model.dart';
import '../../widgets/custom_snackbar.dart';

class RegisterStepperScreen extends StatefulWidget {
  const RegisterStepperScreen({super.key});

  @override
  State<RegisterStepperScreen> createState() => _RegisterStepperScreenState();
}

class _RegisterStepperScreenState extends State<RegisterStepperScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _parkingNameController = TextEditingController();
  final _parkingAddressController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentStep = 0;

  // Datos temporales del usuario
  TempUserData? _tempUserData;

  // Variables para el estacionamiento
  ParkingOperationMode _operationMode = ParkingOperationMode.list;

  // Referencia al widget de teléfono
  final GlobalKey _phoneFieldKey = GlobalKey();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _parkingNameController.dispose();
    _parkingAddressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();

    super.dispose();
  }

  Future<void> _registerUser() async {
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

      try {
        // Guardar datos del usuario temporalmente en memoria
        _tempUserData = TempUserData(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          phone: _phoneController.text,
        );

        // Avanzar al siguiente paso
        setState(() {
          _currentStep = 1;
          _isLoading = false;
        });
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Error al guardar datos: $e';
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _registerParking() async {
    if (_parkingNameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingresa el nombre del estacionamiento';
      });
      return;
    }

    if (_parkingAddressController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingresa la dirección del estacionamiento';
      });
      return;
    }

    if (_tempUserData == null) {
      setState(() {
        _errorMessage = 'Datos del usuario no encontrados';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = AppStateContainer.di(context).resolve<AuthService>();

    try {
      // Preparar las coordenadas
      ParkingLocationModel? location;
      if (_latitudeController.text.isNotEmpty &&
          _longitudeController.text.isNotEmpty) {
        final lat = double.tryParse(_latitudeController.text);
        final lng = double.tryParse(_longitudeController.text);
        if (lat != null && lng != null) {
          location = ParkingLocationModel(lat: lat, lng: lng);
        }
      }

      // Crear el modelo de registro completo
      final registerData = RegisterCompleteModel(
        user: _tempUserData!.toRegisterUserModel(),
        parking: RegisterParkingModel(
          name: _parkingNameController.text,
          operationMode: _operationMode.value,
          location: location,
        ),
      );

      // Realizar el registro completo
      final response = await authService.registerComplete(registerData);

      if (!mounted) return;

      // Configurar el estado de la aplicación igual que en login
      final appState = AppStateContainer.of(context);
      appState.setAccessToken(response.auth.token);
      appState.setCurrentUser(response.user);

      // Los parkings vienen en la respuesta
      final parkings = response.parkings;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cuenta creada exitosamente. Bienvenido ${response.user.name}',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Redirigir según la cantidad de estacionamientos (misma lógica que login)
      if (mounted) {
        // Si solo hay un estacionamiento, seleccionarlo por defecto
        if (parkings.length == 1) {
          appState.setCurrentParking(parkings.first);
          context.go('/home');
          return;
        }

        // Si hay múltiples estacionamientos, ir a la pantalla de selección
        if (parkings.length > 1) {
          context.go('/select');
          return;
        }

        // Si no hay estacionamientos, ir directamente al home
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al crear cuenta: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      _registerUser();
    } else {
      _registerParking();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AuthLayout(
      title: 'Crear Cuenta',
      subtitle: 'Completa los datos para crear tu cuenta',
      children: [
        // Indicador de pasos compacto
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Row(
            children: [
              Expanded(
                child: _buildStepIndicator(
                  step: 1,
                  title: 'Datos Personales',
                  isActive: _currentStep == 0,
                  isCompleted: _currentStep > 0,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              ),
              Container(
                width: 30,
                height: 2,
                color: _currentStep > 0
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 102),
              ),
              Expanded(
                child: _buildStepIndicator(
                  step: 2,
                  title: 'Estacionamiento',
                  isActive: _currentStep == 1,
                  isCompleted: false,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              ),
            ],
          ),
        ),

        // Contenido del paso actual
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _currentStep == 0 ? _buildUserStep() : _buildParkingStep(),
        ),

        const SizedBox(height: 24),

        // Botones de navegación (mismo estilo que login)
        Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Anterior',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary.withValues(alpha: 127),
                    ),
                  ),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: _isLoading ? null : _nextStep,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
                        _currentStep == 0 ? 'Siguiente' : 'Crear Cuenta',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onPrimary,
                        ),
                      ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Link a Login (mismo estilo que login)
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

  Widget _buildStepIndicator({
    required int step,
    required String title,
    required bool isActive,
    required bool isCompleted,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? colorScheme.primary
                : isActive
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: isActive || isCompleted
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 102),
              width: 1.5,
            ),
          ),
          child: Center(
            child: isCompleted
                ? Icon(
                    Icons.check_rounded,
                    color: colorScheme.onPrimary,
                    size: 16,
                  )
                : Text(
                    step.toString(),
                    style: textTheme.bodySmall?.copyWith(
                      color: isActive
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: textTheme.bodySmall?.copyWith(
            color: isActive || isCompleted
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            fontWeight: isActive || isCompleted
                ? FontWeight.w600
                : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUserStep() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Form(
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
          // Campo de Nombre (mismo estilo que login)
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
            autocorrect: false,
            enableSuggestions: true,
            style: textTheme.bodyMedium,
          ),

          const SizedBox(height: 16),

          // Campo de Email (mismo estilo que login)
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

          const SizedBox(height: 16),

          // Campo de Teléfono con selector de país
          PhoneInputField(
            key: _phoneFieldKey,
            controller: _phoneController,
            labelText: 'Teléfono',
            hintText: '123456789',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu teléfono';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 16),

          // Campo de Contraseña (mismo estilo que login)
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

          // Campo de Confirmar Contraseña (mismo estilo que login)
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
                _nextStep();
              }
            },
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildParkingStep() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
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
        // Campo de Nombre del Aparcamiento (mismo estilo que login)
        TextFormField(
          controller: _parkingNameController,
          decoration: InputDecoration(
            labelText: 'Nombre del estacionamiento',
            hintText: 'Mi Estacionamiento',
            prefixIcon: Icon(
              Icons.local_parking_outlined,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa el nombre del estacionamiento';
            }
            return null;
          },
          autocorrect: false,
          enableSuggestions: true,
          style: textTheme.bodyMedium,
        ),

        const SizedBox(height: 16),

        // Campo de Dirección con funcionalidad de mapa
        CustomAddressInput(
          addressController: _parkingAddressController,
          latitudeController: _latitudeController,
          longitudeController: _longitudeController,
          labelText: 'Dirección',
          hintText: 'Ingresa la dirección del estacionamiento',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa la dirección del estacionamiento';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Selector de modo de operación
        CustomOperationModeSelector(
          selectedMode: _operationMode,
          onModeChanged: (mode) {
            setState(() {
              _operationMode = mode;
            });
          },
          label: 'Modo de Operación',
        ),

        const SizedBox(height: 16),

        // Información adicional (estilo más sutil)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: colorScheme.onPrimaryContainer,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Podrás agregar más detalles después de crear el estacionamiento.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
