import 'camera.dart';

class SpriteBatch {
  final List<Sprite> sprites = [];

  void addSprite(Sprite sprite) {
    sprites.add(sprite);
  }

  void render(Camera camera) {
    // Aquí puedes agregar lógica de dibujo
    // Por ejemplo, dibujar cada sprite con la transformación de la cámara
  }
}

class Sprite {
  String imagePath;
  double x;
  double y;
  double width;
  double height;

  Sprite({
    required this.imagePath,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}
    