import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../core/world_state.dart';
import '../models/parking_spot.dart';
import '../models/enums.dart';

/// Clase de utilidades para exportar datos de estacionamiento
class ExportUtils {
  /// Exportar datos de ocupación a CSV
  static Future<String?> exportOccupancyToCsv(WorldState state) async {
    try {
      // Crear contenido CSV
      final StringBuffer csvContent = StringBuffer();
      
      // Encabezados
      csvContent.writeln('ID,Espacio,Tipo,Categoría,Estado,Placa,Fecha');
      
      // Formatear fecha actual
      final now = DateTime.now();
      final dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      final formattedDate = dateFormatter.format(now);
      
      // Agregar cada espacio
      for (final ParkingSpot spot in state.spots) {
        final String status = spot.isOccupied ? 'Ocupado' : 'Disponible';
        final String plate = spot.vehiclePlate ?? '';
        final String type = _getSpotTypeName(spot);
        final String category = spot.categoryName;
        
        csvContent.writeln(
          '${spot.id},${spot.label},$type,$category,$status,$plate,$formattedDate'
        );
      }
      
      // Si estamos en web, devolver el contenido directamente
      if (kIsWeb) {
        return csvContent.toString();
      }
      
      // En plataformas nativas, guardar el archivo
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'estacionamiento_${DateFormat('yyyyMMdd_HHmmss').format(now)}.csv';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(csvContent.toString());
      return file.path;
    } catch (e) {
      debugPrint('Error al exportar datos: $e');
      return null;
    }
  }
  
  /// Compartir reporte CSV
  static Future<void> shareCSVReport(WorldState state) async {
    try {
      final filePath = await exportOccupancyToCsv(state);
      
      if (filePath == null) {
        throw Exception('No se pudo generar el archivo CSV');
      }
      
      if (kIsWeb) {
        // En web, manejar de forma diferente (descargar)
        // Aquí se podría implementar lógica para descarga en web
      } else {
        // En plataformas nativas, usar share_plus
        await Share.shareXFiles(
          [XFile(filePath)],
          subject: 'Reporte de Estacionamiento',
          text: 'Reporte de ocupación del estacionamiento generado el ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
        );
      }
    } catch (e) {
      debugPrint('Error al compartir reporte: $e');
    }
  }
  
  /// Obtener el nombre del tipo de espacio
  static String _getSpotTypeName(ParkingSpot spot) {
    switch (spot.type) {
      case SpotType.vehicle:
        return 'Vehículo';
      case SpotType.motorcycle:
        return 'Motocicleta';
      case SpotType.truck:
        return 'Camión';
      default:
        return 'Desconocido';
    }
  }
  
  /// Generar estadísticas de ocupación
  static Map<String, dynamic> generateOccupancyStats(WorldState state) {
    final spots = state.spots;
    
    // Estadísticas básicas
    int totalSpots = spots.length;
    int occupiedSpots = spots.where((spot) => spot.isOccupied).length;
    double occupancyRate = totalSpots > 0 ? (occupiedSpots / totalSpots) : 0;
    
    // Por tipo
    int vehicleSpots = spots.where((spot) => spot.type == SpotType.vehicle).length;
    int motorcycleSpots = spots.where((spot) => spot.type == SpotType.motorcycle).length;
    int truckSpots = spots.where((spot) => spot.type == SpotType.truck).length;
    
    int occupiedVehicleSpots = spots.where(
      (spot) => spot.type == SpotType.vehicle && spot.isOccupied).length;
    int occupiedMotorcycleSpots = spots.where(
      (spot) => spot.type == SpotType.motorcycle && spot.isOccupied).length;
    int occupiedTruckSpots = spots.where(
      (spot) => spot.type == SpotType.truck && spot.isOccupied).length;
    
    // Por categoría
    int normalSpots = spots.where((spot) => spot.category == SpotCategory.normal).length;
    int disabledSpots = spots.where((spot) => spot.category == SpotCategory.disabled).length;
    int reservedSpots = spots.where((spot) => spot.category == SpotCategory.reserved).length;
    int vipSpots = spots.where((spot) => spot.category == SpotCategory.vip).length;
    
    int occupiedNormalSpots = spots.where(
      (spot) => spot.category == SpotCategory.normal && spot.isOccupied).length;
    int occupiedDisabledSpots = spots.where(
      (spot) => spot.category == SpotCategory.disabled && spot.isOccupied).length;
    int occupiedReservedSpots = spots.where(
      (spot) => spot.category == SpotCategory.reserved && spot.isOccupied).length;
    int occupiedVipSpots = spots.where(
      (spot) => spot.category == SpotCategory.vip && spot.isOccupied).length;
    
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'totalSpots': totalSpots,
      'occupiedSpots': occupiedSpots,
      'availableSpots': totalSpots - occupiedSpots,
      'occupancyRate': occupancyRate,
      'byType': {
        'vehicle': {
          'total': vehicleSpots,
          'occupied': occupiedVehicleSpots,
          'available': vehicleSpots - occupiedVehicleSpots,
        },
        'motorcycle': {
          'total': motorcycleSpots,
          'occupied': occupiedMotorcycleSpots,
          'available': motorcycleSpots - occupiedMotorcycleSpots,
        },
        'truck': {
          'total': truckSpots,
          'occupied': occupiedTruckSpots,
          'available': truckSpots - occupiedTruckSpots,
        },
      },
      'byCategory': {
        'normal': {
          'total': normalSpots,
          'occupied': occupiedNormalSpots,
          'available': normalSpots - occupiedNormalSpots,
        },
        'disabled': {
          'total': disabledSpots,
          'occupied': occupiedDisabledSpots,
          'available': disabledSpots - occupiedDisabledSpots,
        },
        'reserved': {
          'total': reservedSpots,
          'occupied': occupiedReservedSpots,
          'available': reservedSpots - occupiedReservedSpots,
        },
        'vip': {
          'total': vipSpots,
          'occupied': occupiedVipSpots,
          'available': vipSpots - occupiedVipSpots,
        },
      },
    };
  }
} 