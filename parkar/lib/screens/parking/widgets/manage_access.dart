import 'dart:async';
import 'package:flutter/material.dart';
import '../../../services/print_service.dart';
import '../../../services/access_service.dart';
import '../../../state/app_state_container.dart';
import '../../../models/element_model.dart';
import '../../../models/access_model.dart';
import '../../../models/employee_model.dart';
import '../../../models/vehicle_model.dart';
import '../models/parking_spot.dart';
import 'components/index.dart';

/// Modal para registrar salida de vehículos
class ManageAccess extends StatefulWidget {
  final ParkingSpot spot;

  const ManageAccess({
    super.key,
    required this.spot,
  });

  @override
  State<ManageAccess> createState() => _ManageAccessState();
  
  /// Mostrar el modal como un bottom sheet
  static Future<void> show(BuildContext context, ParkingSpot spot) async {
    // Verificar que el spot tenga un acceso asociado
    if (spot.occupancy == null || spot.occupancy!.access == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error: Este espacio no tiene un vehículo registrado'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    // Verificar que el acceso no esté ya completado
    if (spot.occupancy!.access!.endDate != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Este vehículo ya tiene registrada una salida'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    ManageLayout.show(
      context: context,
      child: ManageAccess(spot: spot),
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
      entryTime = DateTime.parse(widget.spot.occupancy!.access!.startDate);
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
    final occupancy = widget.spot.occupancy;
    if (occupancy == null) return;
    
    // Verificar si hay una reserva asociada
    if (occupancy.reservation != null) {
      isReservation = true;
      advanceAmount = occupancy.reservation!.amount;
    }
    
    // Verificar si hay una suscripción asociada
    if (occupancy.subscription != null) {
      isSubscription = true;
    }
    
    // Si el status es 'subscribed', también es una suscripción
    if (occupancy.status == 'subscribed') {
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
    // Contenido principal
    final content = SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información del vehículo
          VehicleInfoCard(vehicle: widget.spot.occupancy!.access!.vehicle),
          
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

    // Botones de acción
    final actions = [
      SecondaryActionButton(
        label: 'Ver Ticket',
        icon: Icons.receipt_outlined,
        onPressed: _printTicket,
        isLoading: isLoading,
      ),
      PrimaryActionButton(
        label: 'Registrar Salida',
        icon: Icons.logout,
        onPressed: _registerExit,
        isLoading: isLoading,
      ),
    ];

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

      final accessService = AppStateContainer.di(context).resolve<AccessService>();
      final now = DateTime.now();
      final access = widget.spot.occupancy!.access!;

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
          finalCost = await accessService.calculateExitFee(
            parkingId,
            access.id,
          );
        } catch (e) {
          debugPrint('Error al calcular tarifa: $e');
          // Usar la tarifa estimada como fallback
          finalCost = cost;
        }
      }
      
      // Registrar salida en la API
      final updatedAccess = await accessService.registerExit(
        parkingId: parkingId,
        accessId: access.id,
        amount: finalCost,
      );

      // Actualizar el spot con los datos devueltos por la API
      _updateSpotWithExitData(updatedAccess);

      // Imprimir ticket de salida
      final printService = AppStateContainer.di(context).resolve<PrintService>();
      
      // Asegurarse de que startDate no sea nulo
      DateTime entryTime;
      try {
        entryTime = access.startDate != null ? DateTime.parse(access.startDate) : now.subtract(const Duration(hours: 1));
      } catch (e) {
        // Si hay un error de parsing, usar un valor por defecto
        entryTime = now.subtract(const Duration(hours: 1));
      }
      
      await printService.printExitTicket(
        plate: access.vehicle.plate,
        spotLabel: widget.spot.label,
        entryTime: entryTime,
        exitTime: now,
        duration: currentDuration,
        cost: finalCost,
        parkingName: appState.currentParking?.name ?? 'Estacionamiento',
        parkingAddress: appState.currentParking?.address ?? 'Dirección no disponible',
        employeeName: appState.employee?.role,
        context: context,
        accessType: _getAccessTypeString(),
      );

      // Cerrar el diálogo después de imprimir
      if (mounted) {
        // Cerrar el diálogo
        Navigator.pop(context);
        
        // Mostrar confirmación
        String message = 'Vehículo ${access.vehicle.plate} ha salido';
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
      widget.spot.occupancy = ElementOccupancyModel(
        status: 'available',
      );
    } else {
      // Si no hay fecha de salida, actualizar con los datos del acceso
      final occupancy = ElementOccupancyModel(
        access: ElementActivityModel(
          id: updatedAccess.id,
          startDate: updatedAccess.entryTime.toIso8601String(),
          endDate: updatedAccess.exitTime?.toIso8601String(),
          vehicle: VehiclePreviewModel(
            id: updatedAccess.vehicle.id,
            plate: updatedAccess.vehicle.plate,
            type: updatedAccess.vehicle.type,
            color: updatedAccess.vehicle.color,
            ownerName: updatedAccess.vehicle.ownerName,
            ownerDocument: updatedAccess.vehicle.ownerDocument,
            ownerPhone: updatedAccess.vehicle.ownerPhone,
          ),
          employee: EmployeePreviewModel(
            id: updatedAccess.employee.id,
            name: updatedAccess.employee.name,
            role: updatedAccess.employee.role,
          ),
          amount: updatedAccess.amount ?? 0.0,
        ),
        status: updatedAccess.exitTime != null ? 'available' : 'occupied',
      );

      widget.spot.occupancy = occupancy;
      widget.spot.isOccupied = updatedAccess.exitTime == null;
    }
  }

  // Método para imprimir ticket
  void _printTicket() {
    final printService = AppStateContainer.di(context).resolve<PrintService>();
    final appState = AppStateContainer.of(context);
    final now = DateTime.now();
    final access = widget.spot.occupancy!.access!;
    
    // Asegurarse de que startDate no sea nulo
    DateTime entryTime;
    try {
      entryTime = access.startDate != null ? DateTime.parse(access.startDate) : now.subtract(const Duration(hours: 1));
    } catch (e) {
      // Si hay un error de parsing, usar un valor por defecto
      entryTime = now.subtract(const Duration(hours: 1));
    }
    
    // Determinar el costo para el ticket
    double ticketCost = cost;
    if (isSubscription) {
      ticketCost = 0;
    } else if (isReservation && advanceAmount != null) {
      ticketCost = advanceAmount!;
    }
    
    printService.printExitTicket(
      plate: access.vehicle.plate,
      spotLabel: widget.spot.label,
      entryTime: entryTime,
      exitTime: now,
      duration: currentDuration,
      cost: ticketCost,
      parkingName: appState.currentParking?.name ?? 'Estacionamiento',
      parkingAddress: appState.currentParking?.address ?? 'Dirección no disponible',
      employeeName: appState.employee?.role,
      context: context,
      accessType: _getAccessTypeString(),
    );
  }
} 