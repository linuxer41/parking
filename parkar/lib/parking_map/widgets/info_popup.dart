import 'package:flutter/material.dart';
import '../models/parking_spot.dart';

class SpotInfoPopup extends StatelessWidget {
  final ParkingSpot spot;
  final Offset position;
  
  const SpotInfoPopup({
    super.key,
    required this.spot,
    required this.position,
  });
  
  @override
  Widget build(BuildContext context) {
    // Obtener el tamaño de la pantalla para evitar que el tooltip se salga
    final screenSize = MediaQuery.of(context).size;
    
    // Calcular la posición base del tooltip (siempre a la derecha del spot)
    // Usar un offset fijo para mayor consistencia
    double left = position.dx + 15;
    double top = position.dy - 100; // Colocar arriba del spot
    
    // Estimar el tamaño del tooltip (aproximado)
    const tooltipWidth = 250.0;
    const tooltipHeight = 200.0;
    
    // Ajustar la posición si se sale por la derecha
    if (left + tooltipWidth > screenSize.width) {
      left = position.dx - tooltipWidth - 15; // Colocar a la izquierda del spot
    }
    
    // Ajustar la posición si se sale por arriba
    if (top < 0) {
      top = 10; // Mantener un pequeño margen superior
    }
    
    // Ajustar la posición si se sale por abajo
    if (top + tooltipHeight > screenSize.height) {
      top = screenSize.height - tooltipHeight - 10; // Mantener un pequeño margen inferior
    }
    
    return Positioned(
      left: left,
      top: top,
      child: Material(
        elevation: 6,
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        child: _buildSpotTooltip(spot),
      ),
    );
  }
  
  // Construye el tooltip para mostrar información del spot
  Widget _buildSpotTooltip(ParkingSpot spot) {
    // Obtener la información necesaria según el tipo de ocupación
    String? vehiclePlate;
    String? vehicleType;
    String? vehicleColor;
    String? ownerName;
    String? status;
    String? time;
    String? startDate;
    String? endDate;
    IconData? statusIcon;
    Color statusColor = Colors.grey;

    status = _getStatusText(spot.status);
    statusIcon = _getStatusIcon(spot.status);
    statusColor = _getStatusColor(spot.status);

    if (spot.status == 'occupied' && spot.entry != null) {
      vehiclePlate = spot.entry!.vehiclePlate;
      vehicleType = 'Vehículo'; // Default type
      vehicleColor = null;
      ownerName = spot.entry!.ownerName;
      time = spot.formattedParkingTime;
      startDate = _formatDate(spot.entry!.startDate);
    } else if (spot.status == 'reserved' && spot.booking != null) {
      vehiclePlate = spot.booking!.vehiclePlate;
      vehicleType = 'Vehículo'; // Default type
      vehicleColor = null;
      ownerName = spot.booking!.ownerName;
      startDate = _formatDate(spot.booking!.startDate);
      endDate = spot.booking!.endDate != null ?
               _formatDate(spot.booking!.endDate!) : 'Sin fin';
    } else if (spot.status == 'subscribed' && spot.subscription != null) {
      vehiclePlate = spot.subscription!.vehiclePlate;
      vehicleType = 'Vehículo'; // Default type
      vehicleColor = null;
      ownerName = spot.subscription!.ownerName;
      startDate = _formatDate(spot.subscription!.startDate);
      endDate = spot.subscription!.endDate != null ?
               _formatDate(spot.subscription!.endDate!) : 'Sin fin';
    }
    
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título con número de espacio
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon ?? Icons.help_outline, color: statusColor, size: 16),
              const SizedBox(width: 8),
              Text(
                'Espacio ${spot.label}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Estado
          RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Estado: ',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: status ?? 'Desconocido',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Información del vehículo
          if (vehiclePlate != null) ...[
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Placa: ',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: vehiclePlate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Tipo de vehículo
          if (vehicleType != null) ...[
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Tipo: ',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: vehicleType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Color del vehículo
          if (vehicleColor != null) ...[
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Color: ',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: vehicleColor,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Propietario
          if (ownerName != null) ...[
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Propietario: ',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: ownerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Tiempo de ocupación para spots ocupados
          if (time != null) ...[
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Tiempo: ',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: time,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Fecha de inicio para todos los tipos
          if (startDate != null) ...[
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Desde: ',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: startDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Fecha de fin para reservados y suscritos
          if (endDate != null) ...[
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Hasta: ',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: endDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  /// Helper method to format a date string to a more user-friendly format
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
  
  /// Helper method to get the appropriate color for a spot status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'occupied':
        return Colors.red;
      case 'reserved':
        return Colors.orange;
      case 'subscribed':
        return Colors.green;
      case 'maintenance':
        return Colors.purple;
      case 'inactive':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  /// Helper method to get the appropriate icon for a spot status
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'occupied':
        return Icons.car_rental;
      case 'reserved':
        return Icons.bookmark;
      case 'subscribed':
        return Icons.card_membership;
      case 'maintenance':
        return Icons.build;
      case 'inactive':
        return Icons.do_not_disturb_on;
      default:
        return Icons.check_circle;
    }
  }

  /// Helper method to get the appropriate text for a spot status
  String _getStatusText(String status) {
    switch (status) {
      case 'occupied':
        return "OCUPADO";
      case 'reserved':
        return "RESERVADO";
      case 'subscribed':
        return "SUSCRITO";
      case 'maintenance':
        return "MANTENIMIENTO";
      case 'inactive':
        return "INACTIVO";
      default:
        return "DISPONIBLE";
    }
  }
} 