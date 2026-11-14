import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:public_file_saver/public_file_saver.dart';

import '../../irrigation/data/mock_irrigation_repository.dart';
import '../../irrigation/data/irrigation_repository.dart';
import '../../irrigation/domain/irrigation_activity.dart';
import '../data/report_pdf_service.dart';

enum ReportPeriod { today, sevenDays, thirtyDays }

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  static const Color forestGreen = Color(0xFF173F35);
  static const Color leafGreen = Color(0xFF397A52);
  static const Color cream = Color(0xFFF4F3E9);
  static const Color harvestGold = Color(0xFFD8A85D);

  static const double tariffPerM3 = 1000;

  final IrrigationRepository _repository = MockIrrigationRepository();

  late Future<List<IrrigationActivity>> _activitiesFuture;

  ReportPeriod _selectedPeriod = ReportPeriod.sevenDays;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _activitiesFuture = _repository.getActivities();
  }

  Future<void> _refresh() async {
    final future = _repository.getActivities();

    setState(() {
      _activitiesFuture = future;
    });

    await future;
  }

  DateTime _startDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedPeriod) {
      case ReportPeriod.today:
        return today;
      case ReportPeriod.sevenDays:
        return today.subtract(const Duration(days: 6));
      case ReportPeriod.thirtyDays:
        return today.subtract(const Duration(days: 29));
    }
  }

  List<IrrigationActivity> _filterActivities(
    List<IrrigationActivity> activities,
  ) {
    final start = _startDate();
    final now = DateTime.now();

    return activities.where((activity) {
      return !activity.startedAt.isBefore(start) &&
          !activity.startedAt.isAfter(now);
    }).toList()..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  double _totalVolume(List<IrrigationActivity> activities) {
    return activities.fold<double>(
      0,
      (total, item) => total + item.volumeLiters,
    );
  }

  double _totalCost(List<IrrigationActivity> activities) {
    return activities.fold<double>(
      0,
      (total, item) => total + item.calculateCost(tariffPerM3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<IrrigationActivity>>(
      future: _activitiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: leafGreen),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorState();
        }

        final activities = _filterActivities(snapshot.data!);
        final volume = _totalVolume(activities);
        final cost = _totalCost(activities);

        return RefreshIndicator(
          onRefresh: _refresh,
          color: leafGreen,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildDemoNotice(),
                        const SizedBox(height: 22),
                        _buildPeriodSelector(),
                        const SizedBox(height: 20),
                        _buildReportSummary(
                          activities.length,
                          volume,
                          cost,
                          isMobile,
                        ),
                        const SizedBox(height: 28),
                        _buildSensorSection(isMobile),
                        const SizedBox(height: 28),
                        _buildIrrigationSection(activities),
                        const SizedBox(height: 28),
                        _buildWaterChart(activities, isMobile),
                        const SizedBox(height: 28),
                        _buildCostBreakdown(volume, cost),
                        const SizedBox(height: 28),
                        _buildActivityList(activities),
                        const SizedBox(height: 24),
                        _buildExportSection(activities, volume, cost),
                        const SizedBox(height: 24),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // HEADER

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Laporan',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: forestGreen,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Ringkasan operasional dan penggunaan air Landia Farm.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildDemoNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: harvestGold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: harvestGold.withValues(alpha: 0.5)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: forestGreen),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'DATA DEMO — Laporan menggunakan data simulasi, '
              'belum berasal dari perangkat IoT.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // PERIOD

  Widget _buildPeriodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Periode Laporan',
          style: TextStyle(
            color: forestGreen,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _periodChip('Hari Ini', ReportPeriod.today),
            _periodChip('7 Hari', ReportPeriod.sevenDays),
            _periodChip('30 Hari', ReportPeriod.thirtyDays),
          ],
        ),
      ],
    );
  }

  Widget _periodChip(String label, ReportPeriod period) {
    final selected = _selectedPeriod == period;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _selectedPeriod = period;
        });
      },
      selectedColor: leafGreen,
      backgroundColor: Colors.white,
      showCheckmark: false,
      side: BorderSide(color: selected ? leafGreen : Colors.grey.shade300),
      labelStyle: TextStyle(
        color: selected ? Colors.white : forestGreen,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }

  // SUMMARY

  Widget _buildReportSummary(
    int count,
    double volume,
    double cost,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Operasional',
          style: TextStyle(
            color: forestGreen,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 850
                ? 4
                : constraints.maxWidth >= 500
                ? 2
                : 1;

            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: columns == 1 ? 3.2 : 1.6,
              children: [
                _summaryCard(
                  'Aktivitas Penyiraman',
                  '$count kali',
                  Icons.water_drop_outlined,
                ),
                _summaryCard(
                  'Penggunaan Air',
                  '${volume.toStringAsFixed(0)} L',
                  Icons.water,
                ),
                _summaryCard(
                  'Estimasi Biaya',
                  _formatCurrency(cost),
                  Icons.payments_outlined,
                ),
                _summaryCard(
                  'Tarif Simulasi',
                  '${_formatCurrency(tariffPerM3)}/m³',
                  Icons.price_change_outlined,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _summaryCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: leafGreen, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: forestGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // SENSOR SNAPSHOT

  Widget _buildSensorSection(bool isMobile) {
    const sensors = [
      _SensorSnapshot(
        'Suhu Udara',
        '28.5 °C',
        'Normal',
        Icons.thermostat_outlined,
      ),
      _SensorSnapshot(
        'Kelembapan Udara',
        '75%',
        'Normal',
        Icons.water_drop_outlined,
      ),
      _SensorSnapshot(
        'Kelembapan Tanah',
        '55%',
        'Normal',
        Icons.grass_outlined,
      ),
      _SensorSnapshot('Level Air Tangki', '80%', 'Aman', Icons.water_outlined),
      _SensorSnapshot(
        'Sensor Hujan',
        '0%',
        'Tidak terdeteksi',
        Icons.cloud_outlined,
      ),
      _SensorSnapshot(
        'Debit Air',
        '0.0 L/min',
        'Tidak mengalir',
        Icons.waves_outlined,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Sensor',
          style: TextStyle(
            color: forestGreen,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Snapshot nilai sensor simulasi, bukan histori periode.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 650 ? 2 : 1;

            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 10,
              childAspectRatio: columns == 1 ? 4.0 : 3.2,
              children: sensors.map((sensor) {
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(sensor.icon, color: leafGreen, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sensor.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              sensor.value,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: forestGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Text(
                          sensor.status,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            color: leafGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // IRRIGATION SUMMARY

  Widget _buildIrrigationSection(List<IrrigationActivity> activities) {
    final completed = activities
        .where((item) => item.status == IrrigationStatus.completed)
        .length;

    final totalDuration = activities
        .where((item) => item.status == IrrigationStatus.completed)
        .fold<int>(0, (total, item) => total + item.durationMinutes);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: forestGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aktivitas Penyiraman',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _whiteDetailRow('Aktivitas selesai', '$completed kali'),
          const SizedBox(height: 12),
          _whiteDetailRow('Total durasi', '$totalDuration menit'),
          const SizedBox(height: 12),
          _whiteDetailRow('Periode laporan', _periodDescription()),
        ],
      ),
    );
  }

  Widget _whiteDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // CHART

  Widget _buildWaterChart(List<IrrigationActivity> activities, bool isMobile) {
    final buckets = _createBuckets(activities);

    final maxVolume = buckets.fold<double>(
      0,
      (maximum, bucket) => bucket.volume > maximum ? bucket.volume : maximum,
    );

    final chartMax = maxVolume <= 0 ? 100.0 : maxVolume * 1.25;
    final interval = chartMax / 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Grafik Penggunaan Air',
          style: TextStyle(
            color: forestGreen,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Distribusi penggunaan air selama periode laporan.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 14),
        Container(
          height: isMobile ? 250 : 290,
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            isMobile ? 4 : 8,
            20,
            isMobile ? 8 : 16,
            12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: BarChart(
            BarChartData(
              maxY: chartMax,
              minY: 0,
              alignment: BarChartAlignment.spaceAround,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: interval,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: Colors.grey.shade200, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: isMobile ? 34 : 42,
                    interval: interval,
                    getTitlesWidget: (value, meta) => Text(
                      value.toStringAsFixed(0),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();

                      if (index < 0 || index >= buckets.length) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          buckets[index].label,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: isMobile ? 8 : 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: List.generate(buckets.length, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: buckets[index].volume,
                      width: isMobile ? 13 : 20,
                      color: leafGreen,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(5),
                      ),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: chartMax,
                        color: cream,
                      ),
                    ),
                  ],
                );
              }),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => forestGreen,
                  tooltipBorderRadius: BorderRadius.circular(8),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.toStringAsFixed(0)} Liter',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: leafGreen,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 7),
            Text(
              'Volume air (Liter)',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  List<_ReportBucket> _createBuckets(List<IrrigationActivity> activities) {
    final now = DateTime.now();
    final buckets = <_ReportBucket>[];

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    if (_selectedPeriod == ReportPeriod.today) {
      for (var i = 0; i < 6; i++) {
        final startHour = i * 4;
        final endHour = startHour + 4;

        final volume = activities
            .where((item) {
              return item.startedAt.hour >= startHour &&
                  item.startedAt.hour < endHour;
            })
            .fold<double>(0, (total, item) => total + item.volumeLiters);

        buckets.add(
          _ReportBucket(
            label: '${startHour.toString().padLeft(2, '0')}:00',
            volume: volume,
          ),
        );
      }

      return buckets;
    }

    if (_selectedPeriod == ReportPeriod.sevenDays) {
      final today = DateTime(now.year, now.month, now.day);

      for (var i = 6; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));

        final volume = activities
            .where((item) => DateUtils.isSameDay(item.startedAt, date))
            .fold<double>(0, (total, item) => total + item.volumeLiters);

        buckets.add(
          _ReportBucket(label: '${date.day}/${date.month}', volume: volume),
        );
      }

      return buckets;
    }

    final start = _startDate();

    for (var i = 0; i < 5; i++) {
      final bucketStart = start.add(Duration(days: i * 6));
      final bucketEnd = bucketStart.add(const Duration(days: 6));
      final lastDay = bucketEnd.subtract(const Duration(days: 1));

      final volume = activities
          .where(
            (item) =>
                !item.startedAt.isBefore(bucketStart) &&
                item.startedAt.isBefore(bucketEnd),
          )
          .fold<double>(0, (total, item) => total + item.volumeLiters);

      final startLabel = '${bucketStart.day} ${months[bucketStart.month - 1]}';
      final endLabel = '${lastDay.day} ${months[lastDay.month - 1]}';

      buckets.add(
        _ReportBucket(label: '$startLabel–$endLabel', volume: volume),
      );
    }

    return buckets;
  }

  // COST BREAKDOWN

  Widget _buildCostBreakdown(double volume, double cost) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rekap Biaya Air',
            style: TextStyle(
              color: forestGreen,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _breakdownRow(
            'Total penggunaan air',
            '${volume.toStringAsFixed(0)} Liter',
          ),
          const SizedBox(height: 12),
          _breakdownRow(
            'Konversi volume',
            '${(volume / 1000).toStringAsFixed(3)} m³',
          ),
          const SizedBox(height: 12),
          _breakdownRow('Tarif simulasi', '${_formatCurrency(tariffPerM3)}/m³'),
          const Divider(height: 24),
          _breakdownRow(
            'Total estimasi biaya',
            _formatCurrency(cost),
            emphasize: true,
          ),
          const SizedBox(height: 12),
          Text(
            'Rumus: (Volume Liter ÷ 1.000) × Tarif per m³',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _breakdownRow(String label, String value, {bool emphasize = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 300) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: emphasize ? leafGreen : forestGreen,
                    fontSize: emphasize ? 15 : 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: emphasize ? leafGreen : forestGreen,
                  fontSize: emphasize ? 15 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ACTIVITY LIST

  Widget _buildActivityList(List<IrrigationActivity> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rincian Aktivitas',
          style: TextStyle(
            color: forestGreen,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Daftar aktivitas penyiraman pada periode laporan.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 14),
        if (activities.isEmpty)
          _buildEmptyState()
        else
          ...activities.map(_activityCard),
      ],
    );
  }

  Widget _activityCard(IrrigationActivity activity) {
    final cost = activity.calculateCost(tariffPerM3);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cream,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.water_drop_outlined, color: leafGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.area,
                  style: const TextStyle(
                    color: forestGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${activity.volumeLiters.toStringAsFixed(0)} L • '
                  '${activity.durationMinutes} menit',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(activity.startedAt),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _formatCurrency(cost),
                style: const TextStyle(
                  color: leafGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // PDF EXPORT

  Widget _buildExportSection(
    List<IrrigationActivity> activities,
    double volume,
    double cost,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: leafGreen.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.picture_as_pdf_outlined, color: forestGreen),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Ekspor Laporan PDF',
                  style: TextStyle(
                    color: forestGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Unduh laporan PDF berdasarkan periode yang sedang dipilih.',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_outlined, color: leafGreen),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Periode laporan',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _periodDescription(),
                        style: const TextStyle(
                          color: forestGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isExporting
                  ? null
                  : () => _downloadPdf(
                      activities: activities,
                      volume: volume,
                      cost: cost,
                    ),
              icon: _isExporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download),
              label: Text(_isExporting ? 'Menyimpan PDF...' : 'Download PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: forestGreen,
                foregroundColor: Colors.white,
                disabledBackgroundColor: forestGreen.withValues(alpha: 0.55),
                disabledForegroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPdf({
    required List<IrrigationActivity> activities,
    required double volume,
    required double cost,
  }) async {
    if (_isExporting) return;

    setState(() => _isExporting = true);

    try {
      final pdfBytes = await ReportPdfService().generate(
        activities: activities,
        period: _periodDescription(),
        tariffPerM3: tariffPerM3,
        totalVolume: volume,
        totalCost: cost,
      );

      final now = DateTime.now();
      final timestamp = [
        now.year.toString().padLeft(4, '0'),
        now.month.toString().padLeft(2, '0'),
        now.day.toString().padLeft(2, '0'),
        '_',
        now.hour.toString().padLeft(2, '0'),
        now.minute.toString().padLeft(2, '0'),
        now.second.toString().padLeft(2, '0'),
      ].join();

      final savedFile = await PublicFileSaver().save(
        bytes: pdfBytes,
        fileName: 'LandiaFarm_Report_$timestamp.pdf',
        mimeType: 'application/pdf',
      );

      if (!mounted) return;

      if (savedFile != null && savedFile.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan PDF berhasil disimpan.'),
            backgroundColor: leafGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF belum berhasil disimpan.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error, stackTrace) {
      debugPrint('Gagal membuat atau menyimpan PDF: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan PDF: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  // EMPTY / ERROR

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(
            Icons.description_outlined,
            size: 40,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 10),
          const Text(
            'Belum ada aktivitas',
            style: TextStyle(color: forestGreen, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            'Tidak ada catatan pada periode laporan ini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, color: leafGreen, size: 40),
            const SizedBox(height: 12),
            const Text(
              'Gagal memuat data laporan.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _activitiesFuture = _repository.getActivities();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }

  // FORMATTERS

  String _formatCurrency(double amount) {
    final digits = amount.round().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);

      final remaining = digits.length - i - 1;

      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }

    return 'Rp${buffer.toString()}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day ${months[date.month - 1]} ${date.year} • '
        '$hour:$minute WIB';
  }

  String _periodDescription() {
    switch (_selectedPeriod) {
      case ReportPeriod.today:
        return 'Hari Ini';
      case ReportPeriod.sevenDays:
        return '7 Hari Terakhir';
      case ReportPeriod.thirtyDays:
        return '30 Hari Terakhir';
    }
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        'LANDIA FARM APP • Laporan Operasional',
        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
      ),
    );
  }
}

class _ReportBucket {
  final String label;
  final double volume;

  const _ReportBucket({required this.label, required this.volume});
}

class _SensorSnapshot {
  final String title;
  final String value;
  final String status;
  final IconData icon;

  const _SensorSnapshot(this.title, this.value, this.status, this.icon);
}
