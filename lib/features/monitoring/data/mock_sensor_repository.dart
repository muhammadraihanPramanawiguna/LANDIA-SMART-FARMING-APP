import 'dart:math' as math;

import '../domain/sensor_reading.dart';
import 'sensor_repository.dart';

class MockSensorRepository implements SensorRepository {
  static const List<SensorDefinition> _sensors = [
    SensorDefinition(
      id: 'temperature',
      name: 'Suhu Udara',
      unit: '°C',
      status: 'Normal',
      latestValue: 28.5,
      category: SensorCategory.air,
      description: 'Temperatur lingkungan greenhouse',
    ),
    SensorDefinition(
      id: 'air_humidity',
      name: 'Kelembapan Udara',
      unit: '%',
      status: 'Normal',
      latestValue: 75,
      category: SensorCategory.air,
      description: 'Kelembapan udara sekitar tanaman',
    ),
    SensorDefinition(
      id: 'soil_moisture',
      name: 'Kelembapan Tanah',
      unit: '%',
      status: 'Normal',
      latestValue: 55,
      category: SensorCategory.tanah,
      description: 'Kadar kelembapan media tanam',
    ),
    SensorDefinition(
      id: 'water_level',
      name: 'Level Air Tangki',
      unit: '%',
      status: 'Aman',
      latestValue: 80,
      category: SensorCategory.tangki,
      description: 'Ketinggian air di dalam tangki',
    ),
    SensorDefinition(
      id: 'rain',
      name: 'Sensor Hujan',
      unit: '%',
      status: 'Tidak terdeteksi',
      latestValue: 0,
      category: SensorCategory.hujanDanAliran,
      description: 'Indikasi deteksi hujan',
    ),
    SensorDefinition(
      id: 'water_flow',
      name: 'Debit Air',
      unit: 'L/min',
      status: 'Tidak mengalir',
      latestValue: 0,
      category: SensorCategory.hujanDanAliran,
      description: 'Laju aliran air pada pipa',
    ),
  ];

  @override
  Future<List<SensorDefinition>> getSensors() async {
    return List.unmodifiable(_sensors);
  }

  @override
  Future<List<SensorReading>> getHistory({
    required String sensorId,
    required MonitoringPeriod period,
  }) async {
    final sensor = _sensors.firstWhere((item) => item.id == sensorId);

    final now = DateTime.now();

    late final Duration range;
    late final Duration interval;

    switch (period) {
      case MonitoringPeriod.oneHour:
        range = const Duration(hours: 1);
        interval = const Duration(minutes: 5);
      case MonitoringPeriod.twentyFourHours:
        range = const Duration(hours: 24);
        interval = const Duration(hours: 1);
      case MonitoringPeriod.sevenDays:
        range = const Duration(days: 7);
        interval = const Duration(hours: 6);
    }

    final count = range.inMinutes ~/ interval.inMinutes;

    final readings = <SensorReading>[];

    for (var i = 0; i <= count; i++) {
      final timestamp = now.subtract(range - interval * i);

      final progress = i / count;

      final value = _generateValue(
        sensorId: sensorId,
        latestValue: sensor.latestValue,
        progress: progress,
        index: i,
      );

      readings.add(
        SensorReading(sensorId: sensorId, value: value, recordedAt: timestamp),
      );
    }

    return readings;
  }

  double _generateValue({
    required String sensorId,
    required double latestValue,
    required double progress,
    required int index,
  }) {
    final wave = math.sin(index * 0.7) * 2.0;
    final secondWave = math.cos(index * 0.35);

    switch (sensorId) {
      case 'temperature':
        return (latestValue + wave + secondWave).clamp(20.0, 40.0);

      case 'air_humidity':
        return (latestValue + wave * 2).clamp(30.0, 100.0);

      case 'soil_moisture':
        return (latestValue - index * 0.25 + wave).clamp(0.0, 100.0);

      case 'water_level':
        return (latestValue + wave * 2).clamp(0.0, 100.0);

      case 'rain':
        return index % 11 == 0 ? 20.0 : 0.0;

      case 'water_flow':
        return index % 5 == 0 ? 0.0 : (2.0 + secondWave).clamp(0.0, 10.0);

      default:
        return latestValue;
    }
  }
}
