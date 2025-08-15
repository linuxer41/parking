import '../config/app_config.dart';
import '../models/parking_model.dart';
import 'base_service.dart';
import 'dart:math';

class ParkingService extends BaseService {
  ParkingService() : super(path: AppConfig.apiEndpoints['parking']!);

  /// Get a parking by ID
  Future<ParkingModel> getParkingById(String id) async {
    return get<ParkingModel>(
      endpoint: '/$id',
      parser: (json) => ParkingModel.fromJson(json),
    );
  }

  /// Create a new parking
  Future<ParkingModel> createParking(ParkingCreateModel model) async {
    return post<ParkingModel>(
      endpoint: '',
      body: model,
      parser: (json) => ParkingModel.fromJson(json),
    );
  }

  /// Update a parking
  Future<ParkingModel> updateParking(
      String id, ParkingUpdateModel model) async {
    return patch<ParkingModel>(
      endpoint: '/$id',
      body: model,
      parser: (json) => ParkingModel.fromJson(json),
    );
  }

  /// Get user parkings
  Future<List<ParkingModel>> getUserParkings() async {
    return get<List<ParkingModel>>(
      endpoint: '/me',
      parser: (data) => (data as List<dynamic>)
          .map((item) => ParkingModel.fromJson(item))
          .toList(),
    );
  }
  
  /// Get dashboard data
  Future<Map<String, dynamic>> getDashboardData(String parkingId) async {
    // En una implementación real, esto haría una llamada a la API
    // Por ahora, simulamos datos de respuesta
    await Future.delayed(const Duration(milliseconds: 800));
    
    final random = Random();
    
    // Datos simulados para el dashboard
    final dashboardData = {
      // Datos de resumen
      'summary': {
        'dailyRevenue': 2450.0 + random.nextDouble() * 200,
        'currentOccupancy': 75.0 + random.nextDouble() * 10,
        'totalSpots': 120,
        'occupiedSpots': 85 + random.nextInt(10),
        'averageTime': 2.5 + random.nextDouble() * 0.5,
        'dailyRotation': 3.2 + random.nextDouble() * 0.3,
      },
      
      // Datos de ocupación por hora (24 horas)
      'hourlyOccupancy': List.generate(24, (index) {
        // Patrón realista: bajo en la madrugada, pico en la mañana, 
        // meseta durante el día, pico en la tarde, y descenso en la noche
        if (index < 6) {
          // Madrugada (0-5): ocupación baja
          return 10 + random.nextDouble() * 15;
        } else if (index < 10) {
          // Mañana (6-9): aumento rápido (hora pico)
          return 40 + random.nextDouble() * 30;
        } else if (index < 16) {
          // Día (10-15): ocupación media-alta
          return 60 + random.nextDouble() * 20;
        } else if (index < 19) {
          // Tarde (16-18): segundo pico
          return 70 + random.nextDouble() * 20;
        } else {
          // Noche (19-23): descenso gradual
          return 40 - (index - 19) * 5 + random.nextDouble() * 10;
        }
      }),
      
      // Datos de ocupación semanal
      'weeklyOccupancy': [65, 72, 58, 80, 75, 68, 70].map((e) => e + random.nextDouble() * 10 - 5).toList(),
      
      // Datos de duración de estacionamiento
      'parkingDuration': {
        '< 1h': 30 + random.nextInt(5),
        '1-2h': 25 + random.nextInt(5),
        '2-4h': 20 + random.nextInt(5),
        '4-8h': 15 + random.nextInt(5),
        '> 8h': 10 + random.nextInt(5),
      },
      
      // Datos financieros
      'financialData': {
        'dailyRevenue': 2450.0 + random.nextDouble() * 200,
        'weeklyRevenue': 14850.0 + random.nextDouble() * 500,
        'monthlyRevenue': 58320.0 + random.nextDouble() * 1000,
        'averageTicket': 12.75 + random.nextDouble(),
        'monthlyNetProfit': 32450.0 + random.nextDouble() * 500,
        'profitMargin': 55.6 + random.nextDouble() * 2,
      },
      
      // Datos de ingresos mensuales
      'monthlyRevenueData': {
        'months': ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul'],
        'values': [42500, 38700, 45200, 51300, 48900, 52700, 58320]
            .map((e) => e + random.nextDouble() * 1000 - 500).toList(),
      },
      
      // Desglose de ingresos
      'revenueBreakdown': {
        'Estacionamiento por hora': 65 + random.nextInt(5),
        'Suscripciones': 20 + random.nextInt(3),
        'Reservas': 10 + random.nextInt(2),
        'Servicios adicionales': 5 + random.nextInt(2),
      },
      
      // KPIs financieros
      'financialKPIs': {
        'ROI': {
          'value': '${215 + random.nextInt(10)}%',
          'trend': 'up',
          'description': 'Retorno sobre inversión',
        },
        'Costo por espacio': {
          'value': '\$${(1.85 + random.nextDouble() * 0.2).toStringAsFixed(2)}',
          'trend': 'down',
          'description': 'Costo operativo por espacio/día',
        },
        'Ingresos por espacio': {
          'value': '\$${(18.50 + random.nextDouble() * 1).toStringAsFixed(2)}',
          'trend': 'up',
          'description': 'Ingreso promedio por espacio/día',
        },
        'Punto de equilibrio': {
          'value': '${22 + random.nextInt(3)}%',
          'trend': 'stable',
          'description': 'Ocupación mínima para cubrir costos',
        },
      },
      
      // Proyecciones financieras
      'financialProjections': {
        'actual': {
          'months': ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul'],
          'values': [42500, 38700, 45200, 51300, 48900, 52700, 58320]
              .map((e) => e + random.nextDouble() * 1000 - 500).toList(),
        },
        'projected': {
          'months': ['Jul', 'Ago', 'Sep', 'Oct', 'Nov'],
          'values': [58320, 61500, 64200, 67800, 71500]
              .map((e) => e + random.nextDouble() * 1500 - 750).toList(),
        },
      },
      
      // Análisis de rentabilidad
      'profitabilityAnalysis': [
        {'metric': 'Margen bruto', 'actual': '68.5%', 'target': '70.0%', 'variation': '-1.5%'},
        {'metric': 'Margen operativo', 'actual': '55.6%', 'target': '58.0%', 'variation': '-2.4%'},
        {'metric': 'Margen neto', 'actual': '42.3%', 'target': '45.0%', 'variation': '-2.7%'},
        {'metric': 'EBITDA', 'actual': '\$28,450', 'target': '\$30,000', 'variation': '-\$1,550'},
      ],
    };
    
    return dashboardData;
  }
}
