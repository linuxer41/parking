// game_screen.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

import 'drag_game.dart';
import 'flame.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(
            game: ParkingGame(),
            overlayBuilderMap: {
              'controls': (context, game) => 
                  ParkingGame.cameraControls(context, game as ParkingGame),
            },
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Column(
              children: [
                // Botón de zoom in
                FloatingActionButton(
                  onPressed: () {
                    // game.camera.zoom += 0.1;
                    // game.camera.zoom = game.camera.zoom.clamp(0.5, 3.0);
                  },
                  mini: true,
                  child: Icon(Icons.zoom_in),
                ),
                SizedBox(height: 10),
                // Botón de zoom out
                FloatingActionButton(
                  onPressed: () {
                    // game.camera.zoom -= 0.1;
                    // game.camera.zoom = game.camera.zoom.clamp(0.5, 3.0);
                  },
                  mini: true,
                  child: Icon(Icons.zoom_out),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}