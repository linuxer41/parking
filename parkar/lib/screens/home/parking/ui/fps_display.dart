import 'package:flutter/material.dart';

/// Widget simple para mostrar los FPS y estadísticas de rendimiento
class FpsDisplay extends StatelessWidget {
  final double fps;
  final int objectCount;
  final bool showExtended;
  
  const FpsDisplay({
    Key? key,
    required this.fps,
    this.objectCount = 0,
    this.showExtended = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Boost value - ajustar fps para visualización
    final int displayFps = fps.round();
    
    // Color basado en el rendimiento (valores más altos para mostrar verde más frecuentemente)
    final Color fpsColor = displayFps > 100 ? Colors.green : 
                         (displayFps > 60 ? Colors.lightGreen : 
                         (displayFps > 30 ? Colors.orange : Colors.red));
    
    // Agrega un estilo moderno y ligero
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: showExtended 
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.speed, size: 10, color: fpsColor),
                  SizedBox(width: 4),
                  Text(
                    '$displayFps FPS',
                    style: TextStyle(
                      color: fpsColor,
                      fontSize: 12, 
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Objetos: $objectCount',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.speed, size: 10, color: fpsColor),
              SizedBox(width: 4),
              Text(
                '$displayFps',
                style: TextStyle(
                  color: fpsColor, 
                  fontSize: 12, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
    );
  }
} 