import 'package:flutter/material.dart';

/// Widget de campo de entrada personalizado para usar en toda la aplicación
class CustomInputField extends StatelessWidget {
  /// Controlador del campo de texto
  final TextEditingController controller;

  /// Texto de la etiqueta
  final String labelText;

  /// Texto de sugerencia
  final String? hintText;

  /// Icono prefijo
  final IconData? prefixIcon;

  /// Tipo de teclado
  final TextInputType? keyboardType;

  /// Función de validación
  final String? Function(String?)? validator;

  /// Indica si el campo es de contraseña
  final bool obscureText;

  /// Indica si el campo es de solo lectura
  final bool readOnly;

  /// Función a ejecutar cuando se toca el campo (para campos de solo lectura)
  final VoidCallback? onTap;

  /// Función a ejecutar cuando cambia el texto
  final Function(String)? onChanged;

  /// Función a ejecutar cuando se envía el campo
  final VoidCallback? onSubmitted;

  /// Texto de acción del teclado
  final TextInputAction? textInputAction;

  /// Capitalización del texto
  final TextCapitalization textCapitalization;

  /// Número máximo de líneas
  final int? maxLines;

  /// Indica si el campo está habilitado
  final bool enabled;

  /// Texto de sufijo
  final String? suffixText;

  /// Widget de sufijo
  final Widget? suffixIcon;

  /// Altura del campo
  final double? height;

  /// Indica si el campo es denso
  final bool isDense;

  /// Indica si el campo debe tener autofocus
  final bool autofocus;

  /// Constructor
  const CustomInputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.enabled = true,
    this.suffixText,
    this.suffixIcon,
    this.height = 44,
    this.isDense = true,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        onSubmitted: (_) => onSubmitted?.call(),
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        maxLines: maxLines,
        enabled: enabled,
        autofocus: autofocus,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, size: 18, color: colorScheme.onSurfaceVariant)
              : null,
          suffixText: suffixText,
          suffixIcon: suffixIcon,
          isDense: isDense,
          // Estilo exacto como en register_stepper_screen.dart
          // Sin bordes personalizados - usa el estilo por defecto de Material Design
        ),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}

/// Widget de campo de entrada con validación (usando TextFormField)
class CustomFormInputField extends StatelessWidget {
  /// Controlador del campo de texto
  final TextEditingController controller;

  /// Texto de la etiqueta
  final String labelText;

  /// Texto de sugerencia
  final String? hintText;

  /// Icono prefijo
  final IconData? prefixIcon;

  /// Tipo de teclado
  final TextInputType? keyboardType;

  /// Función de validación
  final String? Function(String?)? validator;

  /// Indica si el campo es de contraseña
  final bool obscureText;

  /// Indica si el campo es de solo lectura
  final bool readOnly;

  /// Función a ejecutar cuando se toca el campo (para campos de solo lectura)
  final VoidCallback? onTap;

  /// Función a ejecutar cuando cambia el texto
  final Function(String)? onChanged;

  /// Función a ejecutar cuando se envía el campo
  final VoidCallback? onSubmitted;

  /// Texto de acción del teclado
  final TextInputAction? textInputAction;

  /// Capitalización del texto
  final TextCapitalization textCapitalization;

  /// Número máximo de líneas
  final int? maxLines;

  /// Indica si el campo está habilitado
  final bool enabled;

  /// Texto de sufijo
  final String? suffixText;

  /// Widget de sufijo
  final Widget? suffixIcon;

  /// Altura del campo
  final double? height;

  /// Indica si el campo es denso
  final bool isDense;

  /// Indica si el campo debe tener autofocus
  final bool autofocus;

  /// Constructor
  const CustomFormInputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.enabled = true,
    this.suffixText,
    this.suffixIcon,
    this.height = 44,
    this.isDense = true,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: height,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        onFieldSubmitted: (_) => onSubmitted?.call(),
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        maxLines: maxLines,
        enabled: enabled,
        validator: validator,
        autofocus: autofocus,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, size: 18, color: colorScheme.onSurfaceVariant)
              : null,
          suffixText: suffixText,
          suffixIcon: suffixIcon,
          isDense: isDense,
          // Estilo exacto como en register_stepper_screen.dart
          // Sin bordes personalizados - usa el estilo por defecto de Material Design
        ),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}
