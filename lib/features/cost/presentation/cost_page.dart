import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../irrigation/data/mock_irrigation_repository.dart';
import '../../irrigation/data/irrigation_repository.dart';
import '../../irrigation/domain/irrigation_activity.dart';

enum CostPeriod { today, sevenDays, thirtyDays }

class CostPage extends StatefulWidget {
  const CostPage({super.key});

  @override
  State<CostPage> createState() => _CostPageState();
}

class _CostPageState extends State<CostPage> {
  static const Color forestGreen = Color(0xFF173F35);
  static const Color leafGreen = Color(0xFF397A52);
  static const Color cream = Color(0xFFF4F3E9);
  static const Color harvestGold = Color(0xFFD8A85D);

  // Tarif simulasi, bukan tarif resmi Landia Farm.
  static const double tariffPerM3 = 1000;

  final IrrigationRepository _repository = MockIrrigationRepository();

  late Future<List<IrrigationActivity>> _activitiesFuture;

  CostPeriod _selectedPeriod = CostPeriod.sevenDays;

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

  DateTime _startDate(CostPeriod period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (period) {
      case CostPeriod.today:
        return today;
      case CostPeriod.sevenDays:
        return today.subtract(const Duration(days: 6));
      case CostPeriod.thirtyDays:
        return today.subtract(const Duration(days: 29));
    }
  }

  List<IrrigationActivity> _filterActivities(
    List<IrrigationActivity> activities,
  ) {
    final start = _startDate(_selectedPeriod);
    final now = DateTime.now();

    return activities.where((activity) {
      return !activity.startedAt.isBefore(start) &&
          !activity.startedAt.isAfter(now);
    }).toList()..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  double _totalVolume(List<IrrigationActivity> activities) {
    return activities.fold(0.0, (total, item) => total + item.volumeLiters);
  }

  double _totalCost(List<IrrigationActivity> activities) {
    return activities.fold(
      0.0,
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
              final horizontalPadding = isMobile ? 16.0 : 24.0;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(horizontalPadding),
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
                        _buildTariffCard(),
                        const SizedBox(height: 24),
                        _buildPeriodSelector(),
                        const SizedBox(height: 18),
                        _buildMainCostCard(cost),
                        const SizedBox(height: 14),
                        _buildSummaryCards(activities.length, volume, isMobile),
                        const SizedBox(height: 28),
                        _buildChartSection(activities, isMobile),
                        const SizedBox(height: 28),
                        _buildBreakdownSection(volume, cost),
                        const SizedBox(height: 28),
                        _buildActivitySection(activities, isMobile),
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
          'Biaya Air',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: forestGreen,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Pantau penggunaan air dan estimasi biaya Landia Farm.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // DEMO NOTICE

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
              'DATA DEMO — Volume dan biaya masih menggunakan data simulasi.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // TARIFF

  Widget _buildTariffCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: forestGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.price_change_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tarif Air Simulasi',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  'Rp1.000 / m³',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tarif contoh untuk perhitungan aplikasi.',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // PERIOD SELECTOR

  Widget _buildPeriodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Periode Rekap',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: forestGreen,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _periodChip('Hari Ini', CostPeriod.today),
            _periodChip('7 Hari', CostPeriod.sevenDays),
            _periodChip('30 Hari', CostPeriod.thirtyDays),
          ],
        ),
      ],
    );
  }

  Widget _periodChip(String label, CostPeriod period) {
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
      labelStyle: TextStyle(
        color: selected ? Colors.white : forestGreen,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      side: BorderSide(color: selected ? leafGreen : Colors.grey.shade300),
      showCheckmark: false,
    );
  }

  // MAIN COST

  Widget _buildMainCostCard(double cost) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: leafGreen.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Menggunakan Column agar judul tidak overflow pada HP sempit.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.payments_outlined, color: leafGreen),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Estimasi Biaya Periode Ini',
                  softWrap: true,
                  style: TextStyle(color: forestGreen, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _formatCurrency(cost),
              style: const TextStyle(
                color: forestGreen,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _periodDescription(),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // SUMMARY CARDS

  Widget _buildSummaryCards(int activityCount, double volume, bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 850
            ? 3
            : constraints.maxWidth >= 500
            ? 2
            : 1;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: columns == 1 ? 3.2 : 1.8,
          children: [
            _summaryCard(
              'Volume Air',
              '${volume.toStringAsFixed(0)} Liter',
              Icons.water,
            ),
            _summaryCard(
              'Aktivitas',
              '$activityCount kali',
              Icons.water_drop_outlined,
            ),
            _summaryCard(
              'Tarif per m³',
              _formatCurrency(tariffPerM3),
              Icons.price_check_outlined,
            ),
          ],
        );
      },
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
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: forestGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // CHART

  Widget _buildChartSection(
    List<IrrigationActivity> activities,
    bool isMobile,
  ) {
    final buckets = _createChartBuckets(activities);

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
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: forestGreen,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Volume air berdasarkan periode yang dipilih.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 18),
        Container(
          height: isMobile ? 250 : 280,
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
                horizontalInterval: interval > 0 ? interval : 25,
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
                },
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
                    interval: interval > 0 ? interval : 25,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(0),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 9,
                        ),
                      );
                    },
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
                            fontSize: isMobile
                                ? (_selectedPeriod == CostPeriod.thirtyDays
                                      ? 7
                                      : 8)
                                : 9,
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
                      width: isMobile ? 12 : 18,
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
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
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

  List<_ChartBucket> _createChartBuckets(List<IrrigationActivity> activities) {
    final now = DateTime.now();
    final buckets = <_ChartBucket>[];

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

    String formatShortDate(DateTime date) {
      return '${date.day} ${months[date.month - 1]}';
    }

    if (_selectedPeriod == CostPeriod.today) {
      for (var i = 0; i < 6; i++) {
        final startHour = i * 4;
        final endHour = startHour + 4;

        final volume = activities
            .where((activity) {
              final hour = activity.startedAt.hour;
              return hour >= startHour && hour < endHour;
            })
            .fold<double>(0, (total, item) => total + item.volumeLiters);

        buckets.add(
          _ChartBucket(
            label: '${startHour.toString().padLeft(2, '0')}:00',
            volume: volume,
          ),
        );
      }

      return buckets;
    }

    if (_selectedPeriod == CostPeriod.sevenDays) {
      final today = DateTime(now.year, now.month, now.day);

      for (var i = 6; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));

        final volume = activities
            .where((item) => DateUtils.isSameDay(item.startedAt, date))
            .fold<double>(0, (total, item) => total + item.volumeLiters);

        buckets.add(
          _ChartBucket(label: '${date.day}/${date.month}', volume: volume),
        );
      }

      return buckets;
    }

    // Periode 30 hari dibagi menjadi 5 kelompok,
    // masing-masing mencakup 6 hari.
    final start = _startDate(CostPeriod.thirtyDays);

    for (var i = 0; i < 5; i++) {
      final bucketStart = start.add(Duration(days: i * 6));
      final bucketEnd = bucketStart.add(const Duration(days: 6));
      final bucketLastDay = bucketEnd.subtract(const Duration(days: 1));

      final volume = activities
          .where((item) {
            return !item.startedAt.isBefore(bucketStart) &&
                item.startedAt.isBefore(bucketEnd);
          })
          .fold<double>(0, (total, item) => total + item.volumeLiters);

      buckets.add(
        _ChartBucket(
          label:
              '${formatShortDate(bucketStart)}–'
              '${formatShortDate(bucketLastDay)}',
          volume: volume,
        ),
      );
    }

    return buckets;
  }

  // BREAKDOWN

  Widget _buildBreakdownSection(double volume, double cost) {
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
            'Rincian Penggunaan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: forestGreen,
            ),
          ),
          const SizedBox(height: 16),
          _breakdownRow(
            'Total volume air',
            '${volume.toStringAsFixed(0)} Liter',
          ),
          const SizedBox(height: 12),
          _breakdownRow(
            'Konversi volume',
            '${(volume / 1000).toStringAsFixed(3)} m³',
          ),
          const SizedBox(height: 12),
          _breakdownRow('Tarif per m³', _formatCurrency(tariffPerM3)),
          const Divider(height: 24),
          _breakdownRow(
            'Total estimasi biaya',
            _formatCurrency(cost),
            emphasize: true,
          ),
          const SizedBox(height: 12),
          Text(
            'Rumus: (Volume Liter ÷ 1.000) × Tarif per m³',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _breakdownRow(String label, String value, {bool emphasize = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 300;

        final labelWidget = Text(
          label,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
        );

        final valueWidget = Text(
          value,
          textAlign: TextAlign.end,
          style: TextStyle(
            color: emphasize ? leafGreen : forestGreen,
            fontWeight: FontWeight.bold,
            fontSize: emphasize ? 15 : 12,
          ),
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              labelWidget,
              const SizedBox(height: 4),
              Align(alignment: Alignment.centerRight, child: valueWidget),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: labelWidget),
            const SizedBox(width: 8),
            Flexible(child: valueWidget),
          ],
        );
      },
    );
  }

  // ACTIVITY LIST

  Widget _buildActivitySection(
    List<IrrigationActivity> activities,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rincian Aktivitas',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: forestGreen,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Estimasi biaya setiap aktivitas penyiraman.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 14),
        if (activities.isEmpty)
          _buildEmptyState()
        else
          ...activities.map((activity) => _activityCard(activity, isMobile)),
      ],
    );
  }

  Widget _activityCard(IrrigationActivity activity, bool isMobile) {
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
        crossAxisAlignment: CrossAxisAlignment.center,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: forestGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
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
              alignment: Alignment.centerRight,
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
            Icons.water_drop_outlined,
            size: 40,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 10),
          const Text(
            'Belum ada penggunaan air',
            style: TextStyle(color: forestGreen, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            'Belum terdapat aktivitas pada periode ini.',
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
            const Icon(Icons.cloud_off_outlined, size: 40, color: leafGreen),
            const SizedBox(height: 12),
            const Text(
              'Gagal memuat data penggunaan air.',
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
      case CostPeriod.today:
        return 'Rekap penggunaan air hari ini';
      case CostPeriod.sevenDays:
        return 'Rekap penggunaan air selama 7 hari terakhir';
      case CostPeriod.thirtyDays:
        return 'Rekap penggunaan air selama 30 hari terakhir';
    }
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        'LANDIA FARM APP • Biaya Air',
        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
      ),
    );
  }
}

class _ChartBucket {
  final String label;
  final double volume;

  const _ChartBucket({required this.label, required this.volume});
}
