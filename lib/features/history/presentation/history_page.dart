import 'package:flutter/material.dart';

import '../data/mock_history_repository.dart';
import '../data/history_repository.dart';
import '../domain/history_record.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  static const Color forestGreen = Color(0xFF173F35);
  static const Color leafGreen = Color(0xFF397A52);
  static const Color cream = Color(0xFFF4F3E9);
  static const Color harvestGold = Color(0xFFD8A85D);

  final HistoryRepository _repository = MockHistoryRepository();

  late Future<List<HistoryRecord>> _historyFuture;

  HistoryType? _selectedType;
  HistoryPeriod _selectedPeriod = HistoryPeriod.sevenDays;

  @override
  void initState() {
    super.initState();
    _historyFuture = _repository.getHistory();
  }

  Future<void> _refreshHistory() async {
    final future = _repository.getHistory();

    setState(() {
      _historyFuture = future;
    });

    await future;
  }

  List<HistoryRecord> _filterRecords(List<HistoryRecord> records) {
    final now = DateTime.now();

    final startDate = switch (_selectedPeriod) {
      HistoryPeriod.today => DateTime(now.year, now.month, now.day),
      HistoryPeriod.sevenDays => now.subtract(const Duration(days: 7)),
      HistoryPeriod.thirtyDays => now.subtract(const Duration(days: 30)),
    };

    return records.where((record) {
      final matchesPeriod = !record.recordedAt.isBefore(startDate);
      final matchesType = _selectedType == null || record.type == _selectedType;

      return matchesPeriod && matchesType;
    }).toList()..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HistoryRecord>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorState();
        }

        final records = _filterRecords(snapshot.data!);

        return RefreshIndicator(
          onRefresh: _refreshHistory,
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
                    const SizedBox(height: 24),
                    _buildSummary(snapshot.data!),
                    const SizedBox(height: 28),
                    _buildFilters(),
                    const SizedBox(height: 22),
                    _buildHistoryList(records),
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
          'Histori Aktivitas',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: forestGreen,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Riwayat pembacaan sensor dan aktivitas penyiraman.',
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
              'DATA DEMO — Riwayat belum berasal dari backend atau ESP32.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // SUMMARY

  Widget _buildSummary(List<HistoryRecord> records) {
    final sensorCount = records
        .where((record) => record.type == HistoryType.sensor)
        .length;

    final irrigationCount = records
        .where((record) => record.type == HistoryType.irrigation)
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 3 : 1;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: columns == 1 ? 3.2 : 2.1,
          children: [
            _buildSummaryCard(
              title: 'Total Catatan',
              value: '${records.length}',
              icon: Icons.history,
            ),
            _buildSummaryCard(
              title: 'Histori Sensor',
              value: '$sensorCount',
              icon: Icons.sensors,
            ),
            _buildSummaryCard(
              title: 'Penyiraman',
              value: '$irrigationCount',
              icon: Icons.water_drop_outlined,
            ),
          ],
        );
      },
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: forestGreen,
                    fontSize: 22,
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

  // FILTERS

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filter Histori',
          style: TextStyle(
            color: forestGreen,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTypeChip(
              label: 'Semua',
              selected: _selectedType == null,
              onSelected: () {
                setState(() => _selectedType = null);
              },
            ),
            _buildTypeChip(
              label: 'Sensor',
              selected: _selectedType == HistoryType.sensor,
              onSelected: () {
                setState(() {
                  _selectedType = HistoryType.sensor;
                });
              },
            ),
            _buildTypeChip(
              label: 'Penyiraman',
              selected: _selectedType == HistoryType.irrigation,
              onSelected: () {
                setState(() {
                  _selectedType = HistoryType.irrigation;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPeriodChip(label: 'Hari Ini', period: HistoryPeriod.today),
            _buildPeriodChip(label: '7 Hari', period: HistoryPeriod.sevenDays),
            _buildPeriodChip(
              label: '30 Hari',
              period: HistoryPeriod.thirtyDays,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: cream,
      onSelected: (_) => onSelected(),
    );
  }

  Widget _buildPeriodChip({
    required String label,
    required HistoryPeriod period,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedPeriod == period,
      selectedColor: cream,
      onSelected: (_) {
        setState(() {
          _selectedPeriod = period;
        });
      },
    );
  }

  // HISTORY LIST

  Widget _buildHistoryList(List<HistoryRecord> records) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Daftar Aktivitas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: forestGreen,
                ),
              ),
            ),
            Text(
              '${records.length} catatan',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (records.isEmpty)
          _buildEmptyState()
        else
          ...records.map(_buildHistoryCard),
      ],
    );
  }

  Widget _buildHistoryCard(HistoryRecord record) {
    final isIrrigation = record.type == HistoryType.irrigation;

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
            child: Icon(
              isIrrigation ? Icons.water_drop_outlined : Icons.sensors,
              color: leafGreen,
            ),
          ),
          title: Text(
            record.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: forestGreen,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              '${record.description}\n${_formatDate(record.recordedAt)}',
              style: TextStyle(
                fontSize: 11,
                height: 1.6,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          trailing: const Icon(Icons.keyboard_arrow_down, color: leafGreen),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Nilai / Volume', style: TextStyle(fontSize: 12)),
                const Spacer(),
                Text(
                  record.value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: forestGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Status', style: TextStyle(fontSize: 12)),
                const Spacer(),
                _buildStatusBadge(record.status),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                record.details,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: leafGreen.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: leafGreen,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // DATE FORMAT

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

    return '$day ${months[date.month - 1]} ${date.year} • $hour:$minute WIB';
  }

  // EMPTY AND ERROR STATES

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
          Icon(Icons.history, size: 42, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text(
            'Belum ada histori',
            style: TextStyle(fontWeight: FontWeight.bold, color: forestGreen),
          ),
          const SizedBox(height: 6),
          Text(
            'Tidak ada catatan pada filter yang dipilih.',
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
          'Gagal memuat histori. Silakan coba kembali.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // FOOTER

  Widget _buildFooter() {
    return Center(
      child: Text(
        'LANDIA FARM APP • Histori IoT',
        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
      ),
    );
  }
}
