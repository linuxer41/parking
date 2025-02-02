
import 'package:flutter/material.dart';

class SpotInspector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // Implementación del inspector de Spot
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Text('Inspector de Spot'),
          // Aquí puedes agregar campos de edición para modificar propiedades del Spot
        ],
      ),
    );
  }
}
    