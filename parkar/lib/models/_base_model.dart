abstract class JsonConvertible<T> {
  Map<String, dynamic> toJson();
}

/// Base model with common fields for all entities
abstract class BaseModel extends JsonConvertible<BaseModel> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  BaseModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  Map<String, dynamic> toJson();
}

/// Base create model for creating new entities
abstract class BaseCreateModel<T> extends JsonConvertible<T> {
  @override
  Map<String, dynamic> toJson();
}

/// Base update model for updating existing entities
abstract class BaseUpdateModel<T> extends JsonConvertible<T> {
  @override
  Map<String, dynamic> toJson();
}
