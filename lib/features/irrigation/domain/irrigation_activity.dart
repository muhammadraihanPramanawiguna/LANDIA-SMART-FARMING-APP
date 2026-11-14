enum IrrigationStatus { completed, failed, cancelled }

class IrrigationActivity {
  final String id;
  final String area;
  final DateTime startedAt;
  final int durationMinutes;
  final double volumeLiters;
  final IrrigationStatus status;
  final String note;

  const IrrigationActivity({
    required this.id,
    required this.area,
    required this.startedAt,
    required this.durationMinutes,
    required this.volumeLiters,
    required this.status,
    this.note = '',
  });

  double calculateCost(double tariffPerM3) {
    return (volumeLiters / 1000) * tariffPerM3;
  }
}
