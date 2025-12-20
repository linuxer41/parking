import 'package:flutter/material.dart';
import 'custom_input_field.dart';

/// Ejemplos de uso del widget CustomInputField
class CustomInputExamples extends StatefulWidget {
  const CustomInputExamples({super.key});

  @override
  State<CustomInputExamples> createState() => _CustomInputExamplesState();
}

class _CustomInputExamplesState extends State<CustomInputExamples> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _multilineController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _dateController.dispose();
    _numberController.dispose();
    _multilineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejemplos de CustomInputField'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Campos de Entrada Personalizados',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),

            // Campo básico
            Text(
              'Campo Básico',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            CustomInputField(
              controller: _nameController,
              labelText: 'Nombre completo',
              hintText: 'Ingresa tu nombre',
              prefixIcon: Icons.person,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Campo de email
            Text(
              'Campo de Email',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            CustomInputField(
              controller: _emailController,
              labelText: 'Correo electrónico',
              hintText: 'ejemplo@correo.com',
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Campo de teléfono
            Text(
              'Campo de Teléfono',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            CustomInputField(
              controller: _phoneController,
              labelText: 'Número de teléfono',
              hintText: '300 123 4567',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Campo de contraseña
            Text(
              'Campo de Contraseña',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            CustomInputField(
              controller: _passwordController,
              labelText: 'Contraseña',
              hintText: 'Ingresa tu contraseña',
              prefixIcon: Icons.lock,
              obscureText: true,
            ),
            const SizedBox(height: 16),

            // Campo de fecha (solo lectura)
            Text(
              'Campo de Fecha (Solo Lectura)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            CustomInputField(
              controller: _dateController,
              labelText: 'Fecha de nacimiento',
              hintText: 'Seleccionar fecha',
              prefixIcon: Icons.calendar_today,
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _dateController.text =
                        '${date.day}/${date.month}/${date.year}';
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Campo numérico
            Text(
              'Campo Numérico',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            CustomInputField(
              controller: _numberController,
              labelText: 'Edad',
              hintText: '25',
              prefixIcon: Icons.numbers,
              keyboardType: TextInputType.number,
              suffixText: 'años',
            ),
            const SizedBox(height: 16),

            // Campo multilínea
            Text(
              'Campo Multilínea',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            CustomInputField(
              controller: _multilineController,
              labelText: 'Descripción',
              hintText: 'Escribe una descripción...',
              prefixIcon: Icons.description,
              maxLines: 3,
              height: 80,
            ),
            const SizedBox(height: 24),

            // Ejemplos con CustomFormInputField (con validación)
            Text(
              'Campos con Validación (CustomFormInputField)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Formulario con validación
            Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Formulario con Validación',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomFormInputField(
                    controller: _nameController,
                    labelText: 'Nombre (requerido)',
                    hintText: 'Ingresa tu nombre',
                    prefixIcon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El nombre es requerido';
                      }
                      if (value.length < 2) {
                        return 'El nombre debe tener al menos 2 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomFormInputField(
                    controller: _emailController,
                    labelText: 'Email (requerido)',
                    hintText: 'ejemplo@correo.com',
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El email es requerido';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Ingresa un email válido';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Botón para mostrar los valores
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Valores Ingresados'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nombre: ${_nameController.text}'),
                          Text('Email: ${_emailController.text}'),
                          Text('Teléfono: ${_phoneController.text}'),
                          Text('Fecha: ${_dateController.text}'),
                          Text('Número: ${_numberController.text}'),
                          Text('Descripción: ${_multilineController.text}'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cerrar'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Mostrar Valores'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
