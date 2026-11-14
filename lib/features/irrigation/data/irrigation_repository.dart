import '../domain/irrigation_activity.dart';

abstract class IrrigationRepository {
  Future<List<IrrigationActivity>> getActivities();
}
