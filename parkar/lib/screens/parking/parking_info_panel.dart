import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parkar/models/cash_register_model.dart';
import 'package:parkar/models/parking_model.dart';

class ParkingInfoPanel extends StatelessWidget {
  final Function(String) onAreaChanged;
  final TextEditingController? searchController;
  final Function(String)? onSearchChanged;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onCashPressed;
  final ParkingDetailedModel parking;
  final CashRegisterModel? cashRegister;
  final String selectedAreaId;

  const ParkingInfoPanel({
    super.key,
    required this.onAreaChanged,
    required this.parking,
    required this.selectedAreaId,
    this.cashRegister,
    this.searchController,
    this.onSearchChanged,
    this.onSettingsPressed,
    this.onCashPressed,
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
                          parking.name,
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
                // Botones de configuración y caja
                Row(
                  children: [
                    if (onSettingsPressed != null)
                      IconButton(
                        onPressed: onSettingsPressed,
                        icon: Icon(Icons.settings, size: 20),
                        tooltip: 'Configuraciones',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    if (onCashPressed != null)
                      GestureDetector(
                        onTap: onCashPressed,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                cashRegister != null
                                    ? 'Caja: ${cashRegister!.totalAmount.toStringAsFixed(2)} Bs.'
                                    : 'Caja no abierta',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Pestañas para seleccionar áreas (solo si hay más de un área)
          if (parking.areas.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SizedBox(
                height: 30,
                child: Row(
                  children: [
                    Expanded(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: parking.areas.map((area) {
                          final isSelected = selectedAreaId == area.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: GestureDetector(
                              onTap: () async {
                                if (isSelected) {
                                  return; // No hacer nada si ya está seleccionada
                                }
                                onAreaChanged(area.id);
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
                                child: Row(
                                  children: [
                                    Text(
                                      area.name,
                                      style: TextStyle(
                                        color: isSelected
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSurface.withValues(
                                                alpha: 0.8,
                                              ),
                                        fontWeight: isSelected
                                            ? FontWeight.w500
                                            : FontWeight.normal,

                                        fontSize: 12,
                                      ),
                                    ),
                                    // Solo mostrar el botón de editar si está seleccionada y en modo edición
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SizedBox(
              height: 44,
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Buscar vehículo',
                  hintText: 'ABC-123',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.directions_car, size: 16),
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
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9\-]')),
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: onSearchChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
