import 'package:flutter/material.dart';
import 'responsive_detail_screen.dart';

/// Modelo para representar un idioma disponible
class Language {
  final String code;
  final String name;
  final String localName;
  final String flagEmoji;

  Language({
    required this.code,
    required this.name,
    required this.localName,
    required this.flagEmoji,
  });
}

/// Pantalla para configurar el idioma de la aplicación
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  // Lista de idiomas disponibles
  final List<Language> _languages = [
    Language(
      code: 'es',
      name: 'Spanish',
      localName: 'Español',
      flagEmoji: '🇪🇸',
    ),
    Language(
      code: 'en',
      name: 'English',
      localName: 'English',
      flagEmoji: '🇺🇸',
    ),
    Language(
      code: 'pt',
      name: 'Portuguese',
      localName: 'Português',
      flagEmoji: '🇧🇷',
    ),
    Language(
      code: 'fr',
      name: 'French',
      localName: 'Français',
      flagEmoji: '🇫🇷',
    ),
    Language(
      code: 'de',
      name: 'German',
      localName: 'Deutsch',
      flagEmoji: '🇩🇪',
    ),
    Language(
      code: 'it',
      name: 'Italian',
      localName: 'Italiano',
      flagEmoji: '🇮🇹',
    ),
  ];

  // Idioma seleccionado actualmente (por defecto español)
  String _selectedLanguageCode = 'es';
  bool _isChanging = false;

  // Método para cambiar el idioma
  void _changeLanguage(String languageCode) {
    if (_selectedLanguageCode == languageCode) return;

    setState(() {
      _isChanging = true;
    });

    // Simulación de cambio de idioma
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _selectedLanguageCode = languageCode;
          _isChanging = false;
        });

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Idioma cambiado a ${_getLanguageName(languageCode)}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  // Obtener el nombre del idioma a partir del código
  String _getLanguageName(String code) {
    final language = _languages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => _languages.first,
    );
    return language.localName;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return ResponsiveDetailScreen(
      title: 'Idioma',
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Selecciona tu idioma preferido',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              // Lista de idiomas
              Expanded(
                child: ListView.builder(
                  itemCount: _languages.length,
                  itemBuilder: (context, index) {
                    final language = _languages[index];
                    final isSelected = language.code == _selectedLanguageCode;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      elevation: 0,
                      color: isSelected
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerLowest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.outline.withOpacity(0.2),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => _changeLanguage(language.code),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              // Bandera del idioma
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colorScheme.outline.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    language.flagEmoji,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Información del idioma
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      language.localName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? colorScheme.onPrimaryContainer
                                            : colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      language.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isSelected
                                            ? colorScheme.onPrimaryContainer
                                                .withOpacity(0.8)
                                            : colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Indicador de selección
                              if (isSelected)
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    size: 16,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Nota informativa
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'El cambio de idioma se aplicará a toda la aplicación. Algunas secciones pueden mantener el idioma anterior hasta que reinicies la aplicación.',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Indicador de carga
          if (_isChanging)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
