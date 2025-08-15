import 'package:flutter/material.dart';

class CustomCapacityInput extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? suffixText;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;

  const CustomCapacityInput({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.suffixText,
    this.validator,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText ?? 'Capacidad',
        hintText: hintText ?? 'Ej: 100',
        prefixIcon: Icon(
          Icons.directions_car_outlined,
          size: 18,
          color: colorScheme.onSurfaceVariant,
        ),
        suffixText: suffixText ?? 'vehículos',
      ),
      keyboardType: TextInputType.number,
      textInputAction: textInputAction ?? TextInputAction.next,
      validator: validator ?? _defaultValidator,
      onFieldSubmitted: (_) => onSubmitted?.call(),
      autocorrect: false,
      enableSuggestions: false,
      style: textTheme.bodyMedium,
    );
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa la capacidad';
    }
    final capacity = int.tryParse(value);
    if (capacity == null || capacity <= 0) {
      return 'Por favor ingresa un número válido';
    }
    return null;
  }
}
