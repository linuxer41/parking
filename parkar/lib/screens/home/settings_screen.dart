import 'package:flutter/material.dart';
import '../../state/app_state_container.dart';
import '../../state/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppTheme _appTheme;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // No inicializar _appTheme aquí para evitar errores
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inicializar el tema aquí es seguro porque didChangeDependencies se llama después de initState
    // y también cada vez que cambian las dependencias (incluyendo InheritedWidgets)
    if (!_initialized) {
      final appState = AppStateContainer.of(context);
      _appTheme = appState.theme ?? AppTheme();
      _appTheme.addListener(_handleThemeChange);
      _initialized = true;
    }
  }
  
  @override
  void dispose() {
    // Eliminar listener cuando se destruye el widget
    if (_initialized) {
      _appTheme.removeListener(_handleThemeChange);
    }
    super.dispose();
  }
  
  // Manejar cambios en el tema
  void _handleThemeChange() {
    if (mounted) {
      setState(() {
        // Actualizar la UI cuando cambia el tema
      });
    }
  }
  
  // Método para aplicar cambios de tema
  void _applyThemeChange() {
    final appState = AppStateContainer.of(context);
    
    // Importante: notificar al AppState del cambio
    appState.setTheme(_appTheme);
    
    // Guardar explícitamente las preferencias
    _appTheme.savePreferencesNow();
    
    // Mostrar mensaje de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración actualizada'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección de apariencia
          _buildSectionHeader(
            'Apariencia',
            Icons.palette_outlined,
            colorScheme,
            textTheme,
          ),
          const SizedBox(height: 8),
          _buildThemeSelector(colorScheme),
          const SizedBox(height: 16),
          
          // Sección de accesibilidad
          _buildSectionHeader(
            'Accesibilidad',
            Icons.accessibility_new_outlined,
            colorScheme,
            textTheme,
          ),
          const SizedBox(height: 8),
          _buildTextSizeControls(colorScheme),
          const SizedBox(height: 16),
          _buildAccessibilityToggles(colorScheme),
          const SizedBox(height: 24),
          
          // Sección de idioma
          _buildSectionHeader(
            'Idioma',
            Icons.language_outlined,
            colorScheme,
            textTheme,
          ),
          const SizedBox(height: 8),
          _buildLanguageSelector(colorScheme),
          
          // Botón para aplicar cambios
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton.icon(
              onPressed: _applyThemeChange,
              icon: const Icon(Icons.save),
              label: const Text('Aplicar cambios'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Row(
      children: [
        Icon(icon, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSelector(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tema',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode),
                  label: Text('Claro'),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode),
                  label: Text('Oscuro'),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto),
                  label: Text('Sistema'),
                ),
              ],
              selected: <ThemeMode>{_appTheme.mode},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                setState(() {
                  _appTheme.mode = newSelection.first;
                  _applyThemeChange();
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Color primario',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildColorOption(Colors.blue),
                _buildColorOption(Colors.green),
                _buildColorOption(Colors.purple),
                _buildColorOption(Colors.orange),
                _buildColorOption(Colors.red),
                _buildColorOption(Colors.teal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color) {
    final isSelected = _appTheme.color.value == color.value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _appTheme.color = color;
          _applyThemeChange();
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                color: Colors.white,
              )
            : null,
      ),
    );
  }

  Widget _buildTextSizeControls(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tamaño del texto',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _appTheme.decreaseTextSize();
                      _applyThemeChange();
                    });
                  },
                  icon: const Icon(Icons.remove),
                  tooltip: 'Reducir tamaño de texto',
                ),
                Expanded(
                  child: Slider(
                    value: _appTheme.textScaleFactor,
                    min: 0.8,
                    max: 1.5,
                    divisions: 7,
                    label: '${(_appTheme.textScaleFactor * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _appTheme.textScaleFactor = value;
                        _applyThemeChange();
                      });
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _appTheme.increaseTextSize();
                      _applyThemeChange();
                    });
                  },
                  icon: const Icon(Icons.add),
                  tooltip: 'Aumentar tamaño de texto',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Ejemplo de texto',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessibilityToggles(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Opciones de accesibilidad',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Alto contraste'),
              subtitle: const Text('Mejora la visibilidad de los elementos'),
              value: _appTheme.highContrast,
              onChanged: (value) {
                setState(() {
                  _appTheme.highContrast = value;
                  _applyThemeChange();
                });
              },
              secondary: Icon(
                Icons.contrast,
                color: colorScheme.primary,
              ),
            ),
            SwitchListTile(
              title: const Text('Reducir animaciones'),
              subtitle: const Text('Minimiza los efectos visuales'),
              value: _appTheme.reduceAnimations,
              onChanged: (value) {
                setState(() {
                  _appTheme.reduceAnimations = value;
                  _applyThemeChange();
                });
              },
              secondary: Icon(
                Icons.animation,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seleccionar idioma',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: const Text('Español'),
              value: 'es',
              groupValue: _appTheme.locale?.languageCode ?? 'es',
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _appTheme.locale = const Locale('es');
                    _applyThemeChange();
                  });
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _appTheme.locale?.languageCode ?? 'es',
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _appTheme.locale = const Locale('en');
                    _applyThemeChange();
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
} 