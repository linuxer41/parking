// ignore_for_file: sized_box_for_whitespace

import 'package:flutter/material.dart';
import '../../../services/access_service.dart';
import '../../../services/reservation_service.dart';
import '../../../services/subscription_service.dart';
import '../../../services/vehicle_service.dart';
import '../../../state/app_state_container.dart';
import '../../../models/access_model.dart';
import '../../../models/reservation_model.dart';
import '../../../models/subscription_model.dart';
import '../../../models/element_model.dart';
import '../../../models/employee_model.dart';
import '../models/parking_spot.dart';
import '../../../services/print_service.dart'; // Added import for PrintService
import '../../../models/parking_model.dart'; // Added import for ParkingModel
import 'components/index.dart';
import '../../../models/vehicle_model.dart'; // Added import for VehicleModel

/// Modal para registrar entrada de vehículos
class RegisterOccupancy extends StatefulWidget {
  final ParkingSpot spot;

  const RegisterOccupancy({
    super.key,
    required this.spot,
  });

  @override
  State<RegisterOccupancy> createState() => _RegisterOccupancyState();
  
  /// Mostrar el modal como un bottom sheet
  static Future<void> show(BuildContext context, ParkingSpot spot) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RegisterOccupancy(spot: spot),
    );
  }
}

class _RegisterOccupancyState extends State<RegisterOccupancy> {
  final plateController = TextEditingController();
  final ownerNameController = TextEditingController();
  final documentController = TextEditingController();
  final phoneController = TextEditingController();
  final reservationDateController = TextEditingController();
  final reservationDurationController = TextEditingController();
  final subscriptionNameController = TextEditingController();
  final subscriptionDocumentController = TextEditingController();
  final subscriptionStartDateController = TextEditingController(); // Nuevo controlador para fecha de inicio
  
  String vehicleType = 'car';
  String selectedColor = 'blanco';
  SubscriptionPeriod subscriptionType = SubscriptionPeriod.monthly; // Changed to enum
  String errorMessage = '';
  bool isLoading = false;
  int _selectedTabIndex = 0;
  
  final List<String> colors = [
    'blanco', 'negro', 'gris', 'plateado', 'rojo', 
    'azul', 'verde', 'amarillo', 'naranja',
  ];

  @override
  void initState() {
    super.initState();
    // Establecer valores por defecto
    _setDefaultValues();
  }

  void _setDefaultValues() {
    // Establecer fecha actual como valor por defecto para reservas
    final now = DateTime.now();
    final formattedDate = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} - ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    reservationDateController.text = formattedDate;
    
    // Establecer duración por defecto de 1 hora para reservas
    reservationDurationController.text = '1';
    
    // Establecer fecha actual como valor por defecto para suscripciones
    final formattedSubscriptionDate = '${now.day}/${now.month}/${now.year}';
    subscriptionStartDateController.text = formattedSubscriptionDate;
  }

  @override
  void dispose() {
    plateController.dispose();
    ownerNameController.dispose();
    documentController.dispose();
    phoneController.dispose();
    reservationDateController.dispose();
    reservationDurationController.dispose();
    subscriptionNameController.dispose();
    subscriptionDocumentController.dispose();
    subscriptionStartDateController.dispose(); // Nuevo controlador
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Ajustar para el teclado en móvil
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildTabButton(context, 'Entrada', Icons.login_rounded, 0),
                    _buildTabButton(context, 'Reserva', Icons.calendar_month_rounded, 1),
                    _buildTabButton(context, 'Suscripción', Icons.card_membership_rounded, 2),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  Icon(
                    _selectedTabIndex == 0 ? Icons.login_rounded :
                    _selectedTabIndex == 1 ? Icons.calendar_month_rounded : 
                                          Icons.card_membership_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedTabIndex == 0 ? 'Registrar entrada' :
                          _selectedTabIndex == 1 ? 'Crear reserva' : 'Crear suscripción',
                          style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text('Espacio ${widget.spot.label}',
                          style: TextStyle(
                            fontSize: 12, color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            if (errorMessage.isNotEmpty)
              Container(
                margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: _selectedTabIndex == 0
                      ? _buildEntryTab()
                      : _selectedTabIndex == 1
                          ? _buildReservationTab()
                          : _buildSubscriptionTab(),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isLoading ? null : _handleSubmit,
                  child: isLoading
                      ? const SizedBox(
                          height: 18, width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white,
                          ),
                        )
                      : Text(_selectedTabIndex == 0 ? 'Registrar entrada' :
                            _selectedTabIndex == 1 ? 'Crear reserva' : 'Crear suscripción'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Maneja el envío del formulario según la pestaña seleccionada
  Future<void> _handleSubmit() async {
    if (_selectedTabIndex == 0) {
      await _handleEntrySubmit();
    } else if (_selectedTabIndex == 1) {
      await _handleReservationSubmit();
    } else {
      await _handleSubscriptionSubmit();
    }
  }

  // Maneja el registro de entrada de vehículo
  Future<void> _handleEntrySubmit() async {
    if (plateController.text.isEmpty) {
      setState(() => errorMessage = 'Ingrese la placa del vehículo');
      return;
    }

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
      
      final vehicleService = AppStateContainer.di(context).resolve<VehicleService>();

      // Verificar el estado del vehículo por placa
      try {
        final vehicle = await vehicleService.getVehicleByPlate(
          parkingId, 
          plateController.text.toUpperCase()
        );

        // Si el vehículo tiene algún estado especial (acceso, reserva o suscripción)
        final hasActiveAccess = vehicle.access != null;
        final hasReservation = vehicle.reservation != null;
        final hasSubscription = vehicle.subscription != null;
        
        if (hasActiveAccess) {
          // Si ya tiene un acceso activo, mostrar mensaje de error
          setState(() {
            isLoading = false;
            errorMessage = 'Este vehículo ya está registrado en el espacio ${vehicle.access!.spotName}';
          });
          return;
        } else if (hasReservation || hasSubscription) {
          setState(() {
            isLoading = false;
          });
          
          if (!mounted) return;
          
          // Mostrar diálogo con información del vehículo (solo para reservas o suscripciones)
          final shouldContinue = await VehicleStatusDialog.show(
            context: context,
            vehicle: vehicle,
            plate: plateController.text.toUpperCase(),
            onContinue: () {
              // Esta función se ejecuta cuando el usuario decide continuar
              _processEntryBasedOnVehicle(vehicle);
            },
          );
          
          // Si el usuario canceló, no continuar
          if (shouldContinue != true) {
            return;
          }
          
          // El procesamiento continúa en _processEntryBasedOnVehicle
          return;
        }
      } catch (e) {
        print(e);
      }
      
      // Si no tiene estado especial, continuar con el registro normal
      await _registerNormalEntry(parkingId);
      
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }
  
  // Procesa la entrada según el estado del vehículo
  Future<void> _processEntryBasedOnVehicle(VehicleModel vehicle) async {
    setState(() {
      isLoading = true;
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
      AccessModel entry;
      
      // Determinar el tipo de entrada a registrar
      if (vehicle.subscription != null) {
        // Registrar entrada con suscripción
        final subscriptionId = vehicle.subscription!.id;
        entry = await accessService.registerSubscribedEntry(subscriptionId);
      } else if (vehicle.reservation != null) {
        // Registrar entrada con reserva
        final reservationId = vehicle.reservation!.id;
        entry = await accessService.registerReservedEntry(reservationId);
      } else {
        // Registrar entrada normal (aunque tenga un acceso activo)
        await _registerNormalEntry(parkingId);
        return;
      }
      
      // Actualizar el spot con los datos devueltos por la API
      _updateSpotWithAccessData(entry);
      
      if (!mounted) return;
      
      // Cerrar el modal
      Navigator.pop(context);
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Entrada registrada para ${entry.vehicle.plate}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      
      // Imprimir ticket de entrada
      final printService = AppStateContainer.di(context).resolve<PrintService>();
      await printService.printEntryTicket(
        plate: entry.vehicle.plate,
        spotLabel: widget.spot.label,
        entryTime: entry.entryTime,
        vehicleType: entry.vehicle.type ?? '',
        color: entry.vehicle.color ?? 'No especificado',
        parkingName: appState.currentParking?.name ?? 'Estacionamiento',
        ownerName: entry.vehicle.ownerName,
        ownerDocument: entry.vehicle.ownerDocument,
        context: context,
      );
      
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }
  
  // Registra una entrada normal
  Future<void> _registerNormalEntry(String parkingId) async {
    final appState = AppStateContainer.of(context);
    final accessService = AppStateContainer.di(context).resolve<AccessService>();
    
    final accessCreateModel = AccessCreateModel(
      parkingId: parkingId,
      spotId: widget.spot.id,
      ownerName: ownerNameController.text.isNotEmpty ? ownerNameController.text : null,
      ownerDocument: documentController.text.isNotEmpty ? documentController.text : null,
      ownerPhone: phoneController.text.isNotEmpty ? phoneController.text : null,
      vehiclePlate: plateController.text.toUpperCase(),
      vehicleType: vehicleType,
      vehicleColor: selectedColor,
      areaId: appState.selectedAreaId ?? '',
    );
    
    final entry = await accessService.registerEntry(accessCreateModel);
    
    // Actualizar el spot con los datos devueltos por la API
    _updateSpotWithAccessData(entry);
    
    if (!mounted) return;
    
    // Cerrar el modal
    Navigator.pop(context);
    
    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vehículo ${plateController.text.toUpperCase()} registrado'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
    
    // Imprimir ticket de entrada
    final printService = AppStateContainer.di(context).resolve<PrintService>();
    await printService.printEntryTicket(
      plate: entry.vehicle.plate,
      spotLabel: widget.spot.label,
      entryTime: entry.entryTime,
      vehicleType: entry.vehicle.type,
      color: entry.vehicle.color ?? 'No especificado',
      parkingName: appState.currentParking?.name ?? 'Estacionamiento',
      ownerName: entry.vehicle.ownerName,
      ownerDocument: entry.vehicle.ownerDocument,
      context: context,
    );
  }

  // Maneja la creación de reserva
  Future<void> _handleReservationSubmit() async {
    if (plateController.text.isEmpty || reservationDateController.text.isEmpty) {
      setState(() => errorMessage = 'Complete todos los campos');
      return;
    }
    
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    
    try {
      // Obtener datos de la aplicación
      final appState = AppStateContainer.of(context);
      final parkingId = appState.currentParking?.id;
      final parkingName = appState.currentParking?.name ?? 'Estacionamiento';

      if (parkingId == null) {
        setState(() {
          errorMessage = 'No hay estacionamiento seleccionado';
          isLoading = false;
        });
        return;
      }
      
      // Parsear la fecha de reserva y duración
      final reservationDateParts = reservationDateController.text.split(' - ');
      if (reservationDateParts.length != 2) {
        throw const FormatException('Formato de fecha inválido');
      }
      
      final datePart = reservationDateParts[0].split('/');
      if (datePart.length != 3) {
        throw const FormatException('Formato de fecha inválido');
      }
      
      final timePart = reservationDateParts[1].split(':');
      if (timePart.length != 2) {
        throw const FormatException('Formato de hora inválido');
      }
      
      // Parsear con manejo de errores
      final day = int.tryParse(datePart[0]);
      final month = int.tryParse(datePart[1]);
      final year = int.tryParse(datePart[2]);
      
      // Parsear hora y minuto, manejando formato 12h si es necesario
      String hourStr = timePart[0];
      String minuteStr = timePart[1];
      
      // Si el formato incluye AM/PM, convertirlo a 24h
      bool isPM = false;
      if (minuteStr.contains('PM') || minuteStr.contains('pm')) {
        isPM = true;
        minuteStr = minuteStr.replaceAll(RegExp(r'[Pp][Mm]'), '').trim();
      } else if (minuteStr.contains('AM') || minuteStr.contains('am')) {
        minuteStr = minuteStr.replaceAll(RegExp(r'[Aa][Mm]'), '').trim();
      }
      
      final hour = int.tryParse(hourStr);
      final minute = int.tryParse(minuteStr);
      
      if (day == null || month == null || year == null || hour == null || minute == null) {
        throw const FormatException('Valores de fecha u hora inválidos');
      }
      
      // Convertir a formato 24h si es necesario
      int finalHour = hour;
      if (isPM && hour != 12) {
        finalHour = hour + 12;
      } else if (!isPM && hour == 12) {
        finalHour = 0;
      }
      
      final reservationDate = DateTime(year, month, day, finalHour, minute);
      final durationHours = int.tryParse(reservationDurationController.text) ?? 1;
      
      // Calcular monto basado en duración (ejemplo: $10 por hora)
      final amount = (durationHours * 10.0).toDouble();
      
      // Crear el modelo de reserva
      final reservationCreateModel = ReservationCreateModel(
        ownerName: ownerNameController.text.isNotEmpty ? ownerNameController.text : null,
        ownerPhone: phoneController.text.isNotEmpty ? phoneController.text : null,
        vehicleType: vehicleType,
        vehicleColor: selectedColor,
        parkingId: parkingId,
        ownerDocument: documentController.text.isNotEmpty ? documentController.text : null,
        spotId: widget.spot.id,
        areaId: appState.selectedAreaId ?? '',
        startDate: reservationDate.toIso8601String(),
        amount: amount,
        vehiclePlate: plateController.text.toUpperCase(),
        durationHours: durationHours,
      );
      
      // Llamar al servicio de reservas
      final reservationService = AppStateContainer.di(context).resolve<ReservationService>();
      final reservationData = await reservationService.registerReservation(reservationCreateModel);
      
      // Actualizar el spot con los datos devueltos por la API
      _updateSpotWithReservationData(reservationData);
      
      // Cerrar el modal
      if (!mounted) return;
      Navigator.pop(context);
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reserva creada para ${plateController.text.toUpperCase()}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      
      // Imprimir ticket de reserva
      final printService = AppStateContainer.di(context).resolve<PrintService>();
      await printService.printReservationTicket(
        plate: plateController.text.toUpperCase(),
        spotLabel: widget.spot.label,
        reservationDate: reservationDate,
        durationHours: durationHours,
        vehicleType: vehicleType,
        parkingName: parkingName,
        ownerName: ownerNameController.text.isNotEmpty ? ownerNameController.text : null,
        ownerDocument: documentController.text.isNotEmpty ? documentController.text : null,
        context: context,
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Error al crear reserva: $e';
        isLoading = false;
      });
    }
  }

  // Función para calcular el monto de suscripción basado en las tarifas del parking
  double _calculateSubscriptionAmount(SubscriptionPeriod period, String vehicleType) {
    final appState = AppStateContainer.of(context);
    final parking = appState.currentParking;
    
    // Si no hay parking o no es ParkingModel completo, usar valores por defecto
    if (parking == null) {
      switch (period) {
        case SubscriptionPeriod.weekly:
          return 50.0;
        case SubscriptionPeriod.monthly:
          return 180.0;
        case SubscriptionPeriod.yearly:
          return 1800.0;
      }
    }
    
    // Intentar obtener las tarifas del parking
    List<RateModel>? rates;
    try {
      // Si es ParkingModel completo, usar las tarifas
      if (parking is ParkingModel) {
        rates = parking.rates;
      }
    } catch (e) {
      // Si no se puede acceder a las tarifas, usar valores por defecto
    }
    
    if (rates == null || rates.isEmpty) {
      // Fallback a valores por defecto si no hay tarifas configuradas
      switch (period) {
        case SubscriptionPeriod.weekly:
          return 50.0;
        case SubscriptionPeriod.monthly:
          return 180.0;
        case SubscriptionPeriod.yearly:
          return 1800.0;
      }
    }
    
    // Mapear el tipo de vehículo a la categoría de tarifa
    int vehicleCategory;
    switch (vehicleType) {
      case 'car':
        vehicleCategory = 2; // Vehículo
        break;
      case 'motorcycle':
        vehicleCategory = 1; // Moto
        break;
      case 'truck':
        vehicleCategory = 3; // Camión
        break;
      default:
        vehicleCategory = 2; // Por defecto vehículo
    }
    
    // Buscar la tarifa correspondiente
    final targetRate = rates.firstWhere(
      (rate) => rate.vehicleCategory == vehicleCategory && rate.isActive,
      orElse: () => rates!.first, // Fallback a la primera tarifa
    );
    
    // Obtener el precio según el período
    switch (period) {
      case SubscriptionPeriod.weekly:
        return targetRate.weekly;
      case SubscriptionPeriod.monthly:
        return targetRate.monthly;
      case SubscriptionPeriod.yearly:
        return targetRate.yearly;
    }
  }

  // Maneja la creación de suscripción
  Future<void> _handleSubscriptionSubmit() async {
    if (plateController.text.isEmpty) {
      setState(() => errorMessage = 'Ingrese la placa del vehículo');
      return;
    }
    
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    
    try {
      // Obtener datos de la aplicación
      final appState = AppStateContainer.of(context);
      final parkingId = appState.currentParking?.id;
      final parkingName = appState.currentParking?.name ?? 'Estacionamiento';

      if (parkingId == null) {
        setState(() {
          errorMessage = 'No hay estacionamiento seleccionado';
          isLoading = false;
        });
        return;
      }
      
      // Calcular fechas de inicio y fin según el tipo de suscripción
      final startDate = subscriptionStartDateController.text.isNotEmpty 
          ? _parseDate(subscriptionStartDateController.text)
          : DateTime.now();
      DateTime endDate;
      
      switch (subscriptionType) {
        case SubscriptionPeriod.weekly:
          endDate = startDate.add(const Duration(days: 7));
          break;
        case SubscriptionPeriod.monthly:
          endDate = DateTime(startDate.year, startDate.month + 1, startDate.day);
          break;
        case SubscriptionPeriod.yearly:
          endDate = DateTime(startDate.year + 1, startDate.month, startDate.day);
          break;
      }
      
      // Calcular el monto basado en las tarifas del parking
      final amount = _calculateSubscriptionAmount(subscriptionType, vehicleType);
      
      // Crear el modelo de suscripción
      final subscriptionCreateModel = SubscriptionCreateModel(
        ownerName: subscriptionNameController.text.isNotEmpty ? subscriptionNameController.text : null,
        ownerPhone: phoneController.text.isNotEmpty ? phoneController.text : null,
        vehicleType: vehicleType,
        vehicleColor: selectedColor,
        parkingId: parkingId,
        ownerDocument: subscriptionDocumentController.text.isNotEmpty ? subscriptionDocumentController.text : null,
        spotId: widget.spot.id,
        areaId: appState.selectedAreaId ?? '',
        startDate: startDate.toIso8601String(),
        amount: amount,
        vehiclePlate: plateController.text.toUpperCase(),
        period: subscriptionType,
      );
      
      // Llamar al servicio de suscripciones
      final subscriptionService = AppStateContainer.di(context).resolve<SubscriptionService>();
      final subscription = await subscriptionService.registerSubscription(subscriptionCreateModel);
      
      // Actualizar el spot con los datos devueltos por la API
      _updateSpotWithSubscriptionData(subscription);
      
      // Cerrar el modal
      if (!mounted) return;
      Navigator.pop(context);
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Suscripción ${subscriptionType.name} creada para ${plateController.text.toUpperCase()}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      
      // Imprimir recibo de suscripción
      final printService = AppStateContainer.di(context).resolve<PrintService>();
      await printService.printSubscriptionReceipt(
        plate: plateController.text.toUpperCase(),
        subscriptionType: subscriptionType.name,
        startDate: startDate,
        endDate: endDate,
        amount: amount,
        parkingName: parkingName,
        ownerName: subscriptionNameController.text.isNotEmpty ? subscriptionNameController.text : null,
        ownerDocument: subscriptionDocumentController.text.isNotEmpty ? subscriptionDocumentController.text : null,
        context: context,
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Error al crear suscripción: $e';
        isLoading = false;
      });
    }
  }

  // Función auxiliar para parsear la fecha
  DateTime _parseDate(String dateString) {
    final parts = dateString.split('/');
    if (parts.length != 3) {
      throw FormatException('Formato de fecha inválido: $dateString');
    }
    
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    
    if (day == null || month == null || year == null) {
      throw FormatException('Valores de fecha inválidos: $dateString');
    }
    
    return DateTime(year, month, day);
  }

  // Construye el botón para una pestaña
  Widget _buildTabButton(BuildContext context, String text, IconData icon, int index) {
    final isSelected = index == _selectedTabIndex;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14,
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Construir el contenido de la pestaña de entrada
  Widget _buildEntryTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de placa con botón de verificación
        _buildPlateField(
          plateController: plateController,
          onVerifyPressed: () => _searchVehicle(
            plateController, ownerNameController, documentController, phoneController),
          autofocus: true,
        ),
        const SizedBox(height: 16),
        
        // Sección de información del propietario
        _buildOwnerInfoSection(
          nameController: ownerNameController,
          documentController: documentController,
          phoneController: phoneController,
        ),
        const SizedBox(height: 16),

        // Sección de información del vehículo
        _buildVehicleInfoSection(),
      ],
    );
  }

  // Construir el contenido de la pestaña de reserva
  Widget _buildReservationTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de placa con botón de verificación
        _buildPlateField(
          plateController: plateController,
          onVerifyPressed: () => _searchVehicle(
            plateController, ownerNameController, documentController, phoneController),
        ),
        const SizedBox(height: 16),

        // Sección de detalles de reserva
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Detalles de reserva',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 44, // Reducido de 48 a 44
                child: TextField(
                  controller: reservationDateController,
                  readOnly: true,
                  onTap: () async {
                    final now = DateTime.now();
                    final date = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 90)),
                    );
                    
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      
                      if (time != null) {
                        final dateTime = DateTime(
                          date.year, date.month, date.day, time.hour, time.minute,
                        );
                        
                        setState(() {
                          // Usar formato estándar: DD/MM/YYYY - HH:MM
                          reservationDateController.text = 
                            '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} - ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                        });
                      }
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Fecha y hora *',
                    hintText: 'Seleccionar',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.calendar_today, size: 16),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 44, // Reducido de 48 a 44
                child: TextField(
                  controller: reservationDurationController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Duración (horas)',
                    hintText: '2',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.timer, size: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Sección de información del propietario
        _buildOwnerInfoSection(
          nameController: ownerNameController,
          documentController: documentController,
          phoneController: phoneController,
        ),
        const SizedBox(height: 16),

        // Sección de información del vehículo
        _buildVehicleInfoSection(),
      ],
    );
  }

  // Construir el contenido de la pestaña de suscripción
  Widget _buildSubscriptionTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de placa con botón de verificación
        _buildPlateField(
          plateController: plateController,
          onVerifyPressed: () => _searchVehicle(
            plateController, subscriptionNameController, subscriptionDocumentController, phoneController),
        ),
        const SizedBox(height: 16),

        // Sección de detalles de suscripción
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.card_membership_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Detalles de suscripción',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Text('Tipo de suscripción',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildSubscriptionTypeChip(SubscriptionPeriod.weekly, 'Semanal', Icons.date_range),
                    _buildSubscriptionTypeChip(SubscriptionPeriod.monthly, 'Mensual', Icons.calendar_month),
                    _buildSubscriptionTypeChip(SubscriptionPeriod.yearly, 'Anual', Icons.calendar_today),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 44,
                child: TextField(
                  controller: subscriptionStartDateController,
                  readOnly: true,
                  onTap: () async {
                    final now = DateTime.now();
                    final date = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 365)),
                    );
                    
                    if (date != null) {
                      setState(() {
                        subscriptionStartDateController.text = 
                          '${date.day}/${date.month}/${date.year}';
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Fecha de inicio',
                    hintText: 'Seleccionar',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.calendar_today, size: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Precio:', style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    Text(
                      '\$${_calculateSubscriptionAmount(subscriptionType, vehicleType).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Sección de información del propietario
        _buildOwnerInfoSection(
          nameController: subscriptionNameController,
          documentController: subscriptionDocumentController,
          phoneController: phoneController,
        ),
        const SizedBox(height: 16),

        // Sección de información del vehículo
        _buildVehicleInfoSection(),
      ],
    );
  }

  // Widget para los chips de tipo de vehículo
  Widget _buildVehicleTypeChip(String value, String label, IconData icon) {
    final isSelected = value == vehicleType;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () => setState(() => vehicleType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.5),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para los chips de tipo de suscripción
  Widget _buildSubscriptionTypeChip(SubscriptionPeriod value, String label, IconData icon) {
    final isSelected = value == subscriptionType;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () => setState(() => subscriptionType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.5),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para los chips de color
  Widget _buildColorChip(String color) {
    final isSelected = color == selectedColor;
    final colorScheme = Theme.of(context).colorScheme;
    
    // Función para convertir el nombre del color a un objeto Color de Flutter
    Color getColorFromName(String colorName) {
      switch (colorName) {
        case 'blanco': return Colors.white;
        case 'negro': return Colors.black;
        case 'gris': return Colors.grey;
        case 'plateado': return Colors.grey.shade300;
        case 'rojo': return Colors.red;
        case 'azul': return Colors.blue;
        case 'verde': return Colors.green;
        case 'amarillo': return Colors.yellow;
        case 'naranja': return Colors.orange;
        default: return Colors.grey;
      }
    }

    final displayColor = getColorFromName(color);
    final isDark = ThemeData.estimateBrightnessForColor(displayColor) == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => selectedColor = color),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12, height: 12,
              decoration: BoxDecoration(
                color: displayColor,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: isDark ? Colors.white30 : Colors.black12, width: 1),
              ),
            ),
            const SizedBox(width: 4),
            Text(color, style: TextStyle(
                fontSize: 11,
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  /// Buscar vehículo por placa
  Future<void> _searchVehicle(
    TextEditingController plateController,
    TextEditingController nameController,
    TextEditingController documentController,
    TextEditingController phoneController,
  ) async {
    if (plateController.text.isEmpty) {
      setState(() => errorMessage = 'Ingrese una placa para buscar');
      return;
    }
    
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
      
      final vehicleService = AppStateContainer.di(context).resolve<VehicleService>();
      final plate = plateController.text.toUpperCase();
      
      // Verificar el estado del vehículo por placa
      final vehicle = await vehicleService.getVehicleByPlate(parkingId, plate);
      
      setState(() {
        isLoading = false;
      });
      
      // Si el vehículo tiene algún estado especial, mostrar el diálogo
      final hasActiveAccess = vehicle.access != null;
      final hasReservation = vehicle.reservation != null;
      final hasSubscription = vehicle.subscription != null;
      
      if (hasActiveAccess) {
        // Si ya tiene un acceso activo, mostrar mensaje de error
        setState(() {
          errorMessage = 'Este vehículo ya está registrado en el espacio ${vehicle.access!.spotName}';
        });
        return;
      } else if (hasReservation || hasSubscription) {
        if (!mounted) return;
        
        // Mostrar diálogo con información del vehículo (solo para reservas o suscripciones)
        await VehicleStatusDialog.show(
          context: context,
          vehicle: vehicle,
          plate: plate,
          onContinue: () {
            // Llenar los campos con la información del vehículo
            _fillVehicleInfo(vehicle);
          },
        );
        return;
      }
      
      // Si se encontró el vehículo pero no tiene acceso, reserva o suscripción,
      // llenar los campos con la información disponible
      if (vehicle.id.isNotEmpty) {
        _fillVehicleInfo(vehicle);
        return;
      }
      
      // Si no se encontró información, mostrar mensaje
      setState(() {
        errorMessage = 'No se encontró información para la placa $plate';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al buscar vehículo: $e';
        isLoading = false;
      });
    }
  }
  
  /// Llena los campos con la información del vehículo
  void _fillVehicleInfo(VehicleModel vehicle) {
    setState(() {
      // Llenar datos del propietario
      if (vehicle.ownerName != null) {
        ownerNameController.text = vehicle.ownerName!;
      }
      
      if (vehicle.ownerDocument != null) {
        documentController.text = vehicle.ownerDocument!;
      }
      
      if (vehicle.ownerPhone != null) {
        phoneController.text = vehicle.ownerPhone!;
      }
      
      // Actualizar tipo de vehículo y color si están disponibles
      if (vehicle.type != null) {
        vehicleType = vehicle.type!;
      }
      
      if (vehicle.color != null) {
        selectedColor = vehicle.color!;
      }
    });
  }

  // Widget reutilizable para la información del propietario
  Widget _buildOwnerInfoSection({
    required TextEditingController nameController,
    required TextEditingController documentController,
    required TextEditingController phoneController,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Información del propietario (Opcional)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Campo de nombre del propietario
          SizedBox(
            height: 44,
            child: TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Nombre',
                hintText: 'Juan Pérez',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.person, size: 16),
              ),
            ),
          ),
          const SizedBox(height: 10),
          
          // Documento y teléfono en dos columnas
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: TextField(
                    controller: documentController,
                    decoration: InputDecoration(
                      labelText: 'Documento',
                      hintText: '12345678',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.badge, size: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Teléfono',
                      hintText: '3001234567',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.phone, size: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget reutilizable para la información del vehículo
  Widget _buildVehicleInfoSection({bool showColors = true}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.directions_car_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Información del vehículo',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text('Tipo de vehículo',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildVehicleTypeChip('car', 'Automóvil', Icons.directions_car),
                _buildVehicleTypeChip('motorcycle', 'Motocicleta', Icons.two_wheeler),
                _buildVehicleTypeChip('truck', 'Camioneta', Icons.local_shipping),
              ],
            ),
          ),
          if (showColors) ...[
            const SizedBox(height: 12),

            Text('Color del vehículo',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: colors.map((color) => _buildColorChip(color)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // Widget reutilizable para el campo de placa con botón verificar
  Widget _buildPlateField({
    required TextEditingController plateController,
    required VoidCallback onVerifyPressed,
    bool autofocus = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: TextField(
                controller: plateController,
                autofocus: autofocus,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Placa *',
                  hintText: 'ABC-123',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.directions_car, size: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: onVerifyPressed,
              icon: Icon(
                Icons.search, 
                size: 16,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              label: const Text('Verificar', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Función para actualizar el spot con datos de acceso
  void _updateSpotWithAccessData(AccessModel access) {
    // Crear el modelo de ocupación con los datos del acceso
    final occupancy = ElementOccupancyModel(
      access: ElementActivityModel(
        id: access.id,
        startDate: access.entryTime.toIso8601String(),
        endDate: access.exitTime?.toIso8601String(),
        vehicle: access.vehicle,
        employee: EmployeePreviewModel(
          id: access.employee.id,
          name: access.employee.name,
          role: access.employee.role,
        ),
        amount: access.amount ?? 0.0,
      ),
      status: 'occupied',
    );

    // Actualizar el spot
    widget.spot.isOccupied = true;
    widget.spot.occupancy = occupancy;
  }

  // Función para actualizar el spot con datos de reserva
  void _updateSpotWithReservationData(ReservationModel reservation) {
    // Crear el modelo de ocupación con los datos de la reserva
    final occupancy = ElementOccupancyModel(
      reservation: ElementActivityModel(
        id: reservation.id,
        startDate: reservation.startDate.toIso8601String(),
        endDate: reservation.endDate.toIso8601String(),
        vehicle: reservation.vehicle,
        employee:reservation.employee,
        amount: reservation.amount,
      ),
      status: 'reserved',
    );

    // Actualizar el spot
    widget.spot.isOccupied = true;
    widget.spot.occupancy = occupancy;
  }

  // Función para actualizar el spot con datos de suscripción
  void _updateSpotWithSubscriptionData(SubscriptionModel subscription) {
    // Crear el modelo de ocupación con los datos de la suscripción
    final occupancy = ElementOccupancyModel(
      subscription: ElementActivityModel(
        id: subscription.id,
        startDate: subscription.startDate.toIso8601String(),
        endDate: subscription.endDate.toIso8601String(),
        vehicle: subscription.vehicle,
        employee: subscription.employee,
        amount: subscription.amount,
      ),
      status: 'subscribed',
    );

    // Actualizar el spot
    widget.spot.isOccupied = true;
    widget.spot.occupancy = occupancy;
  }
} 