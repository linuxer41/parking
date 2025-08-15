import 'package:json_annotation/json_annotation.dart';
import '_base_model.dart';
import 'element_model.dart';

part 'area_model.g.dart';

@JsonSerializable()
class AreaModel implements JsonConvertible<AreaModel> {
  final String id;
  final String name;
  final String? description;
  final int totalSpots;
  final int availableSpots;
  final int occupiedSpots;
  final String parkingId;
  final List<ElementModel> elements;
  final DateTime createdAt;
  final DateTime updatedAt;

  AreaModel({
    required this.id,
    required this.name,
    this.description,
    required this.totalSpots,
    required this.availableSpots,
    required this.occupiedSpots,
    required this.parkingId,
    this.elements = const [],
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Create a copy of this AreaModel but with the given fields replaced with the new values
  AreaModel copyWith({
    String? id,
    String? name,
    String? description,
    int? totalSpots,
    int? availableSpots,
    int? occupiedSpots,
    String? parkingId,
    List<ElementModel>? elements,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AreaModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      totalSpots: totalSpots ?? this.totalSpots,
      availableSpots: availableSpots ?? this.availableSpots,
      occupiedSpots: occupiedSpots ?? this.occupiedSpots,
      parkingId: parkingId ?? this.parkingId,
      elements: elements ?? this.elements,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AreaModel.fromJson(Map<String, dynamic> json) =>
      _$AreaModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AreaModelToJson(this);

  // Convenience getters for filtered elements
  List<ElementModel> get spots => elements.where((e) => e.isSpot).toList();
  List<ElementModel> get signages => elements.where((e) => e.isSignage).toList();
  List<ElementModel> get facilities => elements.where((e) => e.isFacility).toList();
  
  // Convenience getters for available/occupied spots
  List<ElementModel> get availableSpotsList => spots.where((s) => s.isAvailable).toList();
  List<ElementModel> get occupiedSpotsList => spots.where((s) => s.isOccupied).toList();
}

@JsonSerializable()
class AreaCreateModel implements JsonConvertible<AreaCreateModel> {
  final String name;
  final String? description;
  final String parkingId;

  AreaCreateModel({
    required this.name,
    this.description,
    required this.parkingId,
  });

  factory AreaCreateModel.fromJson(Map<String, dynamic> json) =>
      _$AreaCreateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AreaCreateModelToJson(this);
}

@JsonSerializable()
class AreaUpdateModel implements JsonConvertible<AreaUpdateModel> {
  final String? name;
  final String? description;
  final List<ElementModel>? elements;

  AreaUpdateModel({
    this.name,
    this.description,
    this.elements,
  });

  factory AreaUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$AreaUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AreaUpdateModelToJson(this);
}

@JsonSerializable()
class AreaDetailModel implements JsonConvertible<AreaDetailModel> {
  final String id;
  final String name;
  final String? description;
  final int capacity;
  final int occupiedSpots;
  final String parkingId;
  final List<ElementModel> elements;
  final DateTime createdAt;
  final DateTime updatedAt;

  AreaDetailModel({
    required this.id,
    required this.name,
    this.description,
    required this.capacity,
    required this.occupiedSpots,
    required this.parkingId,
    required this.elements,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AreaDetailModel.fromJson(Map<String, dynamic> json) =>
      _$AreaDetailModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AreaDetailModelToJson(this);
}
