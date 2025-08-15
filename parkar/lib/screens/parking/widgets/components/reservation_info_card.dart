import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'info_components.dart';

/// Componente para mostrar la información de una reserva
class ReservationInfoCard extends StatelessWidget {
  /// Fecha de inicio de la reserva (formato ISO)
  final String startDate;
  
  /// Fecha de fin de la reserva (formato ISO), opcional
  final String? endDate;
  
  /// Monto de la reserva
  final double amount;
  
  /// Nombre del empleado que registró la reserva
  final String employeeName;

  const ReservationInfoCard({
    super.key,
    required this.startDate,
    this.endDate,
    required this.amount,
    required this.employeeName,
  });

  @override
  Widget build(BuildContext context) {
    return InfoSection(
      title: 'Detalles de la Reserva',
      icon: Icons.calendar_today,
      children: [
        InfoRow(label: 'Fecha de inicio', value: _formatDateTime(startDate)),
        if (endDate != null)
          InfoRow(label: 'Fecha de fin', value: _formatDateTime(endDate!)),
        InfoRow(label: 'Monto', value: '\$${amount.toStringAsFixed(2)}'),
        InfoRow(label: 'Empleado', value: employeeName),
      ],
    );
  }
  
  /// Formatea una fecha en formato ISO a un formato legible
  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }
} 