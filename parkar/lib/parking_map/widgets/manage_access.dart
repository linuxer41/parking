import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/access_model.dart';
import '../../models/parking_model.dart';
import '../../models/vehicle_model.dart';
import '../../services/access_service.dart';
import '../../services/print_service.dart';
import '../../state/app_state_container.dart';
import '../../widgets/print_method_dialog.dart';
import '../models/parking_spot.dart';
import 'components/index.dart';

/// Modal para registrar salida de vehículos
class ManageAccess extends StatefulWidget {
  final ParkingSpot spot;
  final VoidCallback? onExitSuccess;

  const ManageAccess({super.key, required this.spot, this.onExitSuccess});

  @override
  State<ManageAccess> createState() => _ManageAccessState();

  /// Mostrar el modal como un bottom sheet
  static Future<void> show(BuildContext context, ParkingSpot spot, {VoidCallback? onExitSuccess}) async {
    // Verificar que el spot tenga un acceso asociado
    if (spot.entry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Error: No hay información de vehículo para este acceso',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    ManageLayout.show(
      context: context,
      child: ManageAccess(spot: spot, onExitSuccess: onExitSuccess),
    );
  }
}

class _ManageAccessState extends State<ManageAccess> {
  late DateTime entryTime;
  late Duration currentDuration;
  Timer? timer;
  double cost = 0;
  bool isLoading = false;
  String errorMessage = '';

  // Variables para determinar el tipo de acceso
  bool isReservation = false;
  bool isSubscription = false;
  double? advanceAmount;

  @override
  void initState() {
    super.initState();
    _determineAccessType();

    // Parse entry time safely
    try {
      entryTime = DateTime.parse(widget.spot.entry!.startDate);
    } catch (e) {
      // If parsing fails, use current time minus 1 hour as fallback
      entryTime = DateTime.now().subtract(const Duration(hours: 1));
    }
    currentDuration = DateTime.now().difference(entryTime);

    // Calcular tarifa inicial solo si no es suscripción
    if (!isSubscription) {
      final hours = (currentDuration.inMinutes / 60).ceil();
      cost = hours * 5.0; // $5 por hora
    }

    // Iniciar temporizador para actualizar duración
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          currentDuration = DateTime.now().difference(entryTime);
        });
      }
    });
  }

  /// Determina el tipo de acceso basado en la ocupación del spot
  void _determineAccessType() {
    // Verificar si hay una reserva asociada
    if (widget.spot.booking != null) {
      isReservation = true;
      // Note: advanceAmount not available in ElementOccupancyInfoModel
    }

    // Verificar si hay una suscripción asociada
    if (widget.spot.subscription != null) {
      isSubscription = true;
    }

    // Si el status es 'subscribed', también es una suscripción
    if (widget.spot.status == 'subscribed') {
      isSubscription = true;
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If entry is null, show empty (should not happen as modal closes)
    if (widget.spot.entry == null) {
      return Container();
    }

    // Contenido principal
    final content = SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información del vehículo
          VehicleInfoCard(vehicle: VehiclePreviewModel(
            id: widget.spot.entry!.id,
            plate: widget.spot.entry!.vehiclePlate,
            type: '', // Not available
            color: '', // Not available
            ownerName: widget.spot.entry!.ownerName,
            ownerDocument: '', // Not available
            ownerPhone: widget.spot.entry!.ownerPhone,
          )),

          const SizedBox(height: 16),

          // Información de permanencia
          StayInfoCard(
            entryTime: entryTime,
            duration: currentDuration,
            cost: cost,
            isSubscription: isSubscription,
            isReservation: isReservation,
            advanceAmount: advanceAmount,
          ),
        ],
      ),
    );

    // Botones de acción con distribución personalizada
    final actions = Row(
      children: [
        Expanded(
          flex: 1, // 25% - Ticket Entrada
          child: SecondaryActionButton(
            label: 'Entrada',
            icon: Icons.receipt_outlined,
            onPressed: _printEntryTicket,
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1, // 25% - Ticket Salida
          child: SecondaryActionButton(
            label: 'Salida',
            icon: Icons.receipt_outlined,
            onPressed: _printExitTicket,
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2, // 50% - Registrar Salida
          child: PrimaryActionButton(
            label: 'Registrar Salida',
            icon: Icons.logout,
            onPressed: _registerExit,
            isLoading: isLoading,
          ),
        ),
      ],
    );

    return ManageLayout(
      title: 'Registrar Salida',
      subtitle: 'Espacio ${widget.spot.label}',
      icon: Icons.logout_rounded,
      content: content,
      actions: actions,
      errorMessage: errorMessage,
    );
  }

  // Método para registrar la salida
  Future<void> _registerExit() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final appState = AppStateContainer.of(context);
      final parkingId = appState.currentParking?.id;

      if (parkingId == null) {
        setState(() {
          errorMessage = 'No hay estacionamiento seleccionado';
          isLoading = false;
        });
        return;
      }

      final accessService = AppStateContainer.di(
        context,
      ).resolve<AccessService>();

      final access = await accessService.getAccess(
        widget.spot.entry!.id,
      );
      if (access == null) {
        setState(() {
          errorMessage = 'No se encontró el acceso';
          isLoading = false;
        });
        return;
      }

      // Determinar el monto a cobrar según el tipo de acceso
      double finalCost = 0;

      if (isSubscription) {
        // Para suscripciones, no se cobra nada
        finalCost = 0;
      } else if (isReservation && advanceAmount != null) {
        // Para reservas, usar el monto del adelanto
        finalCost = advanceAmount!;
      } else {
        // Para acceso normal, calcular tarifa
        try {
          finalCost = await accessService.calculateExitFee(access.id);
        } catch (e) {
          debugPrint('Error al calcular tarifa: $e');
          // Usar la tarifa estimada como fallback
          finalCost = cost;
        }
      }

      // Registrar salida en la API
      final updatedAccess = await accessService.registerExit(
        entryId: access.id,
        amount: finalCost,
      );

      // Actualizar el spot con los datos devueltos por la API
      _updateSpotWithExitData(updatedAccess);

      // Imprimir ticket de salida usando la preferencia guardada
      final printService = AppStateContainer.di(
        context,
      ).resolve<PrintService>();

      await printService.printExitTicket(
        booking: updatedAccess,
        context: context,
        isSimpleMode:
            appState.currentParking?.operationMode == ParkingOperationMode.list,
      );

      // Cerrar el diálogo después de imprimir
      if (mounted) {
        // Cerrar el diálogo
        Navigator.pop(context);

        // Actualizar el spot con los datos devueltos por la API
        _updateSpotWithExitData(updatedAccess);

        // Mostrar confirmación
        String message = 'Vehículo ${updatedAccess.vehicle.plate} ha salido';
        if (isSubscription) {
          message += ' (Suscripción)';
        } else if (isReservation) {
          message += ' (Reserva)';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        // Llamar callback de éxito
        widget.onExitSuccess?.call();
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  /// Obtiene el string del tipo de acceso para el ticket
  String _getAccessTypeString() {
    if (isSubscription) {
      return 'Suscripción';
    } else if (isReservation) {
      return 'Reserva';
    } else {
      return 'Acceso Normal';
    }
  }

  // Función para actualizar el spot con datos de salida
  void _updateSpotWithExitData(AccessModel updatedAccess) {
    // Si el acceso tiene fecha de salida, marcar el spot como disponible
    if (updatedAccess.exitTime != null) {
      widget.spot.isOccupied = false;
      widget.spot.entry = null;
      widget.spot.status = 'available';
    } else {
      // Si no hay fecha de salida, actualizar con los datos del acceso
      final entryInfo = ElementOccupancyInfoModel(
        id: updatedAccess.id,
        vehiclePlate: updatedAccess.vehicle.plate,
        ownerName: updatedAccess.vehicle.ownerName ?? '',
        ownerPhone: updatedAccess.vehicle.ownerPhone ?? '',
        startDate: updatedAccess.entryTime.toIso8601String(),
      );

      widget.spot.entry = entryInfo;
      widget.spot.isOccupied = true;
      widget.spot.status = 'occupied';
    }
  }

  // Método para imprimir ticket de entrada
  Future<void> _printEntryTicket() async {
    final printService = AppStateContainer.di(context).resolve<PrintService>();
    final accessService = AppStateContainer.di(
      context,
    ).resolve<AccessService>();
    final appState = AppStateContainer.of(context);
    final access = await accessService.getAccess(
      widget.spot.entry!.id,
    );

    if (access != null) {
      // Mostrar PDF del ticket de entrada
      printService.printEntryTicket(
        booking: access,
        context: context,
        isSimpleMode:
            appState.currentParking?.operationMode == ParkingOperationMode.list,
        forceView: true,
      );
    }
  }

  // Método para imprimir ticket de salida
  Future<void> _printExitTicket() async {
    final printService = AppStateContainer.di(context).resolve<PrintService>();
    final accessService = AppStateContainer.di(
      context,
    ).resolve<AccessService>();
    final appState = AppStateContainer.of(context);
    final access = await accessService.getAccess(
      widget.spot.entry!.id,
    );

    if (access != null) {
      // Mostrar PDF del ticket de salida (preview)
      printService.printExitTicket(
        booking: access,
        context: context,
        isSimpleMode:
            appState.currentParking?.operationMode == ParkingOperationMode.list,
        forceView: true,
      );
    }
  }
}
