import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import '../../models/reservation_model.dart';
import '../../models/level_model.dart';
import '../../models/parking_model.dart';
import '../../services/reservation_service.dart';
import '../../services/notification_service.dart';
import '../../state/app_state_container.dart';

class ReservationScreen extends StatefulWidget {
  final String? parkingId;
  final String? spotId;

  const ReservationScreen({
    super.key,
    this.parkingId,
    this.spotId,
  });

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final ReservationService _reservationService = ReservationService();
  final NotificationService _notificationService = NotificationService();
  
  // Estado
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime? _startTime;
  DateTime? _endTime;
  ParkingModel? _selectedParking;
  LevelModel? _selectedLevel;
  SpotModel? _selectedSpot;
  List<SpotModel> _availableSpots = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Controladores
  final TextEditingController _vehiclePlateController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  
  @override
  void dispose() {
    _vehiclePlateController.dispose();
    super.dispose();
  }
  
  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Si se proporcionó un ID de estacionamiento, cargar ese estacionamiento
      if (widget.parkingId != null) {
        // Aquí cargaríamos el estacionamiento desde la API
        // Por ahora, usamos datos de ejemplo
        _selectedParking = ParkingModel(
          id: widget.parkingId!,
          name: 'Estacionamiento Central',
          companyId: 'company1',
          vehicleTypes: [],
          params: ParkingParamsModel(
            currency: 'USD',
            timeZone: 'America/Bogota',
            decimalPlaces: 2,
            theme: 'default',
          ),
          prices: [],
          subscriptionPlans: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // Cargar niveles del estacionamiento seleccionado
        await _loadLevels();
      }
      
      // Si se proporcionó un ID de espacio, seleccionarlo
      if (widget.spotId != null) {
        // Aquí cargaríamos el espacio desde la API
        // Por ahora, usamos datos de ejemplo
        _selectedSpot = SpotModel(
          id: widget.spotId!,
          name: 'A-01',
          posX: 0,
          posY: 0,
          posZ: 0,
          rotation: 0,
          scale: 1,
        );
      }
      
      // Inicializar horarios predeterminados
      final now = DateTime.now();
      _startTime = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour + 1,
        0,
      );
      _endTime = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour + 2,
        0,
      );
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar datos: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadLevels() async {
    if (_selectedParking == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Aquí cargaríamos los niveles desde la API
      // Por ahora, usamos datos de ejemplo
      final levels = [
        LevelModel(
          id: 'level1',
          name: 'Piso 1',
          parkingId: _selectedParking!.id,
          spots: [],
        ),
        LevelModel(
          id: 'level2',
          name: 'Piso 2',
          parkingId: _selectedParking!.id,
          spots: [],
        ),
      ];
      
      setState(() {
        _selectedLevel = levels.isNotEmpty ? levels.first : null;
      });
      
      // Si ya tenemos un nivel seleccionado, cargar espacios disponibles
      if (_selectedLevel != null && _startTime != null && _endTime != null) {
        await _loadAvailableSpots();
      }
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar niveles: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadAvailableSpots() async {
    if (_selectedParking == null || _selectedLevel == null || _startTime == null || _endTime == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Cargar espacios disponibles para el rango de fechas seleccionado
      final spots = await _reservationService.getAvailableSpots(
        _selectedParking!.id,
        _selectedLevel!.id,
        _startTime!,
        _endTime!,
      );
      
      setState(() {
        _availableSpots = spots;
        
        // Si solo hay un espacio disponible, seleccionarlo automáticamente
        if (spots.length == 1) {
          _selectedSpot = spots.first;
        }
        // Si ya teníamos un espacio seleccionado, verificar si sigue disponible
        else if (_selectedSpot != null) {
          final stillAvailable = spots.any((spot) => spot.id == _selectedSpot!.id);
          if (!stillAvailable) {
            _selectedSpot = null;
          }
        }
      });
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar espacios disponibles: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _createReservation() async {
    if (_selectedParking == null || _selectedSpot == null || _startTime == null || _endTime == null) {
      setState(() {
        _errorMessage = 'Por favor, complete todos los campos requeridos';
      });
      return;
    }
    
    if (_vehiclePlateController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, ingrese la placa del vehículo';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Obtener el usuario actual desde el estado de la aplicación
      final appState = AppStateContainer.of(context);
      final user = appState.user;
      
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }
      
      // Crear la reserva
      final reservation = await _reservationService.createReservationWithNotification(
        number: DateTime.now().millisecondsSinceEpoch % 10000, // Número de reserva temporal
        parkingId: _selectedParking!.id,
        employeeId: user.id,
        vehicleId: _vehiclePlateController.text, // Temporal, debería ser un ID real
        spotId: _selectedSpot!.id,
        startDate: _startTime!,
        endDate: _endTime!,
        amount: 0.0, // El precio se calcularía en el backend
      );
      
      if (reservation != null) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reserva creada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Volver a la pantalla anterior
        Navigator.pop(context, true);
      } else {
        throw Exception('No se pudo crear la reserva');
      }
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al crear la reserva: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservar Estacionamiento'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mensaje de error (si existe)
                  if (_errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      margin: const EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                  
                  // Sección de calendario
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selecciona una fecha',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16.0),
                          TableCalendar(
                            firstDay: DateTime.now(),
                            lastDay: DateTime.now().add(const Duration(days: 30)),
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                            calendarFormat: CalendarFormat.twoWeeks,
                            availableCalendarFormats: const {
                              CalendarFormat.twoWeeks: 'Dos semanas',
                              CalendarFormat.month: 'Mes',
                            },
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                                
                                // Actualizar horas de inicio y fin
                                _startTime = DateTime(
                                  selectedDay.year,
                                  selectedDay.month,
                                  selectedDay.day,
                                  _startTime?.hour ?? DateTime.now().hour + 1,
                                  _startTime?.minute ?? 0,
                                );
                                
                                _endTime = DateTime(
                                  selectedDay.year,
                                  selectedDay.month,
                                  selectedDay.day,
                                  _endTime?.hour ?? DateTime.now().hour + 2,
                                  _endTime?.minute ?? 0,
                                );
                                
                                // Recargar espacios disponibles
                                _loadAvailableSpots();
                              });
                            },
                            headerStyle: HeaderStyle(
                              titleCentered: true,
                              formatButtonDecoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              formatButtonTextStyle: TextStyle(color: colorScheme.primary),
                            ),
                            calendarStyle: CalendarStyle(
                              todayDecoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16.0),
                  
                  // Sección de horario
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selecciona el horario',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16.0),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    DatePicker.showTimePicker(
                                      context,
                                      showTitleActions: true,
                                      onConfirm: (time) {
                                        setState(() {
                                          _startTime = DateTime(
                                            _selectedDay.year,
                                            _selectedDay.month,
                                            _selectedDay.day,
                                            time.hour,
                                            time.minute,
                                          );
                                          
                                          // Si la hora de fin es anterior a la de inicio, ajustarla
                                          if (_endTime != null && _endTime!.isBefore(_startTime!)) {
                                            _endTime = _startTime!.add(const Duration(hours: 1));
                                          }
                                          
                                          // Recargar espacios disponibles
                                          _loadAvailableSpots();
                                        });
                                      },
                                      currentTime: _startTime ?? DateTime.now(),
                                      locale: LocaleType.es,
                                    );
                                  },
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Hora de inicio',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      suffixIcon: const Icon(Icons.access_time),
                                    ),
                                    child: Text(
                                      _startTime != null
                                          ? DateFormat('HH:mm').format(_startTime!)
                                          : 'Seleccionar',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    DatePicker.showTimePicker(
                                      context,
                                      showTitleActions: true,
                                      onConfirm: (time) {
                                        setState(() {
                                          _endTime = DateTime(
                                            _selectedDay.year,
                                            _selectedDay.month,
                                            _selectedDay.day,
                                            time.hour,
                                            time.minute,
                                          );
                                          
                                          // Si la hora de fin es anterior a la de inicio, ajustar la de inicio
                                          if (_startTime != null && _endTime!.isBefore(_startTime!)) {
                                            _startTime = _endTime!.subtract(const Duration(hours: 1));
                                          }
                                          
                                          // Recargar espacios disponibles
                                          _loadAvailableSpots();
                                        });
                                      },
                                      currentTime: _endTime ?? DateTime.now().add(const Duration(hours: 1)),
                                      locale: LocaleType.es,
                                    );
                                  },
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Hora de fin',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      suffixIcon: const Icon(Icons.access_time),
                                    ),
                                    child: Text(
                                      _endTime != null
                                          ? DateFormat('HH:mm').format(_endTime!)
                                          : 'Seleccionar',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16.0),
                  
                  // Sección de nivel de estacionamiento
                  if (_selectedParking != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nivel de estacionamiento',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16.0),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Selecciona un nivel',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              value: _selectedLevel?.id,
                              items: const [
                                DropdownMenuItem(
                                  value: 'level1',
                                  child: Text('Piso 1'),
                                ),
                                DropdownMenuItem(
                                  value: 'level2',
                                  child: Text('Piso 2'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedLevel = LevelModel(
                                      id: value,
                                      name: value == 'level1' ? 'Piso 1' : 'Piso 2',
                                      parkingId: _selectedParking!.id,
                                      spots: [],
                                    );
                                    _selectedSpot = null;
                                    _loadAvailableSpots();
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 16.0),
                  
                  // Sección de espacios disponibles
                  if (_availableSpots.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Espacios disponibles',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16.0),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: _availableSpots.map((spot) {
                                final isSelected = _selectedSpot?.id == spot.id;
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedSpot = spot;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? colorScheme.primary
                                          : colorScheme.surface,
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(
                                        color: isSelected
                                            ? colorScheme.primary
                                            : colorScheme.outline,
                                      ),
                                    ),
                                    child: Text(
                                      spot.name,
                                      style: TextStyle(
                                        color: isSelected
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSurface,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_selectedLevel != null && !_isLoading)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'No hay espacios disponibles en el horario seleccionado',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 16.0),
                  
                  // Sección de datos del vehículo
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Datos del vehículo',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            controller: _vehiclePlateController,
                            decoration: InputDecoration(
                              labelText: 'Placa del vehículo',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              prefixIcon: const Icon(Icons.directions_car),
                            ),
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24.0),
                  
                  // Botón de reserva
                  SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: ElevatedButton(
                      onPressed: _selectedSpot != null ? _createReservation : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Confirmar Reserva'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}