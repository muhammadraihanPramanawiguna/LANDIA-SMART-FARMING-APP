import '../domain/irrigation_activity.dart';
import 'irrigation_repository.dart';

class MockIrrigationRepository implements IrrigationRepository {
  @override
  Future<List<IrrigationActivity>> getActivities() async {
    final now = DateTime.now();

    return [
      IrrigationActivity(
        id: 'IRR-001',
        area: 'Area Tanaman',
        startedAt: now.subtract(const Duration(hours: 1)),
        durationMinutes: 10,
        volumeLiters: 100,
        status: IrrigationStatus.completed,
        note: 'Aktivitas penyiraman berhasil diselesaikan.',
      ),
      IrrigationActivity(
        id: 'IRR-002',
        area: 'Area Pembibitan',
        startedAt: now.subtract(const Duration(hours: 5)),
        durationMinutes: 8,
        volumeLiters: 80,
        status: IrrigationStatus.completed,
        note: 'Aktivitas penyiraman berhasil diselesaikan.',
      ),
      IrrigationActivity(
        id: 'IRR-003',
        area: 'Area Tanaman',
        startedAt: now.subtract(const Duration(days: 1)),
        durationMinutes: 12,
        volumeLiters: 120,
        status: IrrigationStatus.completed,
        note: 'Aktivitas penyiraman berhasil diselesaikan.',
      ),
      IrrigationActivity(
        id: 'IRR-004',
        area: 'Area Pembibitan',
        startedAt: now.subtract(const Duration(days: 3)),
        durationMinutes: 15,
        volumeLiters: 150,
        status: IrrigationStatus.completed,
        note: 'Aktivitas penyiraman berhasil diselesaikan.',
      ),
      IrrigationActivity(
        id: 'IRR-005',
        area: 'Area Tanaman',
        startedAt: now.subtract(const Duration(days: 8)),
        durationMinutes: 10,
        volumeLiters: 100,
        status: IrrigationStatus.completed,
        note: 'Aktivitas penyiraman berhasil diselesaikan.',
      ),
    ]..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }
}
