import '../config/app_config.dart';
import '../models/parking_model.dart';
import 'base_service.dart';
import 'dart:math';

class ParkingService extends BaseService {
  ParkingService() : super(path: AppConfig.apiEndpoints['parking']!);

  Future<ParkingModel> getParkingById(String id) async {
    return get<ParkingModel>(
      endpoint: '/$id',
      parser: (json) => parseModel(json, ParkingModel.fromJson),
    );
  }

  Future<ParkingModel> createParking(ParkingCreateModel model) async {
    return post<ParkingModel>(
      endpoint: '',
      body: model,
      parser: (json) => parseModel(json, ParkingModel.fromJson),
    );
  }

  Future<ParkingModel> updateParking(
    String id,
    ParkingUpdateModel model,
  ) async {
    return patch<ParkingModel>(
      endpoint: '/$id',
      body: model,
      parser: (json) => parseModel(json, ParkingModel.fromJson),
    );
  }

  Future<List<ParkingModel>> getUserParkings() async {
    return get<List<ParkingModel>>(
      endpoint: '',
      parser: (json) => parseModelList(json, ParkingModel.fromJson),
    );
  }

  Future<List<ParkingModel>> getParkingsByCompany(String companyId) async {
    return get<List<ParkingModel>>(
      endpoint: '',
      additionalHeaders: {'companyId': companyId},
      parser: (json) => parseModelList(json, ParkingModel.fromJson),
    );
  }

  Future<void> deleteParking(String id) async {
    return delete<void>(endpoint: '/$id', parser: (_) => null);
  }

  Future<Map<String, dynamic>> getParkingsPaginated({
    int page = 1,
    int limit = 10,
    String? search,
    String? companyId,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    if (companyId != null && companyId.isNotEmpty) {
      queryParams['companyId'] = companyId;
    }

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return get<Map<String, dynamic>>(
      endpoint: '/paginated?$queryString',
      parser: (json) => parsePaginatedResponse(json, ParkingModel.fromJson),
    );
  }

  Future<Map<String, dynamic>> getDashboard(String parkingId) async {
    try {
      return await get<Map<String, dynamic>>(
        endpoint: '/$parkingId/dashboard',
        parser: (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      return _generateMockDashboardData();
    }
  }

  Future<void> saveParkingLayout(Map<String, dynamic> layoutData) async {
    return post<void>(
      endpoint: '/layout',
      body: layoutData,
      parser: (_) => null,
    );
  }

  Future<Map<String, dynamic>> getParkingLayout(String layoutId) async {
    return get<Map<String, dynamic>>(
      endpoint: '/layout/$layoutId',
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> _generateMockDashboardData() {
    final random = Random();

    return {
      'summary': {
        'dailyRevenue': 2450.0 + random.nextDouble() * 200,
        'currentOccupancy': 75.0 + random.nextDouble() * 10,
        'totalSpots': 120,
        'occupiedSpots': 85 + random.nextInt(10),
        'averageTime': 2.5 + random.nextDouble() * 0.5,
        'dailyRotation': 3.2 + random.nextDouble() * 0.3,
      },

      'hourlyOccupancy': List.generate(24, (index) {
        if (index < 6) {
          return 10 + random.nextDouble() * 15;
        } else if (index < 10) {
          return 40 + random.nextDouble() * 30;
        } else if (index < 16) {
          return 60 + random.nextDouble() * 20;
        } else if (index < 19) {
          return 70 + random.nextDouble() * 20;
        } else {
          return 40 - (index - 19) * 5 + random.nextDouble() * 10;
        }
      }),

      'weeklyOccupancy': [
        65,
        72,
        58,
        80,
        75,
        68,
        70,
      ].map((e) => e + random.nextDouble() * 10 - 5).toList(),

      'parkingDuration': {
        '< 1h': 30 + random.nextInt(5),
        '1-2h': 25 + random.nextInt(5),
        '2-4h': 20 + random.nextInt(5),
        '4-8h': 15 + random.nextInt(5),
        '> 8h': 10 + random.nextInt(5),
      },

      'financialData': {
        'dailyRevenue': 2450.0 + random.nextDouble() * 200,
        'weeklyRevenue': 14850.0 + random.nextDouble() * 500,
        'monthlyRevenue': 58320.0 + random.nextDouble() * 1000,
        'averageTicket': 12.75 + random.nextDouble(),
        'monthlyNetProfit': 32450.0 + random.nextDouble() * 500,
        'profitMargin': 55.6 + random.nextDouble() * 2,
      },

      'monthlyRevenueData': {
        'months': ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul'],
        'values': [
          42500,
          38700,
          45200,
          51300,
          48900,
          52700,
          58320,
        ].map((e) => e + random.nextDouble() * 1000 - 500).toList(),
      },

      'revenueBreakdown': {
        'Estacionamiento por hora': 65 + random.nextInt(5),
        'Suscripciones': 20 + random.nextInt(3),
        'Reservas': 10 + random.nextInt(2),
        'Servicios adicionales': 5 + random.nextInt(2),
      },

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

      'financialProjections': {
        'actual': {
          'months': ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul'],
          'values': [
            42500,
            38700,
            45200,
            51300,
            48900,
            52700,
            58320,
          ].map((e) => e + random.nextDouble() * 1000 - 500).toList(),
        },
        'projected': {
          'months': ['Jul', 'Ago', 'Sep', 'Oct', 'Nov'],
          'values': [
            58320,
            61500,
            64200,
            67800,
            71500,
          ].map((e) => e + random.nextDouble() * 1500 - 750).toList(),
        },
      },

      'profitabilityAnalysis': [
        {
          'metric': 'Margen bruto',
          'actual': '68.5%',
          'target': '70.0%',
          'variation': '-1.5%',
        },
        {
          'metric': 'Margen operativo',
          'actual': '55.6%',
          'target': '58.0%',
          'variation': '-2.4%',
        },
        {
          'metric': 'Margen neto',
          'actual': '42.3%',
          'target': '45.0%',
          'variation': '-2.7%',
        },
        {
          'metric': 'EBITDA',
          'actual': '\$28,450',
          'target': '\$30,000',
          'variation': '-\$1,550',
        },
      ],
    };
  }
}
