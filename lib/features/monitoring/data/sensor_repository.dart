import '../domain/sensor_reading.dart';

abstract class SensorRepository {
  Future<List<SensorDefinition>> getSensors();

  Future<List<SensorReading>> getHistory({
    required String sensorId,
    required MonitoringPeriod period,
  });
}
