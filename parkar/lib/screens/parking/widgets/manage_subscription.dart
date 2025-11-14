import 'package:flutter/material.dart';
import '../../../services/booking_service.dart';
import '../../../services/entry_exit_service.dart';
import '../../../services/subscription_service.dart';
import '../../../state/app_state_container.dart';
import '../../../models/booking_model.dart';
import '../../../models/parking_model.dart';
import '../../../models/employee_model.dart';
import '../../../models/vehicle_model.dart';
import '../../../models/parking_model.dart';
import '../models/parking_spot.dart';
import '../../../services/print_service.dart';
import 'components/index.dart';

/// Modal para manejar spots con suscripción
class ManageSubscription extends StatefulWidget {
  final ParkingSpot spot;

  const ManageSubscription({super.key, required this.spot});

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
    final subscription = widget.spot.subscription;
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
          VehicleInfoCard(
            vehicle: VehiclePreviewModel(
              id: subscription.id,
              plate: subscription.vehiclePlate,
              type: 'Vehículo', // Default type
              color: null,
              ownerName: subscription.ownerName,
              ownerDocument: null,
              ownerPhone: subscription.ownerPhone,
            ),
          ),

          const SizedBox(height: 16),

          // Información de la suscripción
          SubscriptionInfoCard(
            startDate: subscription.startDate,
            endDate: subscription.endDate,
            amount: subscription.amount ?? 0.0,
            employeeName: 'Empleado', // TODO: Add employee info if available
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
      final subscription = widget.spot.subscription;
      if (subscription == null) {
        throw Exception('No hay información de suscripción disponible');
      }

      // Crear acceso usando el EntryExitService con los datos de la suscripción
      final entryExitService = AppStateContainer.di(
        context,
      ).resolve<EntryExitService>();
      final appState = AppStateContainer.of(context);

      final accessModel = AccessCreateModel(
        vehiclePlate: subscription.vehiclePlate,
        vehicleType: 'Vehículo', // Default type
        vehicleColor: null,
        ownerName: subscription.ownerName,
        ownerDocument: null,
        ownerPhone: subscription.ownerPhone,
        spotId: widget.spot.id,
        notes: 'Entrada de suscriptor',
      );

      final entry = await entryExitService.createEntry(
        accessModel,
        parkingId: appState.currentParking?.id ?? '',
        employeeId: appState.employee?.id ?? '',
      );

      // Actualizar el spot con los datos del acceso
      _updateSpotWithAccessData(entry);

      if (!mounted) return;

      // Cerrar el modal
      Navigator.pop(context);

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Entrada registrada para ${subscription.vehiclePlate}',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      // Imprimir ticket de entrada
      final printService = AppStateContainer.di(
        context,
      ).resolve<PrintService>();
      await printService.printEntryTicket(
        booking: entry,
        context: context,
        isSimpleMode:
            appState.currentParking?.operationMode == ParkingOperationMode.list,
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
      final subscription = widget.spot.subscription;
      if (subscription == null) {
        throw Exception('No hay información de suscripción disponible');
      }

      // Llamar al servicio para cancelar la suscripción
      final subscriptionService = AppStateContainer.di(
        context,
      ).resolve<SubscriptionService>();
      await subscriptionService.deleteSubscription(subscription.id);

      // Actualizar el spot como disponible
      widget.spot.isOccupied = false;
      widget.spot.subscription = null;
      widget.spot.status = 'available';

      if (!mounted) return;

      // Cerrar el modal
      Navigator.pop(context);

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Suscripción cancelada para ${subscription.vehiclePlate}',
          ),
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
    final subscription = widget.spot.subscription;
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Suscripción'),
        content: Text(
          '¿Estás seguro de que quieres cancelar la suscripción para el vehículo ${subscription?.vehiclePlate ?? 'desconocido'}?\n\nEsta acción no se puede deshacer.',
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
  void _updateSpotWithAccessData(BookingModel access) {
    final entryInfo = ElementOccupancyInfoModel(
      id: access.id,
      vehiclePlate: access.vehicle.plate ?? '',
      ownerName: access.vehicle.ownerName ?? '',
      ownerPhone: access.vehicle.ownerPhone ?? '',
      startDate: access.startDate?.toIso8601String() ?? '',
      endDate: access.endDate?.toIso8601String(),
      amount: access.amount,
    );

    widget.spot.isOccupied = true;
    widget.spot.entry = entryInfo;
    widget.spot.status = 'occupied';
  }

  // Método para imprimir ticket
  Future<void> _printTicket() async {
    final printService = AppStateContainer.di(context).resolve<PrintService>();
    final subscriptionService = AppStateContainer.di(
      context,
    ).resolve<SubscriptionService>();
    final subscription = widget.spot.subscription;

    if (subscription == null) return;

    final booking = await subscriptionService.getSubscription(subscription.id);

    // Imprimir recibo de suscripción
    printService.printSubscriptionReceipt(booking: booking, context: context);
  }
}
