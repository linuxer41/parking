import 'package:flutter/material.dart';
import '../home/world/world_screen.dart';

/// Pantalla de juego que utiliza Flame o un placeholder si Flame no está configurado
class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.maps_home_work,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Sistema de Control de Parqueo',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Visualización y gestión de estacionamientos',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.map),
              label: const Text('Abrir Mapa de Parqueo'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const WorldScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              child: const Text('Acerca del Sistema'),
              onPressed: () {
                showDialog(
                  context: context, 
                  builder: (context) => AlertDialog(
                    title: const Text('Acerca del Sistema de Parqueo'),
                    content: const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Este sistema permite:'),
                        SizedBox(height: 8),
                        Text('• Visualizar la disponibilidad de espacios'),
                        Text('• Gestionar vehículos y asignaciones'),
                        Text('• Obtener estadísticas en tiempo real'),
                        Text('• Buscar vehículos por placa'),
                        Text('• Exportar reportes de ocupación'),
                        SizedBox(height: 12),
                        Text('Desarrollado para control eficiente de estacionamientos.'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('CERRAR'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 