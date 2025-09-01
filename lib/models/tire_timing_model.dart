class TireTiming {
  final String vehicleType;
  final String description;
  final Map<String, double> baseTimes;
  final Map<String, double>? balancingTimes;
  final double? balancingSupplement;
  final String unit;
  final String? note;

  const TireTiming({
    required this.vehicleType,
    required this.description,
    required this.baseTimes,
    this.balancingTimes,
    this.balancingSupplement,
    required this.unit,
    this.note,
  });

  factory TireTiming.fromJson(Map<String, dynamic> json) {
    return TireTiming(
      vehicleType: json['vehicle_type'] ?? '',
      description: json['descripcion'] ?? '',
      baseTimes: _parseTimesMap(json['tiempos_base'] ?? json),
      balancingTimes: json['tiempos_con_equilibrado_delanteras'] != null
          ? _parseTimesMap(json['tiempos_con_equilibrado_delanteras'])
          : null,
      balancingSupplement:
          json['suplemento_equilibrado_delanteras']?.toDouble(),
      unit: json['unidad'] ?? 'min',
      note: json['nota'],
    );
  }

  static Map<String, double> _parseTimesMap(Map<String, dynamic> times) {
    final Map<String, double> result = {};
    times.forEach((key, value) {
      if (value is num &&
          ![
            'unidad',
            'descripcion',
            'nota',
            'suplemento_equilibrado_delanteras',
            'tiempos_base',
            'tiempos_con_equilibrado_delanteras'
          ].contains(key)) {
        result[key] = value.toDouble();
      }
    });
    return result;
  }

  double? getTimeForWheels(int wheelCount, {bool withBalancing = false}) {
    final String wheelKey = '${wheelCount}_rueda${wheelCount > 1 ? 's' : ''}';

    if (withBalancing && balancingTimes != null) {
      return balancingTimes![wheelKey];
    }

    return baseTimes[wheelKey];
  }

  List<int> getAvailableWheelCounts() {
    final Set<int> wheelCounts = <int>{};

    for (String key in baseTimes.keys) {
      final RegExp regExp = RegExp(r'(\d+)_rueda');
      final Match? match = regExp.firstMatch(key);
      if (match != null) {
        wheelCounts.add(int.parse(match.group(1)!));
      }
    }

    return wheelCounts.toList()..sort();
  }

  bool hasBalancingOption() {
    return balancingTimes != null && balancingTimes!.isNotEmpty;
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle_type': vehicleType,
      'descripcion': description,
      'tiempos_base': baseTimes,
      'tiempos_con_equilibrado_delanteras': balancingTimes,
      'suplemento_equilibrado_delanteras': balancingSupplement,
      'unidad': unit,
      'nota': note,
    };
  }
}

class TireTimingRecommendations {
  static const Map<String, TireTiming> _recommendations = {
    'turismo': TireTiming(
      vehicleType: 'turismo',
      description:
          'Coche turismo (compacto/berlina). Tiempos medios totales en minutos (min).',
      baseTimes: {
        '1_rueda': 15.0,
        '2_ruedas': 25.1,
        '3_ruedas': 37.1,
        '4_ruedas': 50.2,
      },
      unit: 'min',
    ),
    'suv_4x4': TireTiming(
      vehicleType: 'suv_4x4',
      description:
          'SUV o 4x4 ligero. Ruedas de mayor tamaño y peso. Tiempos medios totales en minutos (min).',
      baseTimes: {
        '1_rueda': 25.0,
        '2_ruedas': 50.0,
        '3_ruedas': 69.9,
        '4_ruedas': 90.0,
      },
      unit: 'min',
    ),
    'todoterreno_puro': TireTiming(
      vehicleType: 'todoterreno_puro',
      description:
          'Todoterreno con neumático AT/MT (más duro, más pesado). Tiempos medios totales en minutos (min).',
      baseTimes: {
        '1_rueda': 28.0,
        '2_ruedas': 55.0,
        '3_ruedas': 77.0,
        '4_ruedas': 100.0,
      },
      unit: 'min',
    ),
    'camion': TireTiming(
      vehicleType: 'camion',
      description:
          'Camión. Neumáticos de gran volumen. Incluye inflado más largo. Tiempos medios totales en minutos (min).',
      baseTimes: {
        '1_rueda': 25.0,
        '2_ruedas': 47.8,
        '3_ruedas': 70.7,
        '4_ruedas': 93.8,
      },
      balancingTimes: {
        '2_ruedas': 67.8,
        '4_ruedas': 113.8,
      },
      unit: 'min',
    ),
    'furgoneta_SRW': TireTiming(
      vehicleType: 'furgoneta_SRW',
      description:
          'Furgoneta (vehículo comercial ligero) con rueda simple trasera. Progresión hasta 4 neumáticos.',
      baseTimes: {
        '1_rueda': 23.4,
        '2_ruedas': 42.6,
        '3_ruedas': 63.2,
        '4_ruedas': 84.6,
      },
      balancingTimes: {
        '1_rueda': 43.4,
        '2_ruedas': 62.6,
        '3_ruedas': 83.2,
        '4_ruedas': 104.6,
      },
      balancingSupplement: 20.0,
      unit: 'min',
    ),
    'furgoneta_DRW': TireTiming(
      vehicleType: 'furgoneta_DRW',
      description:
          'Furgoneta gran volumen con rueda gemela en eje trasero (dual rear wheel). Progresión hasta 6 neumáticos.',
      baseTimes: {
        '1_rueda': 23.2,
        '2_ruedas': 43.1,
        '3_ruedas': 63.7,
        '4_ruedas': 84.8,
        '5_ruedas': 106.2,
        '6_ruedas': 127.8,
      },
      balancingTimes: {
        '1_rueda': 43.2,
        '2_ruedas': 63.1,
        '3_ruedas': 83.7,
        '4_ruedas': 104.8,
        '5_ruedas': 126.2,
        '6_ruedas': 147.8,
      },
      balancingSupplement: 20.0,
      unit: 'min',
      note:
          'Si las ruedas delanteras se cambian, su equilibrado ya está incluido y no se suma el suplemento.',
    ),
  };

  static List<TireTiming> getAllRecommendations() {
    return _recommendations.values.toList();
  }

  static TireTiming? getRecommendationForVehicle(String vehicleType) {
    return _recommendations[vehicleType];
  }

  static List<String> getVehicleTypes() {
    return _recommendations.keys.toList();
  }

  static String getVehicleDisplayName(String vehicleType) {
    switch (vehicleType) {
      case 'turismo':
        return 'Turismo';
      case 'suv_4x4':
        return 'SUV/4x4';
      case 'todoterreno_puro':
        return 'Todoterreno Puro';
      case 'camion':
        return 'Camión';
      case 'furgoneta_SRW':
        return 'Furgoneta SRW';
      case 'furgoneta_DRW':
        return 'Furgoneta DRW';
      default:
        return vehicleType;
    }
  }
}
