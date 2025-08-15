import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parkar/state/app_state_container.dart';
import '../../widgets/auth/auth_layout.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AuthLayout(
      title: 'Bienvenido a Parkar',
      subtitle: 'Gestión inteligente de estacionamientos',
      children: [
        // Logo y descripción principal
        _buildMainHeroSection(colorScheme, textTheme),

        const SizedBox(height: 32),

        // Botones de acción principales
        _buildActionButtons(context, colorScheme, textTheme),

        const SizedBox(height: 24),

        // Características principales (simplificadas)
        _buildFeaturesSection(colorScheme, textTheme),

        const SizedBox(height: 24),

        // Información de contacto (simplificada)
        _buildContactSection(context, colorScheme, textTheme),
      ],
    );
  }

  Widget _buildMainHeroSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withValues(alpha: 80),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Logo principal
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.local_parking_rounded,
              size: 40,
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 20),
          // Título y descripción
          Text(
            'Parkar',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Controla tu estacionamiento desde cualquier lugar',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 90),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      children: [
        // Botón "Ya tengo cuenta"
        FilledButton(
          onPressed: () => context.go('/login'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 52),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login_rounded, size: 20, color: colorScheme.onPrimary),
              const SizedBox(width: 12),
              Text(
                'Ya tengo cuenta',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Botón "Registrar mi estacionamiento"
        OutlinedButton(
          onPressed: () => context.go('/register'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(color: colorScheme.primary, width: 2),
            minimumSize: const Size(double.infinity, 52),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_business_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Registrar mi estacionamiento',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 20)),
      ),
      child: Column(
        children: [
          Text(
            '¿Por qué elegir Parkar?',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          // Características en lista simple
          _buildFeatureItem(
            Icons.dashboard_rounded,
            'Control total',
            'Gestiona tu estacionamiento desde cualquier lugar',
            colorScheme,
            textTheme,
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            Icons.access_time_rounded,
            '24/7 disponible',
            'Acceso a tu información en cualquier momento',
            colorScheme,
            textTheme,
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            Icons.touch_app_rounded,
            'Fácil de usar',
            'Interfaz intuitiva y moderna',
            colorScheme,
            textTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String title,
    String description,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                description,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 20)),
      ),
      child: Column(
        children: [
          // Título
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.support_agent_rounded,
                color: colorScheme.onTertiaryContainer,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '¿Necesitas ayuda?',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onTertiaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Información de contacto simplificada
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone_rounded,
                size: 20,
                color: colorScheme.onTertiaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                '+591 7543450',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Botón de WhatsApp simplificado
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                final phoneNumber = '+5917543450';
                final message = 'Hola, necesito soporte con Parkar.';

                try {
                  final whatsappUrl =
                      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
                  final uri = Uri.parse(whatsappUrl);

                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    // Fallback a teléfono
                    final phoneUri = Uri.parse('tel:$phoneNumber');
                    if (await canLaunchUrl(phoneUri)) {
                      await launchUrl(
                        phoneUri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Error al abrir WhatsApp'),
                        backgroundColor: colorScheme.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              icon: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'W',
                    style: TextStyle(
                      color: Color(0xFF25D366),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              label: const Text('Contactar por WhatsApp'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
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
}
