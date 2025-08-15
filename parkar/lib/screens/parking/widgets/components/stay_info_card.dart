import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'info_components.dart';

/// Componente para mostrar la información de permanencia de un vehículo
class StayInfoCard extends StatelessWidget {
  /// Fecha y hora de entrada
  final DateTime entryTime;
  
  /// Duración de la permanencia
  final Duration duration;
  
  /// Costo calculado
  final double cost;
  
  /// Si es una suscripción
  final bool isSubscription;
  
  /// Si es una reserva
  final bool isReservation;
  
  /// Monto del adelanto (para reservas)
  final double? advanceAmount;

  const StayInfoCard({
    super.key,
    required this.entryTime,
    required this.duration,
    required this.cost,
    this.isSubscription = false,
    this.isReservation = false,
    this.advanceAmount,
  });

  @override
  Widget build(BuildContext context) {
    return InfoSection(
      title: 'Detalles de Permanencia',
      icon: Icons.access_time,
      children: [
        InfoRow(label: 'Entrada', value: DateFormat('dd/MM/yyyy - HH:mm').format(entryTime)),
        InfoRow(label: 'Tiempo', value: _formatDuration(duration)),
        _buildCostRow(context),
      ],
    );
  }
  
  /// Construye la fila de costo según el tipo de acceso
  Widget _buildCostRow(BuildContext context) {
    if (isSubscription) {
      return const InfoRow(
        label: 'Tipo de acceso', 
        value: 'Suscripción - Sin cargo'
      );
    } else if (isReservation && advanceAmount != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InfoRow(
            label: 'Tipo de acceso', 
            value: 'Reserva - Adelanto pagado'
          ),
          InfoRow(
            label: 'Monto adelanto', 
            value: '\$${advanceAmount!.toStringAsFixed(2)}'
          ),
        ],
      );
    } else {
      return InfoRow(
        label: 'Total a pagar', 
        value: '\$${cost.toStringAsFixed(2)}'
      );
    }
  }
  
  /// Formatea una duración a un formato legible
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '$hours h ${minutes.toString().padLeft(2, '0')} m ${seconds.toString().padLeft(2, '0')} s';
    } else if (minutes > 0) {
      return '$minutes m ${seconds.toString().padLeft(2, '0')} s';
    } else {
      return '$seconds s';
    }
  }
} 