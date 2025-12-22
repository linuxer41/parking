import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

import 'enums.dart';
import 'parking_elements.dart';
import '../../models/parking_model.dart';

/// Clase que representa un espacio de estacionamiento
class ParkingSpot extends ParkingElement {
  // Tipo de espacio (auto, moto, camión)
  final SpotType type;

  // Estado de selección
  bool _isSelected = false;

  // Estado de destacado (highlight)
  bool _isHighlighted = false;

  // Animación para el efecto de selección
  double _pulseValue = 0.0;
  Timer? _pulseTimer;

  // Animación para el efecto de destacado
  double _highlightPulseValue = 0.0;
  Timer? _highlightPulseTimer;

  // Métodos para actualizar el tipo y categoría
  void updateType(SpotType newType) {
    // No podemos cambiar directamente el valor porque type es final
    // Pero podemos notificar a los listeners para que se redibuje con el nuevo tipo
    print("Actualizando tipo de $type a $newType");

    // Crear una copia del elemento con el nuevo tipo
    final newSpot = ParkingSpot(
      id: id,
      position: vector_math.Vector2(position.x, position.y),
      type: newType,
      label: label,
      isOccupied: isOccupied,
      rotation: rotation,
      scale: scale,
      isVisible: isVisible,
      isLocked: isLocked,
      entry: _entry,
      booking: _booking,
      subscription: _subscription,
      status: _status,
    );

    // Esta función debe ser llamada desde un contexto donde se tenga acceso a ParkingMapState
    // El ParkingMapState debe actualizar este elemento usando updateElement(this, newSpot)
    notifyListeners();
  }

  // Etiqueta para mostrar en el UI
  @override
  final String label;

  // Estado de ocupación
  bool _isOccupied;
  ElementOccupancyInfoModel? _entry;
  ElementOccupancyInfoModel? _booking;
  ElementOccupancyInfoModel? _subscription;
  String _status;

  // Variables para el temporizador de actualización
  Timer? _updateTimer;
  final String _formattedTime = "";

  // Detiene el temporizador de actualización
  void _stopUpdateTimer() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  // Variable para almacenar el tiempo transcurrido
  Duration _elapsedTime = Duration.zero;

  bool isActive;

  // Constructor
  ParkingSpot({
    required super.id,
    required super.position,
    required this.type,
    required this.label,
    bool isOccupied = false,
    super.rotation,
    super.scale,
    super.isVisible,
    super.isLocked,
    super.isSelected,
    ElementOccupancyInfoModel? entry,
    ElementOccupancyInfoModel? booking,
    ElementOccupancyInfoModel? subscription,
    String status = 'available',
    this.isActive = true,
  }) : _isOccupied = isOccupied,
       _entry = entry,
       _booking = booking,
       _subscription = subscription,
       _status = status {
    // Iniciar el temporizador si el spot está ocupado
    _updateElapsedTime();
    if (_isOccupied && _entry != null) {
      _startUpdateTimer();
    }
  }

  @override
  bool get isSelected => _isSelected;

  @override
  set isSelected(bool value) {
    if (value == _isSelected) return;
    _isSelected = value;

    // Iniciar o detener la animación de pulso
    if (_isSelected) {
      _startPulseAnimation();
    } else {
      _stopPulseAnimation();
    }
  }

  // Getter y setter para el estado de destacado
  bool get isHighlighted => _isHighlighted;
  set isHighlighted(bool value) {
    if (value == _isHighlighted) return;
    _isHighlighted = value;

    // Iniciar o detener la animación de destacado
    if (_isHighlighted) {
      _startHighlightAnimation();
    } else {
      _stopHighlightAnimation();
    }
  }

  // Inicia la animación de pulso
  void _startPulseAnimation() {
    _pulseValue = 0.0;
    _pulseTimer?.cancel();
    _pulseTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _pulseValue = (_pulseValue + 0.05) % 1.0;
      notifyListeners();
    });
  }

  // Detiene la animación de pulso
  void _stopPulseAnimation() {
    _pulseTimer?.cancel();
    _pulseTimer = null;
    _pulseValue = 0.0;
  }

  // Inicia la animación de destacado
  void _startHighlightAnimation() {
    _highlightPulseValue = 0.0;
    _highlightPulseTimer?.cancel();
    _highlightPulseTimer = Timer.periodic(const Duration(milliseconds: 60), (
      timer,
    ) {
      _highlightPulseValue = (_highlightPulseValue + 0.05) % 1.0;
      notifyListeners();
    });
  }

  // Detiene la animación de destacado
  void _stopHighlightAnimation() {
    _highlightPulseTimer?.cancel();
    _highlightPulseTimer = null;
    _highlightPulseValue = 0.0;
  }

  @override
  void dispose() {
    _stopPulseAnimation();
    _stopHighlightAnimation();
    _stopUpdateTimer();
    super.dispose();
  }

  // Getters y setters
  bool get isOccupied => _isOccupied;
  set isOccupied(bool value) {
    if (_isOccupied != value) {
      _isOccupied = value;

      // Iniciar o detener el temporizador según el estado de ocupación
      if (_isOccupied && _entry != null) {
        _startUpdateTimer();
      } else {
        _stopUpdateTimer();
      }

      notifyListeners();
    }
  }

  // Getters for occupancy info
  ElementOccupancyInfoModel? get entry => _entry;
  ElementOccupancyInfoModel? get booking => _booking;
  ElementOccupancyInfoModel? get subscription => _subscription;
  String get status => _status;

  // Setters for occupancy info
  set entry(ElementOccupancyInfoModel? value) {
    if (value != _entry) {
      _entry = value;
      notifyListeners();
    }
  }

  set booking(ElementOccupancyInfoModel? value) {
    if (value != _booking) {
      _booking = value;
      notifyListeners();
    }
  }

  set subscription(ElementOccupancyInfoModel? value) {
    if (value != _subscription) {
      _subscription = value;
      notifyListeners();
    }
  }

  set status(String value) {
    if (value != _status) {
      _status = value;
      notifyListeners();
    }
  }

  // Iniciar temporizador para actualizar el tiempo transcurrido
  void _startUpdateTimer() {
    _stopUpdateTimer(); // Asegurarse de que no haya temporizadores duplicados
    _updateElapsedTime(); // Actualizar el tiempo inicial

    // Crear un temporizador que actualice cada segundo
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateElapsedTime();
      notifyListeners(); // Notificar a los listeners para que se redibuje
    });
  }

  // Actualizar el tiempo transcurrido
  void _updateElapsedTime() {
    if (!_isOccupied || _entry == null) {
      _elapsedTime = Duration.zero;
      return;
    }

    try {
      final entryTime = DateTime.parse(_entry!.startDate);
      final now = DateTime.now();
      _elapsedTime = now.difference(entryTime);
    } catch (e) {
      // If parsing fails, use zero duration
      _elapsedTime = Duration.zero;
    }
  }

  // Obtener tiempo de estacionamiento en minutos
  int get parkingTimeMinutes {
    if (!_isOccupied || _entry == null) return 0;
    return _elapsedTime.inMinutes;
  }

  // Obtener tiempo de estacionamiento formateado
  String get formattedParkingTime {
    if (!_isOccupied || _entry == null) return "";

    final hours = _elapsedTime.inHours;
    final minutes = _elapsedTime.inMinutes % 60;
    final seconds = _elapsedTime.inSeconds % 60;

    if (hours > 0) {
      return '$hours h ${minutes.toString().padLeft(2, '0')} m ${seconds.toString().padLeft(2, '0')} s';
    } else if (minutes > 0) {
      return '$minutes m ${seconds.toString().padLeft(2, '0')} s';
    } else {
      return '$seconds s';
    }
  }

  @override
  Size getSize() {
    final visuals = ElementProperties.spotVisuals[type]!;
    return Size(visuals.width, visuals.height);
  }

  @override
  void render(Canvas canvas, dynamic renderer) {
    final Size size = getSize();
    final double width = size.width;
    final double height = size.height;

    // Definir el rectángulo base
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: width,
      height: height,
    );

    // Determinar el color y estado según la ocupación y estado
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (!isActive) {
      statusColor = ElementProperties.gray;
      statusText = "INACTIVO";
      statusIcon = Icons.do_not_disturb_on;
    } else {
      statusColor = _getStatusColor(_status);
      statusText = _getStatusText(_status);
      statusIcon = _getStatusIcon(_status);
    }

    // Dibujar sombra
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.translate(2, 2), const Radius.circular(8)),
      shadowPaint,
    );

    // Gradiente moderno para el fondo del spot
    final Gradient gradient = RadialGradient(
      center: Alignment.center,
      radius: 0.8,
      colors: [
        HSLColor.fromColor(statusColor)
            .withLightness(
              (HSLColor.fromColor(statusColor).lightness + 0.15).clamp(
                0.0,
                1.0,
              ),
            )
            .toColor(),
        statusColor,
        HSLColor.fromColor(statusColor)
            .withLightness(
              (HSLColor.fromColor(statusColor).lightness - 0.1).clamp(0.0, 1.0),
            )
            .toColor(),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final double bgOpacity = isVisible ? 1.0 : 0.5;
    final bgPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(bgOpacity); // Aplica opacidad global
    canvas.saveLayer(rect, Paint());
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      bgPaint,
    );
    canvas.restore();

    // Dibujar borde más fino
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      borderPaint,
    );

    // Dibujar icono de tipo de vehículo
    final typeIcon = _getSpotTypeIcon();
    final iconSize = min(width, height) * 0.18; // Reducido para dejar espacio
    final TextPainter iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(typeIcon.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          fontFamily: typeIcon.fontFamily,
          color: !isVisible ? Colors.white.withOpacity(0.5) : Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        -iconPainter.width / 2,
        -height * 0.35, // Movido más arriba
      ),
    );

    // Dibujar etiqueta del espacio
    final labelStyle = TextStyle(
      color: !isVisible ? Colors.white.withOpacity(0.5) : Colors.white,
      fontSize: min(width, height) * 0.16,
      fontWeight: FontWeight.bold,
    );

    final labelPainter = TextPainter(
      text: TextSpan(text: label, style: labelStyle),
      textDirection: TextDirection.ltr,
    );

    labelPainter.layout();
    labelPainter.paint(
      canvas,
      Offset(
        -labelPainter.width / 2,
        -height * 0.15, // Ajustado para dejar espacio para el estado
      ),
    );

    // Dibujar estado (OCUPADO, LIBRE, etc.)
    final statusStyle = TextStyle(
      color: !isVisible ? Colors.white.withOpacity(0.5) : Colors.white,
      fontSize: min(width, height) * 0.12,
      fontWeight: FontWeight.bold,
    );

    final statusPainter = TextPainter(
      text: TextSpan(text: statusText, style: statusStyle),
      textDirection: TextDirection.ltr,
    );

    statusPainter.layout();
    statusPainter.paint(
      canvas,
      Offset(
        -statusPainter.width / 2,
        height * 0.0, // Centrado
      ),
    );

    // Dibujar icono de estado debajo del texto de estado
    final statusIconSize = min(width, height) * 0.14;
    final statusIconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(statusIcon.codePoint),
        style: TextStyle(
          fontSize: statusIconSize,
          fontFamily: statusIcon.fontFamily,
          color: !isVisible ? Colors.white.withOpacity(0.5) : Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    statusIconPainter.layout();
    statusIconPainter.paint(
      canvas,
      Offset(
        -statusIconPainter.width / 2,
        height * 0.13, // Debajo del texto de estado
      ),
    );

    // Dibujar tiempo transcurrido si está ocupado
    if (_isOccupied && _status == 'occupied') {
      final timeStyle = TextStyle(
        color: !isVisible ? Colors.white.withOpacity(0.5) : Colors.white,
        fontSize: min(width, height) * 0.11,
        fontWeight: FontWeight.w500,
      );

      final timePainter = TextPainter(
        text: TextSpan(text: formattedParkingTime, style: timeStyle),
        textDirection: TextDirection.ltr,
      );

      timePainter.layout();
      timePainter.paint(
        canvas,
        Offset(
          -timePainter.width / 2,
          height * 0.25, // Debajo del icono de estado
        ),
      );

      // Dibujar placa del vehículo si está disponible
      if (_entry != null) {
        final plateStyle = TextStyle(
          color: !isVisible ? Colors.white.withOpacity(0.5) : Colors.white,
          fontSize: min(width, height) * 0.11,
          fontWeight: FontWeight.w600,
          backgroundColor: Colors.black.withOpacity(0.3),
        );

        final platePainter = TextPainter(
          text: TextSpan(text: _entry!.vehiclePlate, style: plateStyle),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );

        platePainter.layout();

        // Dibujar fondo para la placa
        final plateRect = Rect.fromCenter(
          center: Offset(0, height * 0.38),
          width: platePainter.width + 10,
          height: platePainter.height + 4,
        );

        canvas.drawRRect(
          RRect.fromRectAndRadius(plateRect, const Radius.circular(4)),
          Paint()..color = Colors.black.withOpacity(0.5),
        );

        platePainter.paint(
          canvas,
          Offset(
            -platePainter.width / 2,
            height * 0.38 - platePainter.height / 2,
          ),
        );
      }
    }
    // Mostrar placa de vehículo y fechas para spots reservados
    else if (_status == 'reserved' && _booking != null) {
      // Formatear fecha y hora en el nuevo formato
      final dateTimeStart = DateTime.parse(_booking!.startDate);
      final String formattedDate =
          '${dateTimeStart.day}/${dateTimeStart.month}/${dateTimeStart.year}';

      final dateText = formattedDate;
      final timeStyle = TextStyle(
        color: !isVisible ? Colors.white.withOpacity(0.5) : Colors.white,
        fontSize: min(width, height) * 0.08,
        fontWeight: FontWeight.w500,
      );

      final timePainter = TextPainter(
        text: TextSpan(text: dateText, style: timeStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      timePainter.layout();
      timePainter.paint(
        canvas,
        Offset(
          -timePainter.width / 2,
          height * 0.20, // Movido más arriba, antes estaba en height * 0.25
        ),
      );

      // Dibujar placa de vehículo - mismo estilo y posición que para occupied
      final plateStyle = TextStyle(
        color: !isVisible ? Colors.white.withOpacity(0.5) : Colors.white,
        fontSize: min(width, height) * 0.11,
        fontWeight: FontWeight.w600,
        backgroundColor: Colors.black.withOpacity(0.3),
      );

      final platePainter = TextPainter(
        text: TextSpan(text: _booking!.vehiclePlate, style: plateStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      platePainter.layout();

      // Dibujar fondo para la placa - misma posición que occupied
      final plateRect = Rect.fromCenter(
        center: Offset(0, height * 0.38),
        width: platePainter.width + 10,
        height: platePainter.height + 4,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(plateRect, const Radius.circular(4)),
        Paint()..color = Colors.black.withOpacity(0.5),
      );

      platePainter.paint(
        canvas,
        Offset(
          -platePainter.width / 2,
          height * 0.38 - platePainter.height / 2,
        ),
      );
    }
    // Mostrar placa de vehículo y fechas para spots con suscripción
    else if (_status == 'subscribed' && _subscription != null) {
      // Mostrar fechas de inicio
      final startDate = _formatDate(_subscription!.startDate);

      final dateText = "Inicio: $startDate";
      final timeStyle = TextStyle(
        color: !isVisible ? Colors.white.withOpacity(0.5) : Colors.white,
        fontSize: min(width, height) * 0.08,
        fontWeight: FontWeight.w500,
      );

      final timePainter = TextPainter(
        text: TextSpan(text: dateText, style: timeStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      timePainter.layout();
      timePainter.paint(
        canvas,
        Offset(
          -timePainter.width / 2,
          height * 0.20, // Movido más arriba, antes estaba en height * 0.25
        ),
      );

      // Dibujar placa de vehículo - mismo estilo y posición que para occupied
      final plateStyle = TextStyle(
        color: !isVisible ? Colors.white.withOpacity(0.5) : Colors.white,
        fontSize: min(width, height) * 0.11,
        fontWeight: FontWeight.w600,
        backgroundColor: Colors.black.withOpacity(0.3),
      );

      final platePainter = TextPainter(
        text: TextSpan(text: _subscription!.vehiclePlate, style: plateStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      platePainter.layout();

      // Dibujar fondo para la placa - misma posición que occupied
      final plateRect = Rect.fromCenter(
        center: Offset(0, height * 0.38),
        width: platePainter.width + 10,
        height: platePainter.height + 4,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(plateRect, const Radius.circular(4)),
        Paint()..color = Colors.black.withOpacity(0.5),
      );

      platePainter.paint(
        canvas,
        Offset(
          -platePainter.width / 2,
          height * 0.38 - platePainter.height / 2,
        ),
      );
    }

    // Dibujar indicador de selección si está seleccionado
    if (_isSelected) {
      final selectionPaint = Paint()
        ..color = Colors.white.withOpacity(0.5 + _pulseValue * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect.inflate(4 + _pulseValue * 3),
          const Radius.circular(12),
        ),
        selectionPaint,
      );
    }

    // Dibujar indicador de destacado si está destacado
    if (_isHighlighted) {
      // Usar un color dorado/amarillo para el destacado
      final highlightPaint = Paint()
        ..color = Colors.amber.withOpacity(0.3 + _highlightPulseValue * 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect.inflate(5 + _highlightPulseValue * 4),
          const Radius.circular(14),
        ),
        highlightPaint,
      );

      // Añadir un segundo borde más fino para un efecto de brillo
      final glowPaint = Paint()
        ..color = Colors.white.withOpacity(0.2 + _highlightPulseValue * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect.inflate(8 + _highlightPulseValue * 5),
          const Radius.circular(16),
        ),
        glowPaint,
      );
    }
  }

  /// Método auxiliar para dibujar la etiqueta dentro del elemento
  void _renderInternalLabel(Canvas canvas, Rect elementRect) {
    // Crear el área para la etiqueta en la parte inferior del elemento
    final labelRect = Rect.fromLTRB(
      elementRect.left + 4,
      elementRect.bottom - 24,
      elementRect.right - 4,
      elementRect.bottom - 4,
    );

    // Fondo semitransparente para la etiqueta
    final labelBgPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, const Radius.circular(4.0)),
      labelBgPaint,
    );

    // Texto de la etiqueta
    final textSpan = TextSpan(
      text: label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout(maxWidth: labelRect.width - 8);

    // Centrar el texto en el área de etiqueta
    textPainter.paint(
      canvas,
      Offset(
        labelRect.left + (labelRect.width - textPainter.width) / 2,
        labelRect.top + (labelRect.height - textPainter.height) / 2,
      ),
    );
  }

  /// Helper method to get the appropriate color for a spot status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'occupied':
        return ElementProperties.occupiedColor;
      case 'reserved':
        return ElementProperties.reservedColor;
      case 'subscribed':
        return ElementProperties.subscribedColor;
      case 'maintenance':
        return ElementProperties.maintenanceColor;
      case 'inactive':
        return ElementProperties.gray;
      default:
        return ElementProperties.availableColor;
    }
  }

  /// Helper method to get the appropriate icon for a spot status
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'occupied':
        return Icons.car_rental;
      case 'reserved':
        return Icons.bookmark;
      case 'subscribed':
        return Icons.card_membership;
      case 'maintenance':
        return Icons.build;
      case 'inactive':
        return Icons.do_not_disturb_on;
      default:
        return Icons.check_circle;
    }
  }

  /// Helper method to get the appropriate text for a spot status
  String _getStatusText(String status) {
    switch (status) {
      case 'occupied':
        return "OCUPADO";
      case 'reserved':
        return "RESERVADO";
      case 'subscribed':
        return "SUSCRITO";
      case 'maintenance':
        return "MANTENIMIENTO";
      case 'inactive':
        return "INACTIVO";
      default:
        return "DISPONIBLE";
    }
  }

  /// Convierte un nombre de color a un objeto Color
  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'blanco':
        return Colors.white;
      case 'negro':
        return Colors.black87;
      case 'gris':
        return Colors.grey;
      case 'plateado':
        return Colors.grey.shade300;
      case 'rojo':
        return Colors.red;
      case 'azul':
        return Colors.blue;
      case 'verde':
        return Colors.green;
      case 'amarillo':
        return Colors.yellow;
      case 'naranja':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// Obtiene la etiqueta del tipo de espacio
  String _getSpotTypeLabel() {
    switch (type) {
      case SpotType.bicycle:
        return "BICI";
      case SpotType.motorcycle:
        return "MOTO";
      case SpotType.truck:
        return "CAMIÓN";
      default:
        return "AUTO";
    }
  }

  /// Helper method to get the appropriate icon for the spot type
  IconData _getSpotTypeIcon() {
    switch (type) {
      case SpotType.bicycle:
        return Icons.directions_bike;
      case SpotType.motorcycle:
        return Icons.motorcycle;
      case SpotType.truck:
        return Icons.local_shipping;
      default:
        return Icons.directions_car;
    }
  }

  @override
  ParkingElement clone() {
    return ParkingSpot(
      id: '$id-copy',
      position: vector_math.Vector2(position.x, position.y),
      type: type,
      label: '$label-copy',
      isOccupied: _isOccupied,
      rotation: rotation,
      scale: scale,
      isVisible: isVisible,
      isLocked: isLocked,
      entry: _entry,
      booking: _booking,
      subscription: _subscription,
      status: _status,
    )..isHighlighted = _isHighlighted;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': 'spot',
      'spotType': type.toString().split('.').last,
      'label': label,
      'isOccupied': _isOccupied,
      'entry': _entry?.toJson(),
      'booking': _booking?.toJson(),
      'subscription': _subscription?.toJson(),
      'status': _status,
      'position': {'x': position.x, 'y': position.y},
      'rotation': rotation,
      'scale': scale,
      'isVisible': isVisible,
      'isLocked': isLocked,
      'isHighlighted': _isHighlighted,
      'isActive': isActive,
    };
  }

  factory ParkingSpot.fromJson(Map<String, dynamic> json) {
    final spotTypeStr = json['spotType'] as String;

    return ParkingSpot(
      id: json['id'] as String,
      position: vector_math.Vector2(
        (json['position']['x'] as num).toDouble(),
        (json['position']['y'] as num).toDouble(),
      ),
      type: SpotType.values.firstWhere(
        (e) => e.toString().split('.').last == spotTypeStr,
      ),
      label: json['label'] as String,
      isOccupied: json['isOccupied'] as bool,
      entry: json['entry'] != null
          ? ElementOccupancyInfoModel.fromJson(
              json['entry'] as Map<String, dynamic>,
            )
          : null,
      booking: json['booking'] != null
          ? ElementOccupancyInfoModel.fromJson(
              json['booking'] as Map<String, dynamic>,
            )
          : null,
      subscription: json['subscription'] != null
          ? ElementOccupancyInfoModel.fromJson(
              json['subscription'] as Map<String, dynamic>,
            )
          : null,
      status: json['status'] as String? ?? 'available',
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      isVisible: json['isVisible'] as bool? ?? true,
      isLocked: json['isLocked'] as bool? ?? false,
      isSelected: json['isSelected'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    )..isHighlighted = json['isHighlighted'] as bool? ?? false;
  }
}

extension ParkingSpotElementConversion on ParkingSpot {
  // Convertir ParkingSpot a ElementModel
  ElementModel toElementModel() {
    return ElementModel(
      id: id,
      name: label,
      type: ElementType.spot,
      subType: type.index + 1, // Add 1 to match backend schema
      posX: position.x,
      posY: position.y,
      posZ: 0.0,
      scale: scale,
      rotation: rotation,
      isActive: isActive,
      entry: _entry,
      booking: _booking,
      subscription: _subscription,
    );
  }

  // Método estático para crear un ParkingSpot desde un ElementModel
  static ParkingSpot fromElementModel(ElementModel element) {
    return ParkingSpot(
      id: element.id,
      position: vector_math.Vector2(element.posX, element.posY),
      type:
          SpotType.values[(element.subType - 1).clamp(
            0,
            SpotType.values.length - 1,
          )], // Subtract 1 to match enum
      label: element.name,
      isOccupied: element.entry != null,
      entry: element.entry,
      booking: element.booking,
      subscription: element.subscription,
      rotation: element.rotation,
      scale: element.scale,
      isVisible: true,
      isLocked: false,
      isActive: element.isActive,
    );
  }
}

/// Helper method to format a date string to a more user-friendly format
String _formatDate(String dateStr) {
  try {
    final date = DateTime.parse(dateStr);
    return '${date.day}/${date.month}/${date.year}';
  } catch (e) {
    return dateStr;
  }
}
