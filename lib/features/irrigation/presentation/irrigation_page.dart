import 'package:flutter/material.dart';

import '../data/mock_irrigation_repository.dart';
import '../data/irrigation_repository.dart';
import '../domain/irrigation_activity.dart';

class IrrigationPage extends StatefulWidget {
  const IrrigationPage({super.key});

  @override
  State<IrrigationPage> createState() => _IrrigationPageState();
}

class _IrrigationPageState extends State<IrrigationPage> {
  static const Color forestGreen = Color(0xFF173F35);
  static const Color leafGreen = Color(0xFF397A52);
  static const Color cream = Color(0xFFF4F3E9);
  static const Color harvestGold = Color(0xFFD8A85D);

  // Tarif simulasi, bukan tarif resmi Landia Farm.
  static const double tariffPerM3 = 1000;

  final IrrigationRepository _repository = MockIrrigationRepository();

  late Future<List<IrrigationActivity>> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    _activitiesFuture = _repository.getActivities();
  }

  Future<void> _refreshActivities() async {
    final future = _repository.getActivities();

    setState(() {
      _activitiesFuture = future;
    });

    await future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<IrrigationActivity>>(
      future: _activitiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorState();
        }

        final activities = snapshot.data!;
        final todayActivities = activities
            .where(
              (activity) =>
                  DateUtils.isSameDay(activity.startedAt, DateTime.now()),
            )
            .toList();

        final todayVolume = todayActivities.fold<double>(
          0,
          (total, activity) => total + activity.volumeLiters,
        );

        final todayCost = todayActivities.fold<double>(
          0,
          (total, activity) => total + activity.calculateCost(tariffPerM3),
        );

        return RefreshIndicator(
          onRefresh: _refreshActivities,
          color: leafGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
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
                    _buildModeCard(),
                    const SizedBox(height: 24),
                    _buildSummary(
                      todayActivities.length,
                      todayVolume,
                      todayCost,
                    ),
                    const SizedBox(height: 28),
                    _buildScheduleSection(),
                    const SizedBox(height: 28),
                    _buildActivitySection(activities),
                    const SizedBox(height: 24),
                    _buildFooter(),
                  ],
                ),
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
          'Penyiraman',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: forestGreen,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Pantau aktivitas dan penggunaan air Landia Farm.',
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
              'DATA DEMO — Aktivitas belum berasal dari ESP32.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // AUTOMATIC MODE

  Widget _buildModeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: forestGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.autorenew, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode Operasional',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  'Otomatis',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Penyiraman berjalan berdasarkan jadwal ESP32.',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Color(0xFFB8E0C2), size: 24),
        ],
      ),
    );
  }

  // SUMMARY

  Widget _buildSummary(int activityCount, double volume, double cost) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Hari Ini',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: forestGreen,
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
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
                _buildSummaryCard(
                  title: 'Aktivitas',
                  value: '$activityCount kali',
                  icon: Icons.water_drop_outlined,
                ),
                _buildSummaryCard(
                  title: 'Volume Air',
                  value: '${volume.toStringAsFixed(0)} L',
                  icon: Icons.water,
                ),
                _buildSummaryCard(
                  title: 'Estimasi Biaya',
                  value: _formatCurrency(cost),
                  icon: Icons.payments_outlined,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
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
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: forestGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // SCHEDULE

  Widget _buildScheduleSection() {
    final schedules = [
      ('Pagi', '07:00', 'Jadwal pagi'),
      ('Sore', '16:00', 'Jadwal sore'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jadwal Penyiraman',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: forestGreen,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Informasi jadwal simulasi operasional.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 14),
        ...schedules.map((schedule) {
          return Container(
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
                  child: Icon(
                    schedule.$1 == 'Pagi'
                        ? Icons.wb_sunny_outlined
                        : Icons.wb_twilight,
                    color: leafGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.$1,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: forestGreen,
                        ),
                      ),
                      Text(
                        schedule.$3,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  schedule.$2,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: forestGreen,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 4),
        Text(
          'Jadwal ini hanya contoh tampilan dan belum mengatur perangkat.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
        ),
      ],
    );
  }

  // ACTIVITY LIST

  Widget _buildActivitySection(List<IrrigationActivity> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Aktivitas Penyiraman',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: forestGreen,
                ),
              ),
            ),
            Text(
              '${activities.length} catatan',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (activities.isEmpty)
          _buildEmptyState()
        else
          ...activities.map(_buildActivityCard),
      ],
    );
  }

  Widget _buildActivityCard(IrrigationActivity activity) {
    final cost = activity.calculateCost(tariffPerM3);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: CircleAvatar(
            backgroundColor: cream,
            child: const Icon(Icons.water_drop_outlined, color: leafGreen),
          ),
          title: Text(
            activity.area,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: forestGreen,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              '${_formatDate(activity.startedAt)}\n'
              '${activity.durationMinutes} menit • '
              '${activity.volumeLiters.toStringAsFixed(0)} Liter',
              style: TextStyle(
                fontSize: 11,
                height: 1.6,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          trailing: _buildStatusBadge(activity.status),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Volume air',
              '${activity.volumeLiters.toStringAsFixed(1)} Liter',
            ),
            const SizedBox(height: 9),
            _buildDetailRow('Durasi', '${activity.durationMinutes} menit'),
            const SizedBox(height: 9),
            _buildDetailRow(
              'Tarif simulasi',
              '${_formatCurrency(tariffPerM3)}/m³',
            ),
            const SizedBox(height: 9),
            _buildDetailRow(
              'Estimasi biaya',
              _formatCurrency(cost),
              emphasize: true,
            ),
            if (activity.note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  activity.note,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool emphasize = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: emphasize ? leafGreen : forestGreen,
          ),
        ),
      ],
    );
  }

  // STATUS

  Widget _buildStatusBadge(IrrigationStatus status) {
    final label = switch (status) {
      IrrigationStatus.completed => 'Selesai',
      IrrigationStatus.failed => 'Gagal',
      IrrigationStatus.cancelled => 'Dibatalkan',
    };

    final color = switch (status) {
      IrrigationStatus.completed => leafGreen,
      IrrigationStatus.failed => Colors.red.shade700,
      IrrigationStatus.cancelled => Colors.orange.shade800,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // FORMATTERS

  String _formatCurrency(double amount) {
    final rounded = amount.round();
    final digits = rounded.toString();
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

  // EMPTY / ERROR

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.water_drop_outlined,
            size: 42,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          const Text(
            'Belum ada aktivitas penyiraman',
            style: TextStyle(fontWeight: FontWeight.bold, color: forestGreen),
          ),
          const SizedBox(height: 6),
          Text(
            'Catatan penyiraman akan tampil di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Gagal memuat aktivitas penyiraman.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // FOOTER

  Widget _buildFooter() {
    return Center(
      child: Text(
        'LANDIA FARM APP • Penyiraman Otomatis',
        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
      ),
    );
  }
}
