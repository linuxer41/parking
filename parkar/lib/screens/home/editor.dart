import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../models/level_model.dart';

// ==================== ENUMS Y MODELOS ====================
enum SpotType { vehicle, moto, truck }

enum SpotCategory { vip, normal, special }

enum SignageType { entrance, exit, via, information }

enum FacilityType { elevator, stair, restroom, office }

extension Vector2SnapToGrid on Vector2 {
  Vector2 snapToGrid(double gridSize) {
    return Vector2(
      (x / gridSize).roundToDouble() * gridSize,
      (y / gridSize).roundToDouble() * gridSize,
    );
  }
}

extension CameraWorldToScreen on CameraComponent {
  Vector2 worldToScreen(Vector2 worldPosition) {
    final screenPosition = viewfinder.localToGlobal(worldPosition);
    return screenPosition;
  }
}

extension ParkingObjectType on dynamic {
  String get displayName {
    if (this is SpotType) return _spotDisplayName(this as SpotType);
    if (this is SignageType) return _signageDisplayName(this as SignageType);
    if (this is FacilityType) return _facilityDisplayName(this as FacilityType);
    return '';
  }

  String _spotDisplayName(SpotType type) =>
      const ['Vehículo', 'Moto', 'Camión'][type.index];

  String _signageDisplayName(SignageType type) =>
      const ['Entrada', 'Salida', 'Vía', 'Información'][type.index];

  String _facilityDisplayName(FacilityType type) =>
      const ['Ascensor', 'Escalera', 'Baño', 'Oficina'][type.index];
}

// ==================== COMPONENTE BASE ====================
abstract class ParkingEntity<T> extends PositionComponent
  with DragCallbacks, TapCallbacks, HoverCallbacks {
  final String id;
  final T type;
  double rotation = 0.0;
  bool isSelected = false;
  String label;
  bool isInteractive;

  // Propiedades para la forma y el estilo
  late final Path path;
  late final Color color;
  Paint paint = Paint();
  final Paint borderPaint = Paint()
    ..color = const Color(0xFFffffff)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  ParkingEntity({
    required this.id,
    required Vector2 position,
    required Vector2 size,
    required this.type,
    this.label = '',
    this.isInteractive = true,
  }) : super(position: position, size: size, anchor: Anchor.center, children: [
    RectangleHitbox()
  ],
  );
  

  // Getter y setter para escala uniforme
  double get scaleUniform => scale.x;
  set scaleUniform(double value) => scale.setValues(value, value);

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    priority = 10;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    priority = 0;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
  }

    @override
  bool containsLocalPoint(Vector2 point) {
    return path.contains(point.toOffset());
  }

  @override
  void render(Canvas canvas) {
    if (isDragged) {
      paint.color = color.withValues(alpha: 0.5);
      borderPaint.color = Colors.brown;

      canvas.drawPath(path, paint);
      canvas.drawPath(path, borderPaint);
    } else if (isHovered) {
      paint.color = color.withValues(alpha: 0.25);
      canvas.drawPath(path, paint);
      canvas.drawPath(path, borderPaint);
    } else {
      paint.color = color.withValues(alpha: 1);
      canvas.drawPath(path, paint);
    }
    angle = rotation;
  }

  Map<String, dynamic> toJson();
  void updateFromJson(Map<String, dynamic> json);
}

// ==================== SPOT COMPONENT ====================
class ParkingSpot extends ParkingEntity<SpotType> {
  final SpotCategory category;
  bool isOccupied;
  String? vehiclePlate;
  late Sprite vehicleSprite;
  late TextComponent labelText;

  ParkingSpot({
    required super.id,
    required super.type,
    required this.category,
    required super.position,
    this.isOccupied = false,
    this.vehiclePlate,
    super.label,
  }) : super(size: _getSizeForType(type)) {
    // Definir el path para el spot
    color = _getBaseColor();
    path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: size.x, height: size.y),
          const Radius.circular(8),
        ),
      );

    // Definir el paint para el spot
    paint = Paint()
      ..color = _getCategoryColor()
      ..style = PaintingStyle.fill;
  }

    @override
  Future<void> onLoad() async {
    // Cargar sprite del vehículo
    vehicleSprite = await Sprite.load('spot/Car.png');
    
    // Configurar texto
    labelText = TextComponent(
      text: label,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x / 2, -20),
      anchor: Anchor.center,
    );
    add(labelText);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Dibujar vehículo si está ocupado
    if (isOccupied) {
      vehicleSprite.render(
        canvas,
        position: Vector2(-size.x / 4, -size.y / 4),
        size: Vector2(size.x / 2, size.y / 2),
      );
    }
  }

  static Vector2 _getSizeForType(SpotType type) {
    return switch (type) {
      SpotType.vehicle => Vector2(60, 100),
      SpotType.moto => Vector2(40, 60),
      SpotType.truck => Vector2(80, 150),
    };
  }

  Color _getBaseColor() => switch (type) {
        SpotType.vehicle => const Color(0xFF4A90E2),
        SpotType.moto => const Color(0xFF7ED321),
        SpotType.truck => const Color(0xFFD0021B),
      };

  Color _getCategoryColor() => switch (category) {
        SpotCategory.vip => const Color(0xFFFFD700),
        SpotCategory.normal => const Color(0xFF666666),
        SpotCategory.special => const Color(0xFF9013FE),
      };

  @override
  Map<String, dynamic> toJson() => SpotModel(
        id: id,
        name: label,
        posX: position.x,
        posY: position.y,
        posZ: 0,
        rotation: rotation,
        scale: scaleUniform,
        vehicleId: vehiclePlate,
        spotType: type.index,
        spotCategory: category.index,
      ).toJson();

  @override
  void updateFromJson(Map<String, dynamic> json) {
    final model = SpotModel.fromJson(json);
    position = Vector2(model.posX, model.posY);
    rotation = model.rotation;
    scaleUniform = model.scale;
    label = model.name;
    isOccupied = model.vehicleId != null;
    vehiclePlate = model.vehicleId;
  }
}

// ==================== SIGNAGE COMPONENT ====================
class ParkingSignage extends ParkingEntity<SignageType> {
  final double direction;
  SpriteComponent? iconSprite;

  ParkingSignage({
    required super.id,
    required super.type,
    required super.position,
    required this.direction,
    super.label,
  }) : super(size: Vector2(40, 40)) {
    // Definir el path para el signage
    color = Colors.blueGrey[800]!;
    path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: size.x, height: size.y),
          const Radius.circular(8),
        ),
      );

    // Definir el paint para el signage
    paint = Paint()
      ..color = const Color(0xFF2D3047)
      ..style = PaintingStyle.fill;
  }

  @override
  Map<String, dynamic> toJson() => SignageModel(
        id: id,
        posX: position.x,
        posY: position.y,
        posZ: 0,
        scale: scaleUniform,
        rotation: rotation,
        direction: direction,
        signageType: type.index,
      ).toJson();

  @override
  void updateFromJson(Map<String, dynamic> json) {
    final model = SignageModel.fromJson(json);
    position = Vector2(model.posX, model.posY);
    rotation = model.rotation;
    scaleUniform = model.scale;
  }
}

// ==================== FACILITY COMPONENT ====================
class ParkingFacility extends ParkingEntity<FacilityType> {
  final int floorLevel;
  SpriteComponent? facilityIcon;

  ParkingFacility({
    required super.id,
    required super.type,
    required super.position,
    required this.floorLevel,
    super.label,
  }) : super(size: Vector2(60, 60)) {
    // Definir el path para la instalación
    color = _getFacilityColor();
    path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: size.x, height: size.y),
          const Radius.circular(12),
        ),
      );

    // Definir el paint para la instalación
    paint = Paint()
      ..color = _getFacilityColor()
      ..style = PaintingStyle.fill;
  }

  Color _getFacilityColor() => switch (type) {
        FacilityType.elevator => const Color(0xFF8B572A),
        FacilityType.stair => const Color(0xFF4A4A4A),
        FacilityType.restroom => const Color(0xFF417505),
        FacilityType.office => const Color(0xFF50E3C2),
      };

  @override
  Map<String, dynamic> toJson() => FacilityModel(
        id: id,
        name: label,
        posX: position.x,
        posY: position.y,
        posZ: 0,
        rotation: rotation,
        scale: scaleUniform,
        facilityType: type.index,
      ).toJson();

  @override
  void updateFromJson(Map<String, dynamic> json) {
    final model = FacilityModel.fromJson(json);
    position = Vector2(model.posX, model.posY);
    rotation = model.rotation;
    scaleUniform = model.scale;
    label = model.name;
  }
}

// ==================== SISTEMA DE GRID ====================
class SmartGrid extends Component {
  final double step;
  final CameraComponent camera;
  final Paint _gridPaint = Paint()
    ..color = const Color(0xFFE0E0E0)
    ..strokeWidth = 1;

  SmartGrid({required this.step, required this.camera});

  @override
  void render(Canvas canvas) {
    final visibleArea = camera.visibleWorldRect;

    // Líneas verticales
    for (var x = _getStart(visibleArea.left);
        x <= visibleArea.right;
        x += step) {
      _drawLine(
          canvas, Vector2(x, visibleArea.top), Vector2(x, visibleArea.bottom));
    }

    // Líneas horizontales
    for (var y = _getStart(visibleArea.top);
        y <= visibleArea.bottom;
        y += step) {
      _drawLine(
          canvas, Vector2(visibleArea.left, y), Vector2(visibleArea.right, y));
    }
  }

  double _getStart(double edge) => (edge ~/ step) * step - step;

  void _drawLine(Canvas canvas, Vector2 start, Vector2 end) {
    // final screenStart = camera.viewfinder.worldToScreen(start);
    // final screenEnd = camera.viewfinder.worldToScreen(end);
    final screenStart = camera.worldToScreen(start);
    final screenEnd = camera.worldToScreen(end);

    canvas.drawLine(
      screenStart.toOffset(),
      screenEnd.toOffset(),
      _gridPaint,
    );
  }
}

// ==================== EDITOR GAME ====================
class ParkingEditorGame extends FlameGame  with HasCollisionDetection, KeyboardEvents{
  late final LevelModel level;
  late final SmartGrid grid;
  ParkingEntity? selectedObject; // Ya no es ValueNotifier

  ParkingEditorGame({required this.level});

  @override
  Future onLoad() async {
    camera = CameraComponent()
      ..viewfinder.anchor = Anchor.center
      ..viewfinder.zoom = 1;
    grid = SmartGrid(step: 30, camera: camera);
    addAll([grid, ..._convertModelsToEntities()]);
  }

  List _convertModelsToEntities() {
    return [
      ...level.spots.map((s) => ParkingSpot(
            id: s.id,
            type: SpotType.values[s.spotType],
            category: SpotCategory.values[s.spotCategory],
            position: Vector2(s.posX, s.posY),
            isOccupied: s.vehicleId != null,
            vehiclePlate: s.vehicleId,
            label: s.name,
          )),
      ...level.signages.map((s) => ParkingSignage(
            id: s.id,
            type: SignageType.values[s.signageType],
            position: Vector2(s.posX, s.posY),
            direction: s.direction,
          )),
      ...level.facilities.map((f) => ParkingFacility(
            id: f.id,
            type: FacilityType.values[f.facilityType],
            position: Vector2(f.posX, f.posY),
            floorLevel: 0,
            label: f.name,
          )),
    ];
  }

  void saveChanges() {
    level.spots.clear();
    level.signages.clear();
    level.facilities.clear();

    level.spots.addAll(children
        .whereType<ParkingSpot>()
        .map((s) => SpotModel.fromJson(s.toJson())));
    level.signages.addAll(children
        .whereType<ParkingSignage>()
        .map((s) => SignageModel.fromJson(s.toJson())));
    level.facilities.addAll(children
        .whereType<ParkingFacility>()
        .map((f) => FacilityModel.fromJson(f.toJson())));

    // level.updatedAt = DateTime.now();
    print('Cambios guardados: $level');
  }
}

// ==================== UI DE CONTROLES ====================
class EditorControls extends StatelessWidget {
  final ParkingEditorGame game;
  const EditorControls({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildControlButton(Icons.save, () {
            game.saveChanges(); // Guardar cambios al pulsar el botón
          }),
          if (game.selectedObject != null)
            _buildObjectControls(game.selectedObject!),
          _buildCameraControls(), // Siempre mostrar los controles de la cámara
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback action) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.blueGrey[800]),
        onPressed: action,
      ),
    );
  }

  Widget _buildObjectControls(ParkingEntity entity) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Editar ${entity.type.displayName}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _buildRotationControl(entity),
          const SizedBox(height: 8),
          _buildScaleControl(game),
          const SizedBox(height: 8),
          _buildLabelInput(entity),
        ],
      ),
    );
  }

  Widget _buildCameraControls() {
    return Column(
      children: [
        Row(
          children: [
            _buildControlButton(Icons.zoom_in, () {
              game.camera.viewfinder.zoom =
                  (game.camera.viewfinder.zoom + 0.1).clamp(0.5, 2.0);
            }),
            _buildControlButton(Icons.zoom_out, () {
              game.camera.viewfinder.zoom =
                  (game.camera.viewfinder.zoom - 0.1).clamp(0.5, 2.0);
            }),
          ],
        ),
        Text(
          'Zoom: ${game.camera.viewfinder.zoom.toStringAsFixed(1)}x',
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildRotationControl(ParkingEntity entity) {
    return Row(
      children: [
        const Text('Rotación: '),
        IconButton(
          icon: const Icon(Icons.rotate_left),
          onPressed: () => entity.rotation -= 15,
        ),
        IconButton(
          icon: const Icon(Icons.rotate_right),
          onPressed: () => entity.rotation += 15,
        ),
      ],
    );
  }

  Widget _buildScaleControl(ParkingEditorGame game) {
    return Row(
      children: [
        const Text('Zoom: '),
        IconButton(
          icon: const Icon(Icons.zoom_out),
          onPressed: () => game.camera.viewfinder.zoom =
              (game.camera.viewfinder.zoom - 0.1).clamp(0.5, 2.0),
        ),
        IconButton(
          icon: const Icon(Icons.zoom_in),
          onPressed: () => game.camera.viewfinder.zoom =
              (game.camera.viewfinder.zoom + 0.1).clamp(0.5, 2.0),
        ),
      ],
    );
  }

  Widget _buildLabelInput(ParkingEntity entity) {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Etiqueta',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) => entity.label = value,
      controller: TextEditingController(text: entity.label),
    );
  }
}
