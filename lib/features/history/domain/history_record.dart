enum HistoryType { sensor, irrigation }

enum HistoryPeriod { today, sevenDays, thirtyDays }

class HistoryRecord {
  final String id;
  final HistoryType type;
  final String title;
  final String description;
  final String value;
  final String status;
  final DateTime recordedAt;
  final String details;

  const HistoryRecord({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.value,
    required this.status,
    required this.recordedAt,
    required this.details,
  });
}
