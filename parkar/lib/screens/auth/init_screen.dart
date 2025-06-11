import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parkar/services/parking_service.dart';
import 'package:parkar/services/user_service.dart';
import 'package:parkar/state/app_state_container.dart';
import '../../widgets/auth/auth_layout.dart';

class InitScreen extends StatelessWidget {
  const InitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = AppStateContainer.di(context).resolve<UserService>();
    final parkingService =
        AppStateContainer.di(context).resolve<ParkingService>();
    final state = AppStateContainer.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AuthLayout(
      title: "Seleccionar empresa",
      children: [
        Text(
          'Selecciona la empresa y el estacionamiento donde trabajarás',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 280), // Altura máxima
          child: FutureBuilder(
            future: userService.getCompanies(state.user!.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, color: colorScheme.error),
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
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.business_outlined,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                          size: 36),
                      const SizedBox(height: 8),
                      Text(
                        'No hay empresas disponibles',
                        style: textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final companies = snapshot.data!;
              return ListView.builder(
                itemCount: companies.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  final company = companies[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: colorScheme.outline.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        title: Text(
                          company.name,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        iconColor: colorScheme.primary,
                        collapsedIconColor: colorScheme.onSurfaceVariant,
                        tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        childrenPadding:
                            const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                        children: company.parkings.map((parking) {
                          return ListTile(
                            title: Text(
                              parking.name,
                              style: textTheme.bodyMedium,
                            ),
                            leading: Icon(
                              Icons.local_parking_rounded,
                              size: 18,
                              color: colorScheme.primary,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            dense: true,
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
                                // Seleccionar el parqueo
                                final detailedParking = await parkingService
                                    .getDetailed(parking.id);
                                if (context.mounted) {
                                  Navigator.of(context).pop(); // Cerrar diálogo
                                }

                                state.setCompany(company);
                                state.setParking(detailedParking);
                                state.setLevel(detailedParking.levels.first);

                                if (context.mounted) context.go('/home');
                              } catch (e) {
                                if (context.mounted) {
                                  Navigator.of(context).pop(); // Cerrar diálogo
                                }

                                // Mostrar error
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Error al cargar el estacionamiento: $e'),
                                      backgroundColor: colorScheme.error,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        const SizedBox(height: 16),

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
            color: colorScheme.primary,
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
      ],
    );
  }
}
