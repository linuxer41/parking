import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parkar/services/user_service.dart';
import 'package:parkar/state/app_state_container.dart';

class SelectScreen extends StatelessWidget {
  const SelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = AppStateContainer.di(context).resolve<UserService>();
    final state = AppStateContainer.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Título
              Text(
                "Seleccionar estacionamiento",
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Descripción
              Text(
                'Tienes acceso a múltiples estacionamientos. Selecciona uno para continuar.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Lista de estacionamientos (ocupa el espacio disponible)
              Expanded(
                child: state.currentUser == null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.primary.withValues(
                                  alpha: 140,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Cargando información del usuario...',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : FutureBuilder(
                        future: userService.getParkings(state.currentUser!.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.primary.withValues(
                                    alpha: 140,
                                  ),
                                ),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer.withValues(
                                  alpha: 127,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: colorScheme.error,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Error: ${snapshot.error}',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.error,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 127),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.local_parking_rounded,
                                    color: colorScheme.onSurfaceVariant
                                        .withValues(alpha: 178),
                                    size: 36,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No hay estacionamientos disponibles',
                                    style: textTheme.titleSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          final parkings = snapshot.data!;
                          return ListView.builder(
                            itemCount: parkings.length,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              final parking = parkings[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: colorScheme.outline.withValues(
                                      alpha: 51,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: ListTile(
                                  title: Text(
                                    parking.name,
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Selecciona para ver detalles',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  leading: Icon(
                                    Icons.local_parking_rounded,
                                    color: colorScheme.primary,
                                  ),
                                  contentPadding: const EdgeInsets.all(16),
                                  onTap: () async {
                                    // Mostrar indicador de carga mientras se carga el parqueo
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => const Center(
                                        child: SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                    );

                                    try {
                                      // Establecer el estacionamiento detallado en el estado
                                      state.setCurrentParking(parking);

                                      if (context.mounted) {
                                        Navigator.of(
                                          context,
                                        ).pop(); // Cerrar diálogo
                                        context.go('/home');
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        Navigator.of(
                                          context,
                                        ).pop(); // Cerrar diálogo
                                      }

                                      // Mostrar error
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Error al cargar el estacionamiento: $e',
                                            ),
                                            backgroundColor: colorScheme.error,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),

              const SizedBox(height: 24),

              // Botón para cerrar sesión
              TextButton.icon(
                onPressed: () {
                  final state = AppStateContainer.of(context);
                  state.logout();
                  context.go('/login');
                },
                icon: Icon(
                  Icons.logout_rounded,
                  size: 16,
                  color: colorScheme.primary.withValues(alpha: 178),
                ),
                label: Text(
                  'Cerrar sesión',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
