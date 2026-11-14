import '../domain/history_record.dart';
import 'history_repository.dart';

class MockHistoryRepository implements HistoryRepository {
  @override
  Future<List<HistoryRecord>> getHistory() async {
    final now = DateTime.now();

    return [
      HistoryRecord(
        id: 'H001',
        type: HistoryType.sensor,
        title: 'Suhu Udara',
        description: 'Pembacaan sensor suhu',
        value: '28.5 °C',
        status: 'Normal',
        recordedAt: now.subtract(const Duration(minutes: 10)),
        details:
            'Suhu udara tercatat sebesar 28.5 °C. '
            'Data ini merupakan simulasi pembacaan sensor.',
      ),
      HistoryRecord(
        id: 'H002',
        type: HistoryType.sensor,
        title: 'Kelembapan Udara',
        description: 'Pembacaan sensor kelembapan udara',
        value: '75%',
        status: 'Normal',
        recordedAt: now.subtract(const Duration(minutes: 20)),
        details:
            'Kelembapan udara tercatat sebesar 75%. '
            'Data ini merupakan simulasi pembacaan sensor.',
      ),
      HistoryRecord(
        id: 'H003',
        type: HistoryType.irrigation,
        title: 'Penyiraman Area Tanaman',
        description: 'Aktivitas penyiraman otomatis',
        value: '100 Liter',
        status: 'Selesai',
        recordedAt: now.subtract(const Duration(hours: 1)),
        details:
            'Durasi penyiraman: 10 menit. '
            'Volume air: 100 Liter. '
            'Catatan ini merupakan data simulasi.',
      ),
      HistoryRecord(
        id: 'H004',
        type: HistoryType.sensor,
        title: 'Kelembapan Tanah',
        description: 'Pembacaan sensor kelembapan tanah',
        value: '55%',
        status: 'Normal',
        recordedAt: now.subtract(const Duration(hours: 2)),
        details:
            'Kelembapan tanah tercatat sebesar 55%. '
            'Data ini merupakan simulasi pembacaan sensor.',
      ),
      HistoryRecord(
        id: 'H005',
        type: HistoryType.sensor,
        title: 'Level Air Tangki',
        description: 'Pembacaan ketinggian air tangki',
        value: '80%',
        status: 'Aman',
        recordedAt: now.subtract(const Duration(hours: 3)),
        details:
            'Level air tangki tercatat sebesar 80%. '
            'Data ini merupakan simulasi pembacaan sensor.',
      ),
      HistoryRecord(
        id: 'H006',
        type: HistoryType.sensor,
        title: 'Sensor Hujan',
        description: 'Pemeriksaan deteksi hujan',
        value: '0%',
        status: 'Tidak terdeteksi',
        recordedAt: now.subtract(const Duration(days: 1)),
        details:
            'Sensor hujan tidak mendeteksi hujan. '
            'Data ini merupakan simulasi.',
      ),
      HistoryRecord(
        id: 'H007',
        type: HistoryType.irrigation,
        title: 'Penyiraman Area Tanaman',
        description: 'Aktivitas penyiraman otomatis',
        value: '150 Liter',
        status: 'Selesai',
        recordedAt: now.subtract(const Duration(days: 2)),
        details:
            'Durasi penyiraman: 15 menit. '
            'Volume air: 150 Liter. '
            'Catatan ini merupakan data simulasi.',
      ),
      HistoryRecord(
        id: 'H008',
        type: HistoryType.sensor,
        title: 'Debit Air',
        description: 'Pembacaan sensor aliran air',
        value: '2.5 L/min',
        status: 'Mengalir',
        recordedAt: now.subtract(const Duration(days: 3)),
        details:
            'Debit air tercatat sebesar 2.5 L/min. '
            'Data ini merupakan simulasi pembacaan sensor.',
      ),
      HistoryRecord(
        id: 'H009',
        type: HistoryType.irrigation,
        title: 'Penyiraman Area Tanaman',
        description: 'Aktivitas penyiraman otomatis',
        value: '120 Liter',
        status: 'Selesai',
        recordedAt: now.subtract(const Duration(days: 5)),
        details:
            'Durasi penyiraman: 12 menit. '
            'Volume air: 120 Liter. '
            'Catatan ini merupakan data simulasi.',
      ),
      HistoryRecord(
        id: 'H010',
        type: HistoryType.sensor,
        title: 'Suhu Udara',
        description: 'Pembacaan sensor suhu',
        value: '27.8 °C',
        status: 'Normal',
        recordedAt: now.subtract(const Duration(days: 12)),
        details:
            'Suhu udara tercatat sebesar 27.8 °C. '
            'Data ini merupakan simulasi pembacaan sensor.',
      ),
    ]..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }
}
