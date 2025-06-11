import 'package:flutter/material.dart';
import 'responsive_detail_screen.dart';

/// Pantalla de información sobre la aplicación
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return ResponsiveDetailScreen(
      title: 'Acerca de',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),

            // Logo de la aplicación
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.7),
                    colorScheme.primary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.local_parking,
                  size: 60,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Nombre de la aplicación
            Text(
              'ParKar',
              style: textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),

            Text(
              'Versión 1.0.0',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 32),

            // Descripción de la aplicación
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'ParKar es una aplicación integral para la gestión de estacionamientos que permite a los administradores configurar áreas, tarifas y monitorear la ocupación en tiempo real.',
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 40),

            // Secciones informativas
            _buildInfoSection(
              context,
              'Desarrollado por',
              'ParKar Team',
              Icons.code,
              colorScheme,
            ),

            _buildInfoSection(
              context,
              'Contacto',
              'info@parkar.com',
              Icons.email_outlined,
              colorScheme,
            ),

            _buildInfoSection(
              context,
              'Sitio Web',
              'www.parkar.com',
              Icons.language,
              colorScheme,
            ),

            const SizedBox(height: 32),

            // Sección de licencias
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                            'Información Legal',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Botones de información legal
                      _buildLegalButton(
                        'Términos y Condiciones',
                        Icons.description_outlined,
                        colorScheme,
                        onTap: () {
                          _showLegalDialog(
                            context,
                            'Términos y Condiciones',
                            _getTermsAndConditions(),
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      _buildLegalButton(
                        'Política de Privacidad',
                        Icons.privacy_tip_outlined,
                        colorScheme,
                        onTap: () {
                          _showLegalDialog(
                            context,
                            'Política de Privacidad',
                            _getPrivacyPolicy(),
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      _buildLegalButton(
                        'Licencias de Software',
                        Icons.source_outlined,
                        colorScheme,
                        onTap: () {
                          showLicensePage(
                            context: context,
                            applicationName: 'ParKar',
                            applicationVersion: '1.0.0',
                            applicationIcon: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.local_parking,
                                size: 40,
                                color: colorScheme.primary,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Copyright
            Text(
              '© ${DateTime.now().year} ParKar. Todos los derechos reservados.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Widget para construir una sección de información
  Widget _buildInfoSection(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget para construir un botón de información legal
  Widget _buildLegalButton(
    String title,
    IconData icon,
    ColorScheme colorScheme, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // Método para mostrar diálogo con información legal
  void _showLegalDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(content),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // Texto de ejemplo para términos y condiciones
  String _getTermsAndConditions() {
    return '''
TÉRMINOS Y CONDICIONES

Última actualización: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}

1. ACEPTACIÓN DE LOS TÉRMINOS

Al acceder y utilizar la aplicación ParKar, usted acepta estar sujeto a estos Términos y Condiciones y a nuestra Política de Privacidad. Si no está de acuerdo con alguno de estos términos, no debe utilizar nuestra aplicación.

2. USO DE LA APLICACIÓN

ParKar proporciona una plataforma para la gestión de estacionamientos. Usted se compromete a utilizar la aplicación solo para fines legales y de acuerdo con estos términos.

3. CUENTAS DE USUARIO

Para utilizar ciertas funciones de la aplicación, es posible que deba registrarse y crear una cuenta. Usted es responsable de mantener la confidencialidad de su información de cuenta y contraseña.

4. PROPIEDAD INTELECTUAL

Todo el contenido incluido en ParKar, como texto, gráficos, logotipos, iconos, imágenes, clips de audio, descargas digitales y compilaciones de datos, es propiedad de ParKar o sus proveedores de contenido y está protegido por las leyes de propiedad intelectual.

5. LIMITACIÓN DE RESPONSABILIDAD

ParKar no será responsable por daños indirectos, incidentales, especiales, consecuentes o punitivos, o cualquier pérdida de beneficios o ingresos.

6. MODIFICACIONES

Nos reservamos el derecho de modificar estos términos en cualquier momento. Es su responsabilidad revisar periódicamente estos términos para estar al tanto de las actualizaciones.

7. LEY APLICABLE

Estos términos se regirán e interpretarán de acuerdo con las leyes del país donde ParKar tiene su sede principal, sin dar efecto a ningún principio de conflicto de leyes.
''';
  }

  // Texto de ejemplo para política de privacidad
  String _getPrivacyPolicy() {
    return '''
POLÍTICA DE PRIVACIDAD

Última actualización: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}

1. INFORMACIÓN QUE RECOPILAMOS

Recopilamos información que usted proporciona directamente, como su nombre, dirección de correo electrónico, número de teléfono y datos de pago cuando se registra o utiliza nuestros servicios.

2. USO DE LA INFORMACIÓN

Utilizamos la información recopilada para:
- Proporcionar, mantener y mejorar nuestros servicios
- Procesar transacciones y enviar notificaciones relacionadas
- Enviar comunicaciones técnicas, actualizaciones y mensajes promocionales
- Detectar, prevenir y abordar problemas técnicos y de seguridad

3. COMPARTIR INFORMACIÓN

No vendemos su información personal a terceros. Podemos compartir información con:
- Proveedores de servicios que nos ayudan a operar nuestra aplicación
- Autoridades legales cuando sea requerido por ley
- Socios comerciales con su consentimiento explícito

4. SEGURIDAD DE DATOS

Implementamos medidas de seguridad diseñadas para proteger su información personal, pero ningún método de transmisión por Internet es 100% seguro.

5. SUS DERECHOS

Dependiendo de su ubicación, puede tener derechos relacionados con sus datos personales, como el derecho de acceso, rectificación, eliminación y portabilidad.

6. CAMBIOS A ESTA POLÍTICA

Podemos actualizar nuestra Política de Privacidad ocasionalmente. Le notificaremos cualquier cambio publicando la nueva Política de Privacidad en esta página.

7. CONTACTO

Si tiene preguntas sobre esta Política de Privacidad, contáctenos en: privacy@parkar.com
''';
  }
}
