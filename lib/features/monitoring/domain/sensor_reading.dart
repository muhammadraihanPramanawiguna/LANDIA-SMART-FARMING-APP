enum SensorCategory { air, tanah, tangki, hujanDanAliran }

enum MonitoringPeriod { oneHour, twentyFourHours, sevenDays }

class SensorDefinition {
  final String id;
  final String name;
  final String unit;
  final String status;
  final double latestValue;
  final SensorCategory category;
  final String description;

  const SensorDefinition({
    required this.id,
    required this.name,
    required this.unit,
    required this.status,
    required this.latestValue,
    required this.category,
    required this.description,
  });

  String get formattedValue {
    if (id == 'rain') {
      return '${latestValue.toStringAsFixed(0)}%';
    }

    if (id == 'air_humidity' || id == 'soil_moisture' || id == 'water_level') {
      return '${latestValue.toStringAsFixed(0)}%';
    }

    if (id == 'temperature') {
      return '${latestValue.toStringAsFixed(1)} °C';
    }

    if (id == 'water_flow') {
      return '${latestValue.toStringAsFixed(1)} L/min';
    }

    return '${latestValue.toStringAsFixed(1)} $unit';
  }
}

class SensorReading {
  final String sensorId;
  final double value;
  final DateTime recordedAt;

  const SensorReading({
    required this.sensorId,
    required this.value,
    required this.recordedAt,
  });
}
