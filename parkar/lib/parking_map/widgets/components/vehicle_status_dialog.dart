import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/vehicle_model.dart';

/// Diálogo para mostrar el estado de un vehículo
class VehicleStatusDialog extends StatelessWidget {
  /// Datos del vehículo
  final VehicleModel vehicle;
  
  /// Placa del vehículo
  final String plate;
  
  /// Función a ejecutar cuando se selecciona continuar con el registro
  final VoidCallback onContinue;
  
  /// Constructor
  const VehicleStatusDialog({
    super.key,
    required this.vehicle,
    required this.plate,
    required this.onContinue,
  });
  
  /// Mostrar el diálogo
  static Future<bool?> show({
    required BuildContext context,
    required VehicleModel vehicle,
    required String plate,
    required VoidCallback onContinue,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => VehicleStatusDialog(
        vehicle: vehicle,
        plate: plate,
        onContinue: onContinue,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final hasActiveAccess = vehicle.access != null;
    final hasReservation = vehicle.reservation != null;
    final hasSubscription = vehicle.subscription != null;
    
    // Determinar título y color según el estado
    String title;
    Color headerColor;
    IconData headerIcon;
    
    if (hasActiveAccess) {
      title = 'Vehículo con Entrada Activa';
      headerColor = Colors.red;
      headerIcon = Icons.warning_rounded;
    } else if (hasReservation) {
      title = 'Vehículo con Reserva';
      headerColor = Colors.orange;
      headerIcon = Icons.event_available;
    } else if (hasSubscription) {
      title = 'Vehículo con Suscripción';
      headerColor = Colors.green;
      headerIcon = Icons.card_membership;
    } else {
      title = 'Información del Vehículo';
      headerColor = Colors.blue;
      headerIcon = Icons.info_outline;
    }
    
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Encabezado
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(headerIcon, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Placa: $plate',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenido
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mostrar información según el tipo de estado
                  if (hasActiveAccess) _buildAccessInfo(context),
                  if (hasReservation) _buildReservationInfo(context),
                  if (hasSubscription) _buildSubscriptionInfo(context),
                  
                  const SizedBox(height: 24),
                  
                  // Mensaje informativo
                  _buildInfoMessage(context),
                ],
              ),
            ),
            
            // Botones
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Botón para cancelar
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Botón para continuar
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      onContinue();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Continuar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Construye la información de acceso activo
  Widget _buildAccessInfo(BuildContext context) {
    final access = vehicle.access;
    if (access == null) return const SizedBox();
    
    final spotName = access.spotName;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoTitle('Entrada Activa'),
        _buildInfoRow('Espacio:', spotName),
        _buildInfoRow('Inicio:', DateFormat('dd/MM/yyyy').format(DateTime.parse(access.startDate))),
        if (access.endDate != null)
          _buildInfoRow('Fin:', DateFormat('dd/MM/yyyy').format(DateTime.parse(access.endDate!))),
        _buildInfoRow('Monto:', '\$${access.amount.toStringAsFixed(2)}'),
        _buildInfoRow('Tipo:', vehicle.type ?? 'No especificado'),
        _buildInfoRow('Color:', vehicle.color ?? 'No especificado'),
        if (vehicle.ownerName != null)
          _buildInfoRow('Propietario:', vehicle.ownerName!),
      ],
    );
  }
  
  /// Construye la información de reserva
  Widget _buildReservationInfo(BuildContext context) {
    final reservation = vehicle.reservation;
    if (reservation == null) return const SizedBox();
    
    final spotName = reservation.spotName;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoTitle('Reserva'),
        _buildInfoRow('Espacio:', spotName),
        _buildInfoRow('Inicio:', DateFormat('dd/MM/yyyy').format(DateTime.parse(reservation.startDate))),
        if (reservation.endDate != null)
          _buildInfoRow('Fin:', DateFormat('dd/MM/yyyy').format(DateTime.parse(reservation.endDate!))),
        _buildInfoRow('Monto:', '\$${reservation.amount.toStringAsFixed(2)}'),
        _buildInfoRow('Tipo:', vehicle.type ?? 'No especificado'),
        _buildInfoRow('Color:', vehicle.color ?? 'No especificado'),
        if (vehicle.ownerName != null)
          _buildInfoRow('Propietario:', vehicle.ownerName!),
      ],
    );
  }
  
  /// Construye la información de suscripción
  Widget _buildSubscriptionInfo(BuildContext context) {
    final subscription = vehicle.subscription;
    if (subscription == null) return const SizedBox();
    
    final spotName = subscription.spotName;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoTitle('Suscripción'),
        _buildInfoRow('Espacio:', spotName),
        _buildInfoRow('Inicio:', DateFormat('dd/MM/yyyy').format(DateTime.parse(subscription.startDate))),
        if (subscription.endDate != null)
          _buildInfoRow('Fin:', DateFormat('dd/MM/yyyy').format(DateTime.parse(subscription.endDate!))),
        _buildInfoRow('Monto:', '\$${subscription.amount.toStringAsFixed(2)}'),
        _buildInfoRow('Tipo:', vehicle.type ?? 'No especificado'),
        _buildInfoRow('Color:', vehicle.color ?? 'No especificado'),
        if (vehicle.ownerName != null)
          _buildInfoRow('Propietario:', vehicle.ownerName!),
      ],
    );
  }
  
  /// Construye el mensaje informativo según el tipo de estado
  Widget _buildInfoMessage(BuildContext context) {
    final hasActiveAccess = vehicle.access != null;
    final hasReservation = vehicle.reservation != null;
    final hasSubscription = vehicle.subscription != null;
    
    String message;
    IconData icon;
    Color color;
    
    if (hasReservation) {
      message = 'Este vehículo tiene una reserva. Puede registrar su entrada usando la reserva existente.';
      icon = Icons.event_available;
      color = Colors.orange;
    } else if (hasSubscription) {
      message = 'Este vehículo tiene una suscripción activa. Puede registrar su entrada sin costo adicional.';
      icon = Icons.card_membership;
      color = Colors.green;
    } else {
      return const SizedBox();
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Construye un título de sección
  Widget _buildInfoTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  /// Construye una fila de información
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 