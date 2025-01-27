import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart'; // Para cargar imágenes desde assets
import 'dart:ui' as ui; // Para usar ui.Image
import 'grid_object.dart';
import 'helpers/selected_inidcator.dart';

enum SpotObjectType { car, bus, truck, van, motorcycle, bicycle }

enum SpotObjectCategory { standart, vip, electric, handicap }

SpotObjectType intToSpotObjectType(int value) {
  if (value >= 0 && value < SpotObjectType.values.length) {
    return SpotObjectType.values[value];
  } else {
    return SpotObjectType.car;
  }
}

SpotObjectCategory intToSpotObjectCategory(int value) {
  if (value >= 0 && value < SpotObjectCategory.values.length) {
    return SpotObjectCategory.values[value];
  } else {
    return SpotObjectCategory.standart;
  }
}

class SpotObject extends GridObject {
  final SpotObjectType type;
  final SpotObjectCategory category;
  String label; // Código del spot (ejemplo: A4)
  bool isFree;
  Color? tintColor; // Nuevo: Color para aplicar a la imagen
  String? vehiclePlate; // Placa del vehículo (null si está libre)

  // Tamaños predefinidos para cada tipo de spot
  static const Map<SpotObjectType, Size> spotSizes = {
    SpotObjectType.car: Size(2 * 2, 4 * 2),
    SpotObjectType.bus: Size(2.5 * 2, 12 * 2),
    SpotObjectType.truck: Size(2.5 * 2, 8 * 2),
    SpotObjectType.van: Size(2 * 2, 5 * 2),
    SpotObjectType.motorcycle: Size(1 * 2, 2 * 2),
    SpotObjectType.bicycle: Size(5 * 2, 1.5 * 2),
  };

  // Colores predefinidos para cada categoría
  static const Map<SpotObjectCategory, Color> categoryColors = {
  SpotObjectCategory.standart: Color(0xFF4A90E2), // Azul suave
  SpotObjectCategory.vip: Color(0xFFDAA520), // Dorado
  SpotObjectCategory.electric: Color(0xFF32CD32), // Verde lima
  SpotObjectCategory.handicap: Color(0xFFFF6347), // Coral
  };

  // Nombres de las imágenes locales para cada tipo de spot
  static const Map<SpotObjectType, String> spotImages = {
    SpotObjectType.car: 'assets/spot/Car.png',
    SpotObjectType.bus: 'assets/spot/Mini_van.png',
    SpotObjectType.truck: 'assets/spot/Truck.png',
    SpotObjectType.van: 'assets/spot/Mini_van.png',
    SpotObjectType.motorcycle: 'assets/spot/Truck.png',
    SpotObjectType.bicycle: 'assets/spot/Truck.png',
  };

  // Mapa para almacenar las imágenes cargadas
  static final Map<SpotObjectType, ui.Image> _loadedImages = {};

  SpotObject({
    super.position = const Offset(0, 0),
    this.label= '', // Código del spot (ejemplo: A4)
    this.isFree = true,
    this.tintColor, // Nuevo: Color para aplicar a la imagen
    this.vehiclePlate, // Placa del vehículo (null si está libre)
    required this.type,
    required this.category,
    super.id,
  }) : super(
          size: Size(spotSizes[type]!.width, spotSizes[type]!.height),
          color: categoryColors[category]!,
        );

  // Método para cargar las imágenes (debe llamarse antes de usar los objetos)
  static Future<void> loadImages() async {
    for (final entry in spotImages.entries) {
      final imagePath = entry.value;
      final ByteData imageData = await rootBundle.load(imagePath);
      final codec =
          await ui.instantiateImageCodec(imageData.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      _loadedImages[entry.key] = frame.image;
    }
  }

  @override
  void drawContent(
    Canvas canvas,
    Paint paint,
    Rect rect,
    Offset canvasOffset,
    double gridSize,
    double scale,
  ) {
    // Dibujar la imagen solo si el spot está ocupado
    if (!isFree) {
      _drawSpotImage(canvas, rect, tintColor: tintColor);
    }

    // Dibujar el texto
    _drawLabel(canvas, rect);
  }

  void toggleStatus() {
    isFree = !isFree;
  }

  void _drawSpotImage(Canvas canvas, Rect rect,
      {Color? tintColor = Colors.blue}) {
    final image = _loadedImages[type]; // Obtener la imagen cargada
    if (image == null) return; // Si la imagen no está cargada, no hacer nada

    // Calcular la relación de aspecto de la imagen original
    final imageAspectRatio = image.width / image.height;

    // Calcular el tamaño máximo que la imagen puede tener dentro del rectángulo
    final maxImageWidth = rect.width * 0.95; // 95% del ancho del rectángulo
    final maxImageHeight = rect.height * 0.95; // 95% del alto del rectángulo

    // Calcular el tamaño de la imagen respetando su relación de aspecto
    double imageWidth, imageHeight;
    if (maxImageWidth / maxImageHeight > imageAspectRatio) {
      // Si el espacio disponible es más ancho que la imagen, ajustar por altura
      imageHeight = maxImageHeight;
      imageWidth = imageHeight * imageAspectRatio;
    } else {
      // Si el espacio disponible es más alto que la imagen, ajustar por ancho
      imageWidth = maxImageWidth;
      imageHeight = imageWidth / imageAspectRatio;
    }

    // Calcular la posición de la imagen (centrada horizontalmente y verticalmente)
    final imageOffset = Offset(
      (rect.width - imageWidth) / 2, // Centrar horizontalmente
      (rect.height - imageHeight) / 2, // Centrar verticalmente
    );

    // Dibujar la imagen original primero
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(imageOffset.dx, imageOffset.dy, imageWidth, imageHeight),
      Paint(),
    );

    // Si se proporciona un tintColor, aplicar un filtro solo a los colores naranja y rojo
    if (tintColor != null) {
      // Crear una máscara para los colores naranja y rojo
      final maskPaint = Paint()
        ..colorFilter = ColorFilter.mode(tintColor, BlendMode.srcIn)
        ..blendMode = BlendMode.srcIn;

      // Dibujar la imagen nuevamente, pero solo los píxeles que coincidan con la máscara
      canvas.saveLayer(
        Rect.fromLTWH(imageOffset.dx, imageOffset.dy, imageWidth, imageHeight),
        maskPaint,
      );
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(imageOffset.dx, imageOffset.dy, imageWidth, imageHeight),
        Paint()
          ..colorFilter = ColorFilter.mode(
            Colors.white
                .withOpacity(0.5), // Ajusta la opacidad según sea necesario
            BlendMode.srcIn,
          ),
      );
      canvas.restore();
    }
  }

  void _drawLabel(Canvas canvas, Rect rect) {
    // Texto del código del spot (label)
    final spotCodePainter = TextPainter(
      text: TextSpan(
        text: label, // Código del spot (ejemplo: A4)
        style: const TextStyle(
          color: Colors.white, // Texto en blanco
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    spotCodePainter.layout();

    // Texto de la placa o "LIBRE"
    final plateOrFreePainter = TextPainter(
      text: TextSpan(
        text: isFree ? "LIBRE" : vehiclePlate ?? "", // Placa o "LIBRE"
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    plateOrFreePainter.layout();

    // Posicionamiento del texto
    if (isFree) {
      // Si el spot está libre, centrar ambos textos
      final totalHeight = spotCodePainter.height +
          plateOrFreePainter.height +
          4; // Espacio entre textos
      final startY = (rect.height - totalHeight) / 2;

      // Dibujar el código del spot
      spotCodePainter.paint(
        canvas,
        Offset(
          (rect.width - spotCodePainter.width) / 2,
          startY,
        ),
      );

      // Dibujar "LIBRE"
      plateOrFreePainter.paint(
        canvas,
        Offset(
          (rect.width - plateOrFreePainter.width) / 2,
          startY + spotCodePainter.height + 4, // Espacio entre textos
        ),
      );
    } else {
      // Si el spot está ocupado, el código del spot va arriba y la placa abajo
      spotCodePainter.paint(
        canvas,
        Offset(
          (rect.width - spotCodePainter.width) / 2,
          rect.height * 0.1, // Espacio desde la parte superior
        ),
      );

      plateOrFreePainter.paint(
        canvas,
        Offset(
          (rect.width - plateOrFreePainter.width) / 2,
          rect.height * 0.85, // Espacio desde la parte superior
        ),
      );
    }
  }
}
