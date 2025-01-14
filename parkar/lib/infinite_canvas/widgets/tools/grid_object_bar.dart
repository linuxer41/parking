// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:parkar/infinite_canvas/models/indicator_object.dart';
import 'package:parkar/infinite_canvas/models/office_object.dart';
import 'package:parkar/infinite_canvas/models/spot_object.dart';
import '../canvas_controller.dart';

class GridObjectBar extends StatelessWidget {
  final InfiniteCanvasController controller;

  const GridObjectBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            const BoxShadow(
                color: Colors.black26, blurRadius: 5, offset: Offset(0, 3))
          ],
        ),
        child: Column(
          children: [
            IconButton(
              icon: const Icon(Icons.directions_car),
              onPressed: () => controller.addGridObjectNode(
                SpotObject(
                  type: SpotObjectType.car,
                  category: SpotObjectCategory.standart,
                ),
              ),
              tooltip: "Spot",
            ),
            IconButton(
              icon: const Icon(Icons.directions_car),
              onPressed: () => controller.addGridObjectNode(
                IndicatorObject(
                  label: '',
                  type: InidicatorObjectType.entrance,
                ),
              ),
              tooltip: "Entrada",
            ),
            IconButton(
              icon: const Icon(Icons.directions_car),
              onPressed: () => controller.addGridObjectNode(
                IndicatorObject(
                  label: '',
                  type: InidicatorObjectType.exit,
                ),
              ),
              tooltip: "Salida",
            ),
            IconButton(
              icon: const Icon(Icons.directions_car),
              onPressed: () => controller.addGridObjectNode(
                OfficeObject(
                  label: '',
                ),
              ),
              tooltip: "Oficina",
            ),
          ],
        ),
      ),
    );
  }
}