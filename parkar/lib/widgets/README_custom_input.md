# Widget CustomInputField - Documentación

## Descripción

El `CustomInputField` es un widget personalizado que proporciona campos de entrada consistentes en toda la aplicación, con soporte completo para caracteres especiales y acentos en español.

## Características

- ✅ **Soporte completo de caracteres especiales** (á, é, í, ó, ú, ñ, ü)
- ✅ **Diseño consistente** con el estilo por defecto de Material Design
- ✅ **Diseño consistente** con el tema de la aplicación
- ✅ **Validación integrada** con `CustomFormInputField`
- ✅ **Iconos prefijo y sufijo**
- ✅ **Diferentes tipos de teclado**
- ✅ **Campos de solo lectura** con callbacks personalizados
- ✅ **Autofocus** y navegación entre campos
- ✅ **Altura personalizable**
- ✅ **Capitalización de texto configurable**

## Configuración de Localización

La aplicación ahora incluye soporte completo para caracteres especiales en español:

### Archivos de Configuración

1. **`lib/config/localization_config.dart`** - Configuración central de localización
2. **`lib/main.dart`** - Configuración de la aplicación con delegados de localización
3. **`pubspec.yaml`** - Dependencia `flutter_localizations`

### Locales Soportados

- 🇪🇸 España (es-ES) - Por defecto
- 🇲🇽 México (es-MX)
- 🇦🇷 Argentina (es-AR)
- 🇨🇴 Colombia (es-CO)
- 🇵🇪 Perú (es-PE)
- 🇻🇪 Venezuela (es-VE)
- 🇨🇱 Chile (es-CL)
- 🇪🇨 Ecuador (es-EC)
- 🇬🇹 Guatemala (es-GT)
- 🇨🇺 Cuba (es-CU)
- 🇧🇴 Bolivia (es-BO)
- 🇩🇴 República Dominicana (es-DO)
- 🇭🇳 Honduras (es-HN)
- 🇵🇾 Paraguay (es-PY)
- 🇸🇻 El Salvador (es-SV)
- 🇳🇮 Nicaragua (es-NI)
- 🇨🇷 Costa Rica (es-CR)
- 🇵🇦 Panamá (es-PA)
- 🇺🇾 Uruguay (es-UY)
- 🇬🇶 Guinea Ecuatorial (es-GQ)
- 🇺🇸 Estados Unidos (en-US) - Fallback

## Uso del Widget

### Importación

```dart
import 'package:parkar/widgets/custom_input_field.dart';
```

### Ejemplo Básico

```dart
CustomInputField(
  controller: _nameController,
  labelText: 'Nombre completo',
  hintText: 'Ingresa tu nombre',
  prefixIcon: Icons.person,
  textCapitalization: TextCapitalization.words,
)
```

### Ejemplo con Validación

```dart
CustomFormInputField(
  controller: _emailController,
  labelText: 'Correo electrónico',
  hintText: 'ejemplo@correo.com',
  prefixIcon: Icons.email,
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Ingresa un email válido';
    }
    return null;
  },
)
```

### Ejemplo de Campo de Fecha (Solo Lectura)

```dart
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
        _dateController.text = '${date.day}/${date.month}/${date.year}';
      });
    }
  },
)
```

### Ejemplo de Campo de Contraseña

```dart
CustomInputField(
  controller: _passwordController,
  labelText: 'Contraseña',
  hintText: 'Ingresa tu contraseña',
  prefixIcon: Icons.lock,
  obscureText: true,
)
```

### Ejemplo de Campo Numérico

```dart
CustomInputField(
  controller: _ageController,
  labelText: 'Edad',
  hintText: '25',
  prefixIcon: Icons.numbers,
  keyboardType: TextInputType.number,
  suffixText: 'años',
)
```

### Ejemplo de Campo Multilínea

```dart
CustomInputField(
  controller: _descriptionController,
  labelText: 'Descripción',
  hintText: 'Escribe una descripción...',
  prefixIcon: Icons.description,
  maxLines: 3,
  height: 80,
)
```

## Parámetros Disponibles

### Parámetros Requeridos

- `controller` - Controlador del campo de texto
- `labelText` - Texto de la etiqueta

### Parámetros Opcionales

- `hintText` - Texto de sugerencia
- `prefixIcon` - Icono prefijo
- `suffixIcon` - Widget de sufijo
- `suffixText` - Texto de sufijo
- `keyboardType` - Tipo de teclado
- `obscureText` - Indica si es campo de contraseña (default: false)
- `readOnly` - Indica si es de solo lectura (default: false)
- `onTap` - Función a ejecutar al tocar el campo
- `onChanged` - Función a ejecutar cuando cambia el texto
- `onSubmitted` - Función a ejecutar al enviar el campo
- `textInputAction` - Acción del teclado
- `textCapitalization` - Capitalización del texto (default: TextCapitalization.none)
- `maxLines` - Número máximo de líneas (default: 1)
- `enabled` - Indica si el campo está habilitado (default: true)
- `height` - Altura del campo (default: 44)
- `isDense` - Indica si el campo es denso (default: true)
- `autofocus` - Indica si debe tener autofocus (default: false)
- `validator` - Función de validación (solo en CustomFormInputField)

## Migración de TextField Existentes

### Antes (TextField básico)

```dart
TextField(
  controller: _nameController,
  decoration: InputDecoration(
    labelText: 'Nombre',
    hintText: 'Juan Pérez',
    prefixIcon: Icon(Icons.person),
    border: OutlineInputBorder(),
  ),
)
```

### Después (CustomInputField)

```dart
CustomInputField(
  controller: _nameController,
  labelText: 'Nombre',
  hintText: 'Juan Pérez',
  prefixIcon: Icons.person,
  textCapitalization: TextCapitalization.words,
)
```

## Ventajas del Widget Personalizado

1. **Consistencia Visual** - Todos los campos tienen el mismo estilo
2. **Menos Código** - No necesitas repetir la configuración de InputDecoration
3. **Mantenimiento Fácil** - Cambios de estilo centralizados
4. **Soporte de Caracteres** - Acentos y caracteres especiales funcionan correctamente
5. **Validación Integrada** - Fácil implementación de validaciones
6. **Accesibilidad** - Mejor soporte para lectores de pantalla

## Solución de Problemas

### Caracteres Especiales No Se Muestran Correctamente

1. Verifica que el archivo esté guardado en UTF-8
2. Asegúrate de que `flutter_localizations` esté en `pubspec.yaml`
3. Confirma que los delegados de localización estén configurados en `main.dart`

### Validación No Funciona

- Usa `CustomFormInputField` en lugar de `CustomInputField`
- Asegúrate de que el campo esté dentro de un `Form`
- Llama a `Form.validate()` para ejecutar las validaciones

### Estilo No Se Aplica

- Verifica que el tema esté configurado correctamente
- Confirma que `Theme.of(context)` esté disponible
- Revisa que no haya estilos personalizados que sobrescriban el widget

## Ejemplos Completos

Ver el archivo `lib/widgets/custom_input_examples.dart` para ejemplos completos de uso en diferentes situaciones.
