import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parkar/models/parking_model.dart';
import '../core/parking_state.dart';
import '../models/enums.dart';

/// Panel superior reutilizable con información del estacionamiento
class ParkingInfoPanel extends StatelessWidget {
  final String parkingName;
  final String? currentAreaId;
  final List<AreaModel> areas;
  final Function(String) onAreaChanged;
  final Function(AreaModel) onEditAreaName;
  final Function() onAddArea;
  final bool showSearchField;
  final TextEditingController? searchController;
  final Function(String)? onSearchChanged;

  const ParkingInfoPanel({
    super.key,
    required this.parkingName,
    required this.currentAreaId,
    required this.areas,
    required this.onAreaChanged,
    required this.onEditAreaName,
    required this.onAddArea,
    this.showSearchField = false,
    this.searchController,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determinar si es móvil o tablet
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Calcular ancho máximo del contenedor
    final containerWidth = isMobile
        ? screenWidth
        : math.min(600.0, screenWidth);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : (screenWidth - containerWidth) / 2 + 8,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colorScheme.surface.withValues(alpha: 0.95)
            : colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Encabezado con nombre del estacionamiento y botones
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Información del parqueo
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.local_parking,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          parkingName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Botones de acción
                Consumer<ParkingState>(
                  builder: (context, state, _) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón de editar
                        Container(
                          decoration: BoxDecoration(
                            color: state.isEditMode
                                ? colorScheme.error.withValues(alpha: 0.1)
                                : colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: state.isEditMode
                                  ? colorScheme.error.withValues(alpha: 0.3)
                                  : colorScheme.primary.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                state.toggleEditMode();
                                if (state.isEditMode) {
                                  state.editorMode = EditorMode.free;
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  state.isEditMode
                                      ? Icons.close
                                      : Icons.edit_note,
                                  size: 18,
                                  color: state.isEditMode
                                      ? colorScheme.error
                                      : colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Botón de guardar (solo en modo edición)
                        if (state.isEditMode) ...[
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  // Aquí se llamaría a la función de actualizar
                                  state.isEditMode = false;
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 18,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Pestañas para seleccionar áreas (solo si hay más de un área)
          if (areas.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SizedBox(
                height: 30,
                child: Row(
                  children: [
                    Expanded(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: areas.map((area) {
                          final isSelected = currentAreaId == area.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: GestureDetector(
                              onTap: () async {
                                if (isSelected) {
                                  return; // No hacer nada si ya está seleccionada
                                }
                                onAreaChanged(area.id);
                              },
                              onLongPress: () {
                                // Mostrar diálogo para editar nombre del área solo en modo edición
                                final state = Provider.of<ParkingState>(
                                  context,
                                  listen: false,
                                );
                                if (state.isEditMode) {
                                  onEditAreaName(area);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? colorScheme.primary
                                        : colorScheme.outline.withValues(
                                            alpha: 0.3,
                                          ),
                                    width: 1,
                                  ),
                                ),
                                child: Consumer<ParkingState>(
                                  builder: (context, state, _) {
                                    return Row(
                                      children: [
                                        Text(
                                          area.name,
                                          style: TextStyle(
                                            color: isSelected
                                                ? colorScheme.onPrimary
                                                : colorScheme.onSurface
                                                      .withValues(alpha: 0.8),
                                            fontWeight: isSelected
                                                ? FontWeight.w500
                                                : FontWeight.normal,
                                            fontSize: 12,
                                          ),
                                        ),
                                        // Solo mostrar el botón de editar si está seleccionada y en modo edición
                                        if (isSelected && state.isEditMode) ...[
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () => onEditAreaName(area),
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: colorScheme.onPrimary
                                                    .withValues(alpha: 0.3),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.edit,
                                                size: 10,
                                                color: colorScheme.onPrimary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    // Botón para añadir nueva área - pegado a los tabs
                    Consumer<ParkingState>(
                      builder: (context, state, _) {
                        if (!state.isEditMode) return const SizedBox.shrink();

                        return GestureDetector(
                          onTap: onAddArea,
                          child: Container(
                            margin: EdgeInsets.zero,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.add,
                              size: 16,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

          // Campo de búsqueda (solo si se solicita)
          if (showSearchField &&
              searchController != null &&
              onSearchChanged != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar vehículo...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    suffixIcon: searchController!.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            onPressed: () {
                              searchController!.clear();
                              onSearchChanged!('');
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onChanged: onSearchChanged,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
