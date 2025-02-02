import '../components/transform.dart';
import '../components/renderable.dart';
import '../components/collider.dart';
import '../components/draggable.dart';

class Entity {
  String id;
  TransformComponent transform;
  RenderableComponent? renderable;
  ColliderComponent? collider;
  DraggableComponent? draggable;

  Entity({
    required this.id,
    required this.transform,
    this.renderable,
    this.collider,
    this.draggable,
  });
}

class EntitySystem {
  List<Entity> entities = [];

  void addEntity(Entity entity) {
    entities.add(entity);
  }

  void update() {
    for (var entity in entities) {
      // Actualizar la posición de la entidad si tiene un componente de transformación
      if (entity.transform != null) {
        // Aquí puedes agregar lógica de actualización para cada entidad
      }
    }
  }
}