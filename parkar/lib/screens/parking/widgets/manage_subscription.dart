import 'package:flutter/material.dart';
import '../../../services/access_service.dart';
import '../../../services/subscription_service.dart';
import '../../../state/app_state_container.dart';
import '../../../models/access_model.dart';
import '../../../models/element_model.dart';
import '../../../models/employee_model.dart';
import '../../../models/vehicle_model.dart';
import '../models/parking_spot.dart';
import '../../../services/print_service.dart';
import 'components/index.dart';

/// Modal para manejar spots con suscripción
class ManageSubscription extends StatefulWidget {
  final ParkingSpot spot;

  const ManageSubscription({
    super.key,
    required this.spot,
  });

  @override
  State<ManageSubscription> createState() => _ManageSubscriptionState();
  
  /// Mostrar el modal como un bottom sheet
  static Future<void> show(BuildContext context, ParkingSpot spot) async {
    ManageLayout.show(
      context: context,
      child: ManageSubscription(spot: spot),
    );
  }
}

class _ManageSubscriptionState extends State<ManageSubscription> {
  bool isLoading = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    final subscription = widget.spot.occupancy?.subscription;
    if (subscription == null) {
      return const FullScreenErrorContainer(
        message: 'No hay información de suscripción disponible',
      );
    }

    // Botón de cancelar suscripción
    final cancelButton = CancelButton(
      label: 'Cancelar\nSuscripción',
      icon: Icons.card_membership_outlined,
      onPressed: () => _showCancelConfirmation(),
      isLoading: isLoading,
    );

    // Contenido principal
    final content = SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información del vehículo
          VehicleInfoCard(vehicle: subscription.vehicle),
          
          const SizedBox(height: 16),
          
          // Información de la suscripción
          SubscriptionInfoCard(
            startDate: subscription.startDate,
            endDate: subscription.endDate,
            amount: subscription.amount,
            employeeName: subscription.employee.name,
          ),
        ],
      ),
    );

    // Botones de acción
    final actions = [
      SecondaryActionButton(
        label: 'Ver Ticket',
        icon: Icons.receipt_outlined,
        onPressed: _printTicket,
        isLoading: isLoading,
      ),
      PrimaryActionButton(
        label: 'Marcar Entrada',
        icon: Icons.login,
        onPressed: _handleMarkEntry,
        isLoading: isLoading,
      ),
    ];

    return ManageLayout(
      title: 'Espacio Suscrito',
      subtitle: 'Espacio ${widget.spot.label}',
      icon: Icons.card_membership,
      content: content,
      actions: actions,
      headerAction: cancelButton,
      errorMessage: errorMessage,
    );
  }

  // Marcar entrada del vehículo suscrito
  Future<void> _handleMarkEntry() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final subscription = widget.spot.occupancy?.subscription;
      if (subscription == null) {
        throw Exception('No hay información de suscripción disponible');
      }

      // Registrar entrada usando el nuevo endpoint para suscripciones
      final accessService = AppStateContainer.di(context).resolve<AccessService>();
      final entry = await accessService.registerSubscribedEntry(subscription.id);

      // Actualizar el spot con los datos del acceso
      _updateSpotWithAccessData(entry);

      if (!mounted) return;

      // Cerrar el modal
      Navigator.pop(context);

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Entrada registrada para ${subscription.vehicle.plate}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      // Imprimir ticket de entrada
      final printService = AppStateContainer.di(context).resolve<PrintService>();
      final appState = AppStateContainer.of(context);
      await printService.printEntryTicket(
        plate: subscription.vehicle.plate,
        spotLabel: widget.spot.label,
        entryTime: DateTime.now(),
        vehicleType: subscription.vehicle.type ?? 'car',
        color: subscription.vehicle.color ?? 'blanco',
        parkingName: appState.currentParking?.name ?? 'Estacionamiento',
        ownerName: subscription.vehicle.ownerName,
        ownerDocument: subscription.vehicle.ownerDocument,
        context: context,
      );

    } catch (e) {
      setState(() {
        errorMessage = 'Error al registrar entrada: $e';
        isLoading = false;
      });
    }
  }

  // Cancelar la suscripción
  Future<void> _handleCancelSubscription() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final subscription = widget.spot.occupancy?.subscription;
      if (subscription == null) {
        throw Exception('No hay información de suscripción disponible');
      }

      // Llamar al servicio para cancelar la suscripción
      final subscriptionService = AppStateContainer.di(context).resolve<SubscriptionService>();
      await subscriptionService.cancelSubscription(subscription.id);

      // Actualizar el spot como disponible
      widget.spot.isOccupied = false;
      widget.spot.occupancy = ElementOccupancyModel(status: 'available');

      if (!mounted) return;

      // Cerrar el modal
      Navigator.pop(context);

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Suscripción cancelada para ${subscription.vehicle.plate}'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

    } catch (e) {
      setState(() {
        errorMessage = 'Error al cancelar suscripción: $e';
        isLoading = false;
      });
    }
  }

  void _showCancelConfirmation() {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Suscripción'),
        content: Text(
          '¿Estás seguro de que quieres cancelar la suscripción para el vehículo ${widget.spot.occupancy?.subscription?.vehicle.plate}?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        _handleCancelSubscription();
      }
    });
  }

  // Función para actualizar el spot con datos de acceso
  void _updateSpotWithAccessData(AccessModel access) {
    final occupancy = ElementOccupancyModel(
      access: ElementActivityModel(
        id: access.id,
        startDate: access.entryTime.toIso8601String(),
        endDate: access.exitTime?.toIso8601String(),
        vehicle: VehiclePreviewModel(
          id: access.vehicle.id,
          plate: access.vehicle.plate,
          type: access.vehicle.type,
          color: access.vehicle.color,
          ownerName: access.vehicle.ownerName,
          ownerDocument: access.vehicle.ownerDocument,
          ownerPhone: access.vehicle.ownerPhone,
        ),
        employee: EmployeePreviewModel(
          id: access.employee.id,
          name: access.employee.name,
          role: access.employee.role,
        ),
        amount: access.amount ?? 0.0,
      ),
      status: 'occupied',
    );

    widget.spot.isOccupied = true;
    widget.spot.occupancy = occupancy;
  }

  // Método para imprimir ticket
  void _printTicket() {
    final printService = AppStateContainer.di(context).resolve<PrintService>();
    final appState = AppStateContainer.of(context);
    final subscription = widget.spot.occupancy?.subscription;
    
    if (subscription == null) return;
    
    // Obtener fecha de inicio
    DateTime startDate;
    try {
      startDate = DateTime.parse(subscription.startDate);
    } catch (e) {
      startDate = DateTime.now();
    }
    
    // Obtener fecha de fin
    DateTime endDate;
    try {
      endDate = subscription.endDate != null 
        ? DateTime.parse(subscription.endDate!)
        : startDate.add(const Duration(days: 30)); // 30 días por defecto
    } catch (e) {
      endDate = startDate.add(const Duration(days: 30));
    }
    
    // Determinar tipo de suscripción
    String subscriptionType = 'Mensual'; // Por defecto
    if (endDate.difference(startDate).inDays >= 90) {
      subscriptionType = 'Trimestral';
    } else if (endDate.difference(startDate).inDays >= 180) {
      subscriptionType = 'Semestral';
    } else if (endDate.difference(startDate).inDays >= 365) {
      subscriptionType = 'Anual';
    }
    
    // Imprimir recibo de suscripción
    printService.printSubscriptionReceipt(
      plate: subscription.vehicle.plate,
      subscriptionType: subscriptionType,
      startDate: startDate,
      endDate: endDate,
      amount: subscription.amount,
      parkingName: appState.currentParking?.name ?? 'Estacionamiento',
      ownerName: subscription.vehicle.ownerName,
      ownerDocument: subscription.vehicle.ownerDocument,
      context: context,
    );
  }
} 