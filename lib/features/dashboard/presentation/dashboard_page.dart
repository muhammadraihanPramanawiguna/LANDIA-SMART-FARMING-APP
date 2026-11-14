import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // Design system LANDIA FARM — dipertahankan.
  static const Color forestGreen = Color(0xFF173F35);
  static const Color leafGreen = Color(0xFF397A52);
  static const Color cream = Color(0xFFF4F3E9);
  static const Color harvestGold = Color(0xFFD8A85D);

  static const List<_SensorData> _sensors = [
    _SensorData(
      title: 'Suhu Udara',
      value: '28.5',
      unit: '°C',
      icon: Icons.thermostat,
      color: Colors.deepOrange,
      status: 'Normal',
    ),
    _SensorData(
      title: 'Kelembapan Udara',
      value: '75',
      unit: '%',
      icon: Icons.water_drop_outlined,
      color: Colors.blue,
      status: 'Normal',
    ),
    _SensorData(
      title: 'Kelembapan Tanah',
      value: '55',
      unit: '%',
      icon: Icons.grass,
      color: leafGreen,
      status: 'Normal',
    ),
    _SensorData(
      title: 'Level Air Tangki',
      value: '80',
      unit: '%',
      icon: Icons.water,
      color: Colors.cyan,
      status: 'Aman',
    ),
    _SensorData(
      title: 'Sensor Hujan',
      value: '0',
      unit: '%',
      icon: Icons.cloud_outlined,
      color: Colors.indigo,
      status: 'Tidak terdeteksi',
    ),
    _SensorData(
      title: 'Debit Air',
      value: '0.0',
      unit: 'L/min',
      icon: Icons.speed,
      color: Colors.teal,
      status: 'Tidak mengalir',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth < 600 ? 16.0 : 24.0;

    return Container(
      color: cream,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 24,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1500),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth = constraints.maxWidth;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),

                    _buildDemoNotice(),
                    const SizedBox(height: 28),

                    _buildSectionTitle(
                      'Kondisi Lingkungan',
                      'Ringkasan pembacaan sensor',
                    ),
                    const SizedBox(height: 14),

                    _buildSensorGrid(contentWidth),
                    const SizedBox(height: 28),

                    _buildSectionTitle(
                      'Penggunaan Air',
                      'Ringkasan konsumsi dan estimasi biaya',
                    ),
                    const SizedBox(height: 14),

                    _buildWaterSummary(contentWidth),
                    const SizedBox(height: 28),

                    _buildSectionTitle(
                      'Aktivitas Penyiraman',
                      'Aktivitas terbaru sistem irigasi',
                    ),
                    const SizedBox(height: 14),

                    _buildIrrigationActivity(),
                    const SizedBox(height: 28),

                    _buildSectionTitle(
                      'Status Sistem',
                      'Informasi konektivitas perangkat',
                    ),
                    const SizedBox(height: 14),

                    _buildSystemStatus(),
                    const SizedBox(height: 28),

                    Center(
                      child: Text(
                        'LANDIA FARM • Smart Farming Monitoring System',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: forestGreen,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Pantau kondisi operasional Landia Farm.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: leafGreen.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today_outlined, size: 16, color: forestGreen),
              SizedBox(width: 8),
              Text(
                'Data Simulasi',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: forestGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDemoNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: harvestGold.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: harvestGold.withValues(alpha: 0.5)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Color(0xFF9A6A1D)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Mode Demo aktif. Seluruh angka pada Dashboard ini '
              'merupakan data simulasi, bukan pembacaan sensor aktual.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: Color(0xFF79551F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: forestGreen,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // Desktop: 3 kolom. Tablet dan HP: 2 kolom.
  // Layar sangat sempit: 1 kolom.
  Widget _buildSensorGrid(double width) {
    final columns = width >= 1000
        ? 3
        : width >= 320
        ? 2
        : 1;

    const spacing = 12.0;

    final cardWidth = (width - spacing * (columns - 1)) / columns;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: _sensors.map((sensor) {
        return SizedBox(
          width: cardWidth,
          child: _SensorCard(sensor: sensor),
        );
      }).toList(),
    );
  }

  Widget _buildWaterSummary(double width) {
    final columns = width >= 650 ? 2 : 1;
    const spacing = 12.0;

    final cardWidth = (width - spacing * (columns - 1)) / columns;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        SizedBox(
          width: cardWidth,
          child: const _SummaryCard(
            title: 'Penggunaan Air Hari Ini',
            value: '500',
            unit: 'Liter',
            description: 'Total volume simulasi',
            icon: Icons.water_drop,
            color: Colors.blue,
          ),
        ),
        SizedBox(
          width: cardWidth,
          child: const _SummaryCard(
            title: 'Estimasi Biaya Bulan Ini',
            value: 'Rp15.000',
            unit: '',
            description: 'Tarif simulasi Rp1.000/m³',
            icon: Icons.payments_outlined,
            color: leafGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildIrrigationActivity() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.water_drop, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Penyiraman Area Tanaman',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Data aktivitas simulasi',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: leafGreen.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Selesai',
                  style: TextStyle(
                    color: leafGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          const Row(
            children: [
              Expanded(
                child: _ActivityValue(label: 'Waktu', value: '09:00'),
              ),
              Expanded(
                child: _ActivityValue(label: 'Durasi', value: '10 menit'),
              ),
              Expanded(
                child: _ActivityValue(label: 'Volume', value: '100 L'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: const Column(
        children: [
          _StatusRow(
            icon: Icons.memory,
            title: 'ESP32',
            subtitle: 'Status simulasi perangkat',
            status: 'Demo',
          ),
          Divider(height: 24),
          _StatusRow(
            icon: Icons.cloud_outlined,
            title: 'Server',
            subtitle: 'Belum terhubung ke backend',
            status: 'Belum terhubung',
          ),
          Divider(height: 24),
          _StatusRow(
            icon: Icons.sensors,
            title: 'Sensor IoT',
            subtitle: 'Menampilkan data simulasi',
            status: 'Demo',
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.025),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}

class _SensorData {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final String status;

  const _SensorData({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.status,
  });
}

class _SensorCard extends StatelessWidget {
  final _SensorData sensor;

  const _SensorCard({required this.sensor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(sensor.icon, color: sensor.color, size: 22),
              const Spacer(),
              Icon(Icons.circle, color: sensor.color, size: 8),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            sensor.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  sensor.value,
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: DashboardPage.forestGreen,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  sensor.unit,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            sensor.status,
            style: TextStyle(
              fontSize: 11,
              color: sensor.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String description;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: DashboardPage.forestGreen,
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 5),
                  Text(
                    unit,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _ActivityValue extends StatelessWidget {
  final String label;
  final String value;

  const _ActivityValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;

  const _StatusRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: DashboardPage.leafGreen, size: 22),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            status,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: DashboardPage.leafGreen,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
