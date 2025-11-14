import 'package:flutter/material.dart';
import '../../../services/booking_service.dart';
import '../../../services/entry_exit_service.dart';
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
    final reservation = widget.spot.booking;
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
          VehicleInfoCard(
            vehicle: VehiclePreviewModel(
              id: reservation.id,
              plate: reservation.vehiclePlate,
              type: 'Vehículo', // Default type
              color: null,
              ownerName: reservation.ownerName,
              ownerDocument: null,
              ownerPhone: reservation.ownerPhone,
            ),
          ),

          const SizedBox(height: 16),

          // Información de la reserva
          ReservationInfoCard(
            startDate: reservation.startDate,
            endDate: reservation.endDate,
            amount: reservation.amount ?? 0.0,
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
      final reservation = widget.spot.booking;
      if (reservation == null) {
        throw Exception('No hay información de reserva disponible');
      }

      // Registrar entrada usando el servicio de entradas y salidas
      final entryExitService = AppStateContainer.di(
        context,
      ).resolve<EntryExitService>();
      final entry = await entryExitService.registerEntry(reservation.id);

      // Actualizar el spot con los datos del acceso
      _updateSpotWithAccessData(entry);

      if (!mounted) return;

      // Cerrar el modal
      Navigator.pop(context);

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Entrada registrada para ${reservation.vehiclePlate}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      // Imprimir ticket de entrada
      final printService = AppStateContainer.di(
        context,
      ).resolve<PrintService>();
      final bookingService = AppStateContainer.di(
        context,
      ).resolve<BookingService>();
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
      final reservation = widget.spot.booking;
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
      widget.spot.booking = null;
      widget.spot.status = 'available';

      if (!mounted) return;

      // Cerrar el modal
      Navigator.pop(context);

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reserva cancelada para ${reservation.vehiclePlate}'),
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
    final reservation = widget.spot.booking;
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: Text(
          '¿Estás seguro de que quieres cancelar la reserva para el vehículo ${reservation?.vehiclePlate ?? 'desconocido'}?',
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
  void _printTicket() {
    final printService = AppStateContainer.di(context).resolve<PrintService>();
    final appState = AppStateContainer.of(context);
    final reservation = widget.spot.booking;

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
