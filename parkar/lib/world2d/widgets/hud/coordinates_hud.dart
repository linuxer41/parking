
import 'package:flutter/material.dart';

class CoordinatesHUD extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // Implementación del HUD de coordenadas
      color: Colors.black54,
      padding: EdgeInsets.all(5),
      child: Text(
        'Coordenadas: (0,0)',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
    