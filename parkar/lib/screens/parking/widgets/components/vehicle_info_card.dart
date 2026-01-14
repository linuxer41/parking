import 'package:flutter/material.dart';
import 'package:parkar/constants/constants.dart';
import '../../../../models/vehicle_model.dart';
import 'info_components.dart';

/// Componente para mostrar la información del vehículo de manera estandarizada
class VehicleInfoCard extends StatelessWidget {
  /// Modelo del vehículo a mostrar
  final VehiclePreviewModel vehicle;

  const VehicleInfoCard({
    super.key,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    return InfoSection(
      title: 'Información del Vehículo',
      icon: Icons.directions_car,
      children: [
        // Placa, color y tipo en 3 columnas
        ThreeColumnRow(
          labels: const ['Placa', 'Color', 'Tipo'],
          values: [
            vehicle.plate.toUpperCase(),
            vehicle.color ?? 'No especificado',
            getVehicleCategoryLabel(vehicle.type)
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Nombre del propietario en una columna
        if (vehicle.ownerName != null)
          InfoRow(label: 'Propietario', value: vehicle.ownerName!),
        
        const SizedBox(height: 4),
        
        // Teléfono y documento en 2 columnas
        TwoColumnRow(
          labels: const ['Teléfono', 'Documento'],
          values: [
            vehicle.ownerPhone ?? 'No especificado',
            vehicle.ownerDocument ?? 'No especificado'
          ],
        ),
      ],
    );
  }
} 