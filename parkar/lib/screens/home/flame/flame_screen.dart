import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flame/game.dart';
import 'package:provider/provider.dart';

import 'game/parking_game.dart';
import 'state/flame_state.dart';
import 'widgets/toolbar_widget.dart';

/// Pantalla para el editor de estacionamientos con Flame
class FlameScreen extends StatefulWidget {
  const FlameScreen({Key? key}) : super(key: key);

  @override
  State<FlameScreen> createState() => _FlameScreenState();
}

class _FlameScreenState extends State<FlameScreen> {
  late FlameState _flameState;
  late ParkingGame _game;
  
  @override
  void initState() {
    super.initState();
    
    // Inicializar el estado
    _flameState = FlameState();
    
    // Crear el juego
    _game = ParkingGame(flameState: _flameState);
  }
  
  @override
  void dispose() {
    _flameState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _flameState,
      child: Scaffold(
        body: Column(
          children: [
            // Barra de herramientas
            const FlameToolbarWidget(),
            
            // Juego Flame (editor de estacionamientos)
            Expanded(
              child: GestureDetector(
                onTapDown: (details) {
                  // Manejar tap directamente
                  final position = details.localPosition;
                  _game.handleTap(position);
                },
                onPanStart: (details) {
                  // Manejar inicio de arrastre
                  final position = details.localPosition;
                  _game.handleDragStart(position);
                },
                onPanUpdate: (details) {
                  // Manejar actualización de arrastre
                  final position = details.localPosition;
                  _game.handleDragUpdate(position);
                },
                onPanEnd: (details) {
                  // Manejar fin de arrastre
                  _game.handleDragEnd(Offset.zero);
                },
                child: Listener(
                  onPointerSignal: (signal) {
                    // Manejar scroll del ratón
                    if (signal is PointerScrollEvent) {
                      _game.handleScroll(signal.scrollDelta.dy);
                    }
                  },
                  child: GameWidget(
                    game: _game,
                    focusNode: FocusNode()..requestFocus(),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Panel lateral para propiedades y opciones
        endDrawer: Drawer(
          child: Consumer<FlameState>(
            builder: (context, state, _) {
              return ListView(
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Text(
                      'Propiedades',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  // Mostrar propiedades del elemento seleccionado
                  if (state.firstSelectedElement != null) ...[
                    ListTile(
                      title: const Text('ID'),
                      subtitle: Text(state.firstSelectedElement!.id),
                    ),
                    ListTile(
                      title: const Text('Tipo'),
                      subtitle: Text(state.firstSelectedElement!.type.toString()),
                    ),
                    ListTile(
                      title: const Text('Posición'),
                      subtitle: Text('(${state.firstSelectedElement!.position.x.toStringAsFixed(1)}, ${state.firstSelectedElement!.position.y.toStringAsFixed(1)})'),
                    ),
                  ] else
                    const ListTile(
                      title: Text('No hay elementos seleccionados'),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
} 