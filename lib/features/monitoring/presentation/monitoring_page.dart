import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../data/mock_sensor_repository.dart';
import '../data/sensor_repository.dart';
import '../domain/sensor_reading.dart';

class MonitoringPage extends StatefulWidget {
  const MonitoringPage({super.key});

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
  static const Color forestGreen = Color(0xFF173F35);
  static const Color leafGreen = Color(0xFF397A52);
  static const Color cream = Color(0xFFF4F3E9);
  static const Color harvestGold = Color(0xFFD8A85D);

  final SensorRepository _repository = MockSensorRepository();

  late final Future<List<SensorDefinition>> _sensorsFuture;
  late Future<List<SensorReading>> _historyFuture;

  String _selectedSensorId = 'temperature';

  MonitoringPeriod _selectedPeriod = MonitoringPeriod.twentyFourHours;

  @override
  void initState() {
    super.initState();

    _sensorsFuture = _repository.getSensors();

    _historyFuture = _repository.getHistory(
      sensorId: _selectedSensorId,
      period: _selectedPeriod,
    );
  }

  void _selectSensor(SensorDefinition sensor) {
    if (_selectedSensorId == sensor.id) return;

    setState(() {
      _selectedSensorId = sensor.id;
      _historyFuture = _repository.getHistory(
        sensorId: sensor.id,
        period: _selectedPeriod,
      );
    });
  }

  void _selectPeriod(MonitoringPeriod period) {
    if (_selectedPeriod == period) return;

    setState(() {
      _selectedPeriod = period;
      _historyFuture = _repository.getHistory(
        sensorId: _selectedSensorId,
        period: period,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SensorDefinition>>(
      future: _sensorsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorState();
        }

        final sensors = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildDemoNotice(),
                  const SizedBox(height: 28),
                  _buildSensorCategories(sensors),
                  const SizedBox(height: 28),
                  _buildChartSection(sensors),
                  const SizedBox(height: 24),
                  _buildFooter(),
                ],
              ),
            ),
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
          'Monitoring Sensor',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: forestGreen,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Pemantauan kondisi sensor Landia Farm.',
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
        children: [
          Icon(Icons.info_outline, color: forestGreen),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'DATA DEMO — Belum terhubung dengan sensor ESP32.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // SENSOR CATEGORIES

  Widget _buildSensorCategories(List<SensorDefinition> sensors) {
    final categories = [
      (
        category: SensorCategory.air,
        title: 'Kondisi Udara',
        subtitle: 'Suhu dan kelembapan udara',
        icon: Icons.cloud_outlined,
      ),
      (
        category: SensorCategory.tanah,
        title: 'Kondisi Tanah',
        subtitle: 'Kelembapan media tanam',
        icon: Icons.grass,
      ),
      (
        category: SensorCategory.tangki,
        title: 'Tangki Air',
        subtitle: 'Ketinggian air tangki',
        icon: Icons.water,
      ),
      (
        category: SensorCategory.hujanDanAliran,
        title: 'Hujan dan Aliran Air',
        subtitle: 'Deteksi hujan dan debit air',
        icon: Icons.waves,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori Sensor',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: forestGreen,
          ),
        ),
        const SizedBox(height: 16),
        for (final category in categories)
          _buildCategorySection(
            title: category.title,
            subtitle: category.subtitle,
            icon: category.icon,
            sensors: sensors
                .where((sensor) => sensor.category == category.category)
                .toList(),
          ),
      ],
    );
  }

  Widget _buildCategorySection({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<SensorDefinition> sensors,
  }) {
    if (sensors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: leafGreen, size: 21),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 850
                  ? 3
                  : constraints.maxWidth >= 500
                  ? 2
                  : 1;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sensors.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 128,
                ),
                itemBuilder: (context, index) {
                  return _buildSensorCard(sensors[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // SENSOR CARD

  Widget _buildSensorCard(SensorDefinition sensor) {
    final isSelected = _selectedSensorId == sensor.id;

    return Material(
      color: isSelected ? cream : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _selectSensor(sensor),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? leafGreen : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(_sensorIcon(sensor.id), color: leafGreen, size: 22),
                  const Spacer(),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: leafGreen, size: 19),
                ],
              ),
              Text(
                sensor.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      sensor.formattedValue,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: forestGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      sensor.status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontSize: 10, color: leafGreen),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _sensorIcon(String id) {
    switch (id) {
      case 'temperature':
        return Icons.thermostat;
      case 'air_humidity':
        return Icons.water_drop_outlined;
      case 'soil_moisture':
        return Icons.grass;
      case 'water_level':
        return Icons.water;
      case 'rain':
        return Icons.cloud_outlined;
      case 'water_flow':
        return Icons.waves;
      default:
        return Icons.sensors;
    }
  }

  // CHART SECTION

  Widget _buildChartSection(List<SensorDefinition> sensors) {
    final selectedSensor = sensors.firstWhere(
      (sensor) => sensor.id == _selectedSensorId,
    );

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
            'Grafik Tren Sensor',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: forestGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Riwayat pembacaan ${selectedSensor.name}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 16),
          _buildPeriodSelector(),
          const SizedBox(height: 24),
          FutureBuilder<List<SensorReading>>(
            future: _historyFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 230,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return _buildChartError();
              }

              return _buildLineChart(snapshot.data!, selectedSensor);
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Periode: ${_periodLabel(_selectedPeriod)} • Data simulasi',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // PERIOD FILTER

  Widget _buildPeriodSelector() {
    final periods = [
      (period: MonitoringPeriod.oneHour, label: '1 Jam'),
      (period: MonitoringPeriod.twentyFourHours, label: '24 Jam'),
      (period: MonitoringPeriod.sevenDays, label: '7 Hari'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: periods.map((item) {
        final selected = _selectedPeriod == item.period;

        return ChoiceChip(
          label: Text(item.label),
          selected: selected,
          selectedColor: cream,
          onSelected: (_) => _selectPeriod(item.period),
        );
      }).toList(),
    );
  }

  // LINE CHART - RESPONSIVE

  Widget _buildLineChart(
    List<SensorReading> readings,
    SensorDefinition sensor,
  ) {
    if (readings.isEmpty) {
      return const SizedBox(
        height: 230,
        child: Center(child: Text('Belum ada data sensor.')),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        final values = readings.map((reading) => reading.value).toList();

        final minValue = values.reduce(math.min);
        final maxValue = values.reduce(math.max);

        // Tentukan rentang sumbu Y.
        final difference = maxValue - minValue;
        final padding = difference == 0 ? 1.0 : difference * 0.15;

        final rawMinY = math.max(0.0, minValue - padding);
        final rawMaxY = maxValue + padding;

        // Interval angka yang lebih mudah dibaca.
        final interval = _calculateYAxisInterval(rawMaxY - rawMinY);

        // Bulatkan batas sumbu agar label tidak bertumpuk
        // di dekat nilai minimum dan maksimum.
        final minY = (rawMinY / interval).floor() * interval;
        final maxY = math.max(
          minY + interval * 4,
          (rawMaxY / interval).ceil() * interval,
        );

        final spots = readings.asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.value);
        }).toList();

        final xInterval = _bottomLabelInterval(
          readings.length,
          isMobile: isMobile,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Satuan: ${sensor.unit}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: isMobile ? 220 : 250,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: math.max(1, readings.length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY,

                  // TOOLTIP
                  lineTouchData: LineTouchData(
                    enabled: true,
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => forestGreen,
                      tooltipBorderRadius: BorderRadius.circular(10),
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      tooltipMargin: 12,
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final value = sensor.unit == '%'
                              ? '${spot.y.toStringAsFixed(0)}%'
                              : '${spot.y.toStringAsFixed(1)} ${sensor.unit}';

                          return LineTooltipItem(
                            value,
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),

                  // GRID
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: interval,
                  ),

                  borderData: FlBorderData(show: false),

                  // AXIS LABELS
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),

                    // Y AXIS
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: interval,
                        reservedSize: isMobile ? 38 : 45,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _formatAxisValue(value, sensor.unit),
                            style: TextStyle(
                              fontSize: isMobile ? 9 : 10,
                              color: forestGreen,
                            ),
                          );
                        },
                      ),
                    ),

                    // X AXIS
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: isMobile ? 30 : 34,
                        interval: xInterval.toDouble(),
                        getTitlesWidget: (value, meta) {
                          final index = value.round();

                          if (index < 0 ||
                              index >= readings.length ||
                              (value - index).abs() > 0.01) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _formatTime(readings[index].recordedAt),
                              style: TextStyle(
                                fontSize: isMobile ? 9 : 10,
                                color: forestGreen,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // SENSOR LINE
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: false,
                      color: leafGreen,
                      barWidth: 3,
                      dotData: FlDotData(show: readings.length <= 25),
                      belowBarData: BarAreaData(
                        show: true,
                        color: leafGreen.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // AXIS INTERVAL

  double _calculateYAxisInterval(double range) {
    if (range <= 0 || !range.isFinite) {
      return 1;
    }

    final rawInterval = range / 4;
    final magnitude = math
        .pow(10, (math.log(rawInterval) / math.ln10).floor())
        .toDouble();

    final normalized = rawInterval / magnitude;

    final niceValue = normalized <= 1
        ? 1.0
        : normalized <= 2
        ? 2.0
        : normalized <= 5
        ? 5.0
        : 10.0;

    return niceValue * magnitude;
  }

  String _formatAxisValue(double value, String unit) {
    if (unit == '%') {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
  }

  // X AXIS INTERVAL

  double _bottomLabelInterval(int length, {required bool isMobile}) {
    if (length <= 13) {
      return isMobile ? 3 : 2;
    }

    if (length <= 25) {
      return isMobile ? 8 : 4;
    }

    return isMobile ? 14 : 7;
  }

  // TIME FORMAT

  String _formatTime(DateTime date) {
    if (_selectedPeriod == MonitoringPeriod.sevenDays) {
      return '${date.day}/${date.month}';
    }

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    if (_selectedPeriod == MonitoringPeriod.twentyFourHours) {
      return '$hour:00';
    }

    return '$hour:$minute';
  }

  String _periodLabel(MonitoringPeriod period) {
    switch (period) {
      case MonitoringPeriod.oneHour:
        return '1 Jam Terakhir';
      case MonitoringPeriod.twentyFourHours:
        return '24 Jam Terakhir';
      case MonitoringPeriod.sevenDays:
        return '7 Hari Terakhir';
    }
  }

  // ERROR STATES

  Widget _buildChartError() {
    return const SizedBox(
      height: 230,
      child: Center(child: Text('Gagal memuat data grafik sensor.')),
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Gagal memuat daftar sensor. Silakan coba kembali.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // FOOTER

  Widget _buildFooter() {
    return Center(
      child: Text(
        'LANDIA FARM APP • Monitoring IoT',
        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
      ),
    );
  }
}
