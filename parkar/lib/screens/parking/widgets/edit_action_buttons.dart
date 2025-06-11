import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/parking_state.dart';
import '../../../services/parking_api_service.dart';

/// Widget que muestra los botones de guardar y cancelar en la parte superior derecha
class EditActionButtons extends StatelessWidget {
  final VoidCallback? onSaveChanges;
  final VoidCallback? onCancelChanges;

  const EditActionButtons({
    super.key,
    this.onSaveChanges,
    this.onCancelChanges,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final parkingState = Provider.of<ParkingState>(context);
    final apiService = ParkingApiService();

    // Determinar si es móvil o tablet
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Usar colores completamente sólidos
    final backgroundColor = theme.brightness == Brightness.dark
        ? Colors.grey[850]! // Color oscuro sólido
        : Colors.white; // Color claro sólido

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón de guardar
            _buildActionButton(
              context: context,
              icon: Icons.save_rounded,
              label: 'Guardar',
              color: colorScheme.primary,
              onTap: () async {
                // Mostrar indicador de carga
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Guardando cambios...'),
                    duration: Duration(seconds: 1),
                  ),
                );

                // Simular llamada a API
                await Future.delayed(const Duration(milliseconds: 800));

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cambios guardados correctamente'),
                    duration: Duration(seconds: 2),
                  ),
                );

                // Salir del modo edición
                if (onSaveChanges != null) {
                  onSaveChanges!();
                }
              },
            ),

            const SizedBox(width: 8),

            // Botón de cancelar
            _buildActionButton(
              context: context,
              icon: Icons.close_rounded,
              label: 'Cancelar',
              color: colorScheme.error,
              onTap: () async {
                // Mostrar indicador de carga
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cancelando cambios...'),
                    duration: Duration(seconds: 1),
                  ),
                );

                // Simular recarga de datos
                await Future.delayed(const Duration(milliseconds: 800));

                // Limpiar todo el estado para volver al punto inicial
                parkingState.clear();

                // Recargar los datos desde la API
                await apiService.loadParkingData();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cambios descartados'),
                    duration: Duration(seconds: 2),
                  ),
                );

                // Salir del modo edición sin guardar
                if (onCancelChanges != null) {
                  onCancelChanges!();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    // Diseño minimalista sin fondo
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
