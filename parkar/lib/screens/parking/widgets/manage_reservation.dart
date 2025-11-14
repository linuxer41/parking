import 'package:flutter/material.dart';
import '../../../services/booking_service.dart';
import '../../../state/app_state_container.dart';
import '../../../models/booking_model.dart';
import '../../../models/parking_model.dart';
import '../../../models/employee_model.dart';
import '../../../models/vehicle_model.dart';
import '../../../models/parking_model.dart';
import '../models/parking_spot.dart';
import '../../../services/print_service.dart';
import 'components/index.dart';

/// Modal para manejar spots con reserva
class ManageReservation extends StatefulWidget {
  final ParkingSpot spot;

  const ManageReservation({super.key, required this.spot});

  @override
  State<ManageReservation> createState() => _ManageReservationState();

  /// Mostrar el modal como un bottom sheet
  static Future<void> show(BuildContext context, ParkingSpot spot) async {
    ManageLayout.show(
      context: context,
      child: ManageReservation(spot: spot),
    );
  }
}

class _ManageReservationState extends State<ManageReservation> {
  bool isLoading = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    final reservation = widget.spot.occupancy?.reservation;
    if (reservation == null) {
      return const FullScreenErrorContainer(
        message: 'No hay información de reserva disponible',
      );
    }

    // Botón de cancelar reserva
    final cancelButton = CancelButton(
      label: 'Cancelar\nReserva',
      icon: Icons.event_busy,
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
          VehicleInfoCard(vehicle: reservation.vehicle),

          const SizedBox(height: 16),

          // Información de la reserva
          ReservationInfoCard(
            startDate: reservation.startDate,
            endDate: reservation.endDate,
            amount: reservation.amount,
            employeeName: reservation.employee.name,
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
      title: 'Espacio Reservado',
      subtitle: 'Espacio ${widget.spot.label}',
      icon: Icons.bookmark,
      content: content,
      actions: actions,
      headerAction: cancelButton,
      errorMessage: errorMessage,
    );
  }

  // Marcar entrada del vehículo reservado
  Future<void> _handleMarkEntry() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final reservation = widget.spot.occupancy?.reservation;
      if (reservation == null) {
        throw Exception('No hay información de reserva disponible');
      }

      // Registrar entrada usando el nuevo endpoint para reservas
      final bookingService = AppStateContainer.di(
        context,
      ).resolve<BookingService>();
      final entry = await bookingService.registerEntry(reservation.id);

      // Actualizar el spot con los datos del acceso
      _updateSpotWithAccessData(entry);

      if (!mounted) return;

      // Cerrar el modal
      Navigator.pop(context);

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Entrada registrada para ${reservation.vehicle.plate}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      // Imprimir ticket de entrada
      final printService = AppStateContainer.di(
        context,
      ).resolve<PrintService>();
      final booking = await bookingService.getBooking(reservation.id);
      if (booking == null) {
        throw Exception('No se encontró el booking');
      }
      final appState = AppStateContainer.of(context);
      await printService.printEntryTicket(
        booking: booking,
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

  // Cancelar la reserva
  Future<void> _handleCancelReservation() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final reservation = widget.spot.occupancy?.reservation;
      if (reservation == null) {
        throw Exception('No hay información de reserva disponible');
      }

      // Llamar al servicio para cancelar la reserva
      final bookingService = AppStateContainer.di(
        context,
      ).resolve<BookingService>();
      await bookingService.deleteBooking(reservation.id);

      // Actualizar el spot como disponible
      widget.spot.isOccupied = false;
      widget.spot.occupancy = ElementOccupancyModel(status: 'available');

      if (!mounted) return;

      // Cerrar el modal
      Navigator.pop(context);

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reserva cancelada para ${reservation.vehicle.plate}'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cancelar reserva: $e';
        isLoading = false;
      });
    }
  }

  void _showCancelConfirmation() {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: Text(
          '¿Estás seguro de que quieres cancelar la reserva para el vehículo ${widget.spot.occupancy?.reservation?.vehicle.plate}?',
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
        _handleCancelReservation();
      }
    });
  }

  // Función para actualizar el spot con datos de acceso
  void _updateSpotWithAccessData(BookingModel access) {
    final occupancy = ElementOccupancyModel(
      access: ElementActivityModel(
        id: access.id,
        startDate: access.startDate?.toIso8601String() ?? '',
        endDate: access.endDate?.toIso8601String(),
        vehicle: VehiclePreviewModel(
          id: access.vehicle.id ?? '',
          plate: access.vehicle.plate ?? '',
          type: access.vehicle.type ?? '',
          color: access.vehicle.color,
          ownerName: access.vehicle.ownerName,
          ownerDocument: access.vehicle.ownerDocument,
          ownerPhone: access.vehicle.ownerPhone,
        ),
        employee: EmployeePreviewModel(
          id: access.employee.id ?? '',
          name: access.employee.name ?? '',
          role: access.employee.role ?? '',
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
    final reservation = widget.spot.occupancy?.reservation;

    if (reservation == null) return;

    // Obtener fecha de reserva
    DateTime reservationDate;
    try {
      reservationDate = DateTime.parse(reservation.startDate);
    } catch (e) {
      reservationDate = DateTime.now();
    }

    // Imprimir ticket de reserva
    printService.printReservationTicket(
      booking: reservation as BookingModel,
      context: context,
      isSimpleMode:
          appState.currentParking?.operationMode == ParkingOperationMode.list,
    );
  }
}
