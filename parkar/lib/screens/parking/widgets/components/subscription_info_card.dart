import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../constants/constants.dart';
import 'info_components.dart';

/// Componente para mostrar la información de una suscripción
class SubscriptionInfoCard extends StatelessWidget {
  /// Fecha de inicio de la suscripción (formato ISO)
  final String startDate;
  
  /// Fecha de fin de la suscripción (formato ISO), opcional
  final String? endDate;
  
  /// Monto de la suscripción
  final double amount;
  
  /// Nombre del empleado que registró la suscripción
  final String employeeName;

  const SubscriptionInfoCard({
    super.key,
    required this.startDate,
    this.endDate,
    required this.amount,
    required this.employeeName,
  });

  @override
  Widget build(BuildContext context) {
    return InfoSection(
      title: 'Detalles de la Suscripción',
      icon: Icons.card_membership,
      children: [
        InfoRow(label: 'Fecha de inicio', value: _formatDateTime(startDate)),
        InfoRow(label: 'Fecha de vencimiento', value: _formatDateTime(endDate ?? '')),
        InfoRow(label: 'Monto', value: CurrencyConstants.formatAmountWithParkingParams(context, amount)),
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