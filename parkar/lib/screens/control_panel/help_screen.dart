import 'package:flutter/material.dart';
import 'responsive_detail_screen.dart';

/// Pantalla de ayuda con preguntas frecuentes y soporte
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  // Lista de preguntas frecuentes
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: '¿Cómo agrego un nuevo estacionamiento?',
      answer:
          'Para agregar un nuevo estacionamiento, ve a la sección "Estacionamientos" en el Centro de Control y presiona el botón + en la parte inferior derecha. Completa el formulario con la información requerida y presiona "Agregar".',
    ),
    FAQItem(
      question: '¿Cómo configuro las áreas de mi estacionamiento?',
      answer:
          'Primero debes tener un estacionamiento creado. Luego, selecciona el estacionamiento y presiona el botón "Áreas". Allí podrás agregar, editar o eliminar áreas según necesites.',
    ),
    FAQItem(
      question: '¿Cómo configuro las tarifas?',
      answer:
          'En la sección de estacionamientos, selecciona el estacionamiento deseado y presiona el botón "Tarifas". Podrás configurar tarifas diferentes para cada tipo de vehículo, con opciones por hora y por día.',
    ),
    FAQItem(
      question: '¿Puedo cambiar mi contraseña?',
      answer:
          'Sí, puedes cambiar tu contraseña en cualquier momento desde el Centro de Control. Ve a la sección "Cuenta" y selecciona "Cambiar contraseña".',
    ),
    FAQItem(
      question: '¿Cómo puedo recibir notificaciones?',
      answer:
          'Puedes configurar las notificaciones en el Centro de Control, en la sección "Cuenta". Selecciona "Notificaciones" y activa los tipos de alertas que deseas recibir.',
    ),
    FAQItem(
      question: '¿La aplicación funciona sin conexión a internet?',
      answer:
          'Algunas funciones básicas están disponibles sin conexión, pero para sincronizar datos, procesar pagos y recibir notificaciones en tiempo real, se requiere conexión a internet.',
    ),
    FAQItem(
      question: '¿Cómo contacto al soporte técnico?',
      answer:
          'Puedes contactar al soporte técnico a través del formulario en esta pantalla o enviando un correo a soporte@parkar.com. Nuestro equipo te responderá en un plazo máximo de 24 horas.',
    ),
  ];

  // Controladores para el formulario de contacto
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // Método para enviar el formulario de contacto
  void _sendSupportRequest() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    // Simulación de envío
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isSending = false;
          _subjectController.clear();
          _messageController.clear();
        });

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Tu mensaje ha sido enviado. Te responderemos pronto.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return ResponsiveDetailScreen(
      title: 'Ayuda y Soporte',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de preguntas frecuentes
            Text(
              'Preguntas Frecuentes',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Lista de preguntas frecuentes
            ..._faqItems.map((item) => _buildFAQItem(item, colorScheme)),

            const SizedBox(height: 32),

            // Sección de contacto
            Text(
              'Contacta con Soporte',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Formulario de contacto
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Si no encuentras respuesta a tu pregunta, envíanos un mensaje y te responderemos lo antes posible.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Campo de asunto
                      TextFormField(
                        controller: _subjectController,
                        decoration: InputDecoration(
                          labelText: 'Asunto',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.subject),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa un asunto';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Campo de mensaje
                      TextFormField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          labelText: 'Mensaje',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.message_outlined),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu mensaje';
                          }
                          if (value.length < 10) {
                            return 'Tu mensaje debe tener al menos 10 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Botón de enviar
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isSending ? null : _sendSupportRequest,
                          icon: _isSending
                              ? Container(
                                  width: 24,
                                  height: 24,
                                  padding: const EdgeInsets.all(2.0),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send),
                          label: Text(
                              _isSending ? 'Enviando...' : 'Enviar Mensaje'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Información de contacto adicional
            Card(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Información de Contacto',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildContactInfo(
                      Icons.email_outlined,
                      'Email',
                      'soporte@parkar.com',
                      colorScheme,
                    ),
                    const SizedBox(height: 12),
                    _buildContactInfo(
                      Icons.phone_outlined,
                      'Teléfono',
                      '+1 (555) 123-4567',
                      colorScheme,
                    ),
                    const SizedBox(height: 12),
                    _buildContactInfo(
                      Icons.access_time,
                      'Horario de Atención',
                      'Lunes a Viernes, 9:00 AM - 6:00 PM',
                      colorScheme,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para construir un elemento de FAQ
  Widget _buildFAQItem(FAQItem item, ColorScheme colorScheme) {
    return ExpansionTile(
      title: Text(
        item.question,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      leading: Icon(
        Icons.help_outline,
        color: colorScheme.primary,
      ),
      childrenPadding: const EdgeInsets.fromLTRB(48, 0, 16, 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.answer,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // Widget para construir información de contacto
  Widget _buildContactInfo(
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Clase para representar un elemento de preguntas frecuentes
class FAQItem {
  final String question;
  final String answer;

  FAQItem({
    required this.question,
    required this.answer,
  });
}
