import 'package:flutter/material.dart';
import 'package:flame/game.dart';

import '../../state/app_state_container.dart';
import 'editor.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final level =  AppStateContainer.of(context).currentLevel;
    final game = ParkingEditorGame(level: level!);
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(
            game: game,
            overlayBuilderMap: {
              'controls': (context, game) =>
                  EditorControls(game: game as ParkingEditorGame),
            },
          ),
        ],
      ),
    );
  }
}