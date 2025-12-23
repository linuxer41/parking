import 'dart:async';

import 'package:flutter/material.dart';

import '../../../models/access_model.dart';
import '../../../models/parking_model.dart';
import '../../../models/vehicle_model.dart';
import '../../../parking_map/models/parking_spot.dart';
import '../../../parking_map/models/enums.dart';
import '../../../services/access_service.dart';
import '../../../services/print_service.dart';
import '../../../state/app_state_container.dart';
import '../../../utils/parking_utils.dart';
import 'components/action_buttons.dart' show SecondaryActionButton, PrimaryActionButton;
import 'components/manage_layout.dart';
import 'components/stay_info_card.dart';
import 'components/vehicle_info_card.dart';

/// Modal para registrar salida de vehículos
class ManageAccess extends StatefulWidget {
  final dynamic parking;
  final AccessModel access;
  final VoidCallback? onExitSuccess;

  const ManageAccess({super.key, required this.parking, required this.access, this.onExitSuccess});

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

    final appState = AppStateContainer.of(context);
    final parking = appState.currentParking;
    if (parking == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No hay estacionamiento seleccionado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final accessService = AppStateContainer.di(context).resolve<AccessService>();
    final access = await accessService.getAccess(spot.entry!.id);
    if (access == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo obtener el acceso'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ManageLayout.show(
      context: context,
      child: ManageAccess(parking: parking, access: access, onExitSuccess: onExitSuccess),
    );
  }

  @override
  State<ManageAccess> createState() => _ManageAccessState();
}

class _ManageAccessState extends State<ManageAccess> {
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

    currentDuration = DateTime.now().difference(widget.access.entryTime);

    // Calcular tarifa inicial usando el calculador de fees
    _calculateCost();

    // Iniciar temporizador para actualizar duración y costo
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          currentDuration = DateTime.now().difference(widget.access.entryTime);
          _calculateCost();
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _calculateCost() {
    if (isSubscription) {
      cost = 0.0;
      return;
    }

    try {
      final appState = AppStateContainer.of(context);
      final rates = appState.currentParking?.rates ?? [];
      if (rates.isEmpty) {
        cost = 0.0;
        return;
      }

      cost = calculateParkingFee(
        widget.access.entryTime.toIso8601String(),
        rates,
        widget.access.vehicle.type,
      );
    } catch (e) {
      cost = 0.0;
    }
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
          VehicleInfoCard(vehicle: widget.access.vehicle),

          const SizedBox(height: 16),

          // Información de permanencia
          StayInfoCard(
            entryTime: widget.access.entryTime,
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
            onPressed: () => _printExitTicket(widget.access, widget.parking.operationMode),
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
      subtitle: 'Espacio ${widget.access.spot?.name ?? '--'}',
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
      
      final accessService = AppStateContainer.di(
        context,
      ).resolve<AccessService>();

      final access = await accessService.getAccess(
        widget.access.id,
      );

      // Registrar salida en la API
      final updatedAccess = await accessService.registerExit(
        entryId: access.id,
        amount: cost,
      );

      // Cerrar el diálogo primero
      if (mounted) {
        Navigator.pop(context);
        setState(() {
          isLoading = false;
        });
      }
      widget.onExitSuccess?.call();

      await _printExitTicket(
        updatedAccess,
        widget.parking.operationMode,
      );
      
    } catch (e) {
      debugPrint('Error al registrar salida: $e');
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
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
      widget.access.id,
    );

    if (access != null) {
      // Mostrar PDF del ticket de entrada
      printService.printEntryTicket(
        access: access,
        context: context,
        isSimpleMode:
            appState.currentParking?.operationMode == ParkingOperationMode.list,
        forceView: false,
      );
    }
  }

  // Método para imprimir ticket de salida
  Future<void> _printExitTicket(AccessModel access, ParkingOperationMode? operationMode) async {
    final printService = AppStateContainer.di(context).resolve<PrintService>();
    printService.printExitTicket(
      access: access,
      context: context,
      isSimpleMode: (operationMode ?? ParkingOperationMode.list) == ParkingOperationMode.list,
      forceView: false,
    );
  }
}
