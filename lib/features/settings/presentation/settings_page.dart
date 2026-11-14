import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const Color _forestGreen = Color(0xFF173F35);
  static const Color _leafGreen = Color(0xFF397A52);
  static const Color _cream = Color(0xFFF4F3E9);
  static const Color _textDark = Color(0xFF26332F);
  static const Color _textMuted = Color(0xFF858B85);
  static const Color _borderColor = Color(0xFFE5E7DF);
  static const Color _gold = Color(0xFFD8A85D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildFarmProfile(),
                  const SizedBox(height: 24),
                  _buildSectionTitle(
                    'Preferensi Aplikasi',
                    'Informasi pengaturan tampilan dan penggunaan aplikasi.',
                  ),
                  const SizedBox(height: 12),
                  _buildPreferences(),
                  const SizedBox(height: 24),
                  _buildSectionTitle(
                    'Konfigurasi Biaya Air',
                    'Parameter perhitungan biaya penggunaan air.',
                  ),
                  const SizedBox(height: 12),
                  _buildWaterCost(),
                  const SizedBox(height: 24),
                  _buildSectionTitle(
                    'Informasi Sistem',
                    'Status konfigurasi aplikasi dan integrasi perangkat.',
                  ),
                  const SizedBox(height: 12),
                  _buildSystemInfo(),
                  const SizedBox(height: 24),
                  _buildAbout(),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'LANDIA FARM APP • Smart Farming',
                      style: TextStyle(
                        fontSize: 11,
                        color: _textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Pengaturan',
              style: TextStyle(
                color: _forestGreen,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0D9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.science_outlined, size: 15, color: Colors.brown),
                  SizedBox(width: 6),
                  Text(
                    'Mode DEMO',
                    style: TextStyle(
                      color: Colors.brown,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Informasi farm dan konfigurasi aplikasi Landia Farm.',
          style: TextStyle(color: _textMuted, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildFarmProfile() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _IconContainer(
                icon: Icons.agriculture_outlined,
                backgroundColor: Color(0xFFE8F0E9),
                iconColor: _leafGreen,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profil Landia Farm',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: _forestGreen,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Informasi lokasi dan identitas area pertanian.',
                      style: TextStyle(fontSize: 12, color: _textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: _borderColor),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 650 ? 2 : 1;
              final itemWidth =
                  (constraints.maxWidth - (columns - 1) * 20) / columns;

              return Wrap(
                spacing: 20,
                runSpacing: 22,
                children: [
                  SizedBox(
                    width: itemWidth,
                    child: _InfoItem(
                      icon: Icons.business_outlined,
                      label: 'Nama Farm',
                      value: 'Landia Farm',
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _InfoItem(
                      icon: Icons.location_on_outlined,
                      label: 'Lokasi',
                      value: 'Nagari Koto Tinggi, Kecamatan Baso',
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _InfoItem(
                      icon: Icons.map_outlined,
                      label: 'Kabupaten / Provinsi',
                      value: 'Agam, Sumatera Barat',
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _InfoItem(
                      icon: Icons.terrain_outlined,
                      label: 'Elevasi',
                      value: '± 1.056 mdpl',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferences() {
    return _buildCard(
      child: Column(
        children: [
          _buildSettingRow(
            icon: Icons.language,
            title: 'Bahasa Aplikasi',
            subtitle: 'Bahasa yang digunakan pada aplikasi.',
            value: 'Indonesia',
          ),
          const Divider(color: _borderColor, height: 24),
          _buildSettingRow(
            icon: Icons.light_mode_outlined,
            title: 'Tema Tampilan',
            subtitle: 'Skema warna antarmuka aplikasi.',
            value: 'Terang',
          ),
          const Divider(color: _borderColor, height: 24),
          _buildSettingRow(
            icon: Icons.water_drop_outlined,
            title: 'Satuan Volume Air',
            subtitle: 'Satuan yang digunakan untuk data penggunaan air.',
            value: 'Liter',
          ),
        ],
      ),
    );
  }

  Widget _buildWaterCost() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingRow(
            icon: Icons.payments_outlined,
            title: 'Tarif Simulasi Air',
            subtitle: 'Parameter untuk perhitungan estimasi biaya air.',
            value: 'Rp1.000 / m³',
            valueColor: _leafGreen,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5E6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _gold.withValues(alpha: 0.35)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.brown, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Nilai tarif ini hanya digunakan untuk simulasi aplikasi. '
                    'Bukan tarif resmi penyedia air atau listrik. '
                    'Perubahan tarif aktual perlu dikonfigurasi melalui '
                    'integrasi sistem.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemInfo() {
    return _buildCard(
      child: Column(
        children: [
          _buildStatusRow(
            icon: Icons.science_outlined,
            title: 'Mode Aplikasi',
            subtitle: 'Sumber data yang digunakan saat ini.',
            value: 'DEMO',
          ),
          const Divider(color: _borderColor, height: 24),
          _buildStatusRow(
            icon: Icons.cloud_outlined,
            title: 'Backend Landia Farm',
            subtitle: 'Koneksi REST API dan layanan server.',
            value: 'Belum diverifikasi',
          ),
          const Divider(color: _borderColor, height: 24),
          _buildStatusRow(
            icon: Icons.memory_outlined,
            title: 'ESP32 Main Controller',
            subtitle: 'Integrasi data perangkat IoT.',
            value: 'Belum diverifikasi',
          ),
          const Divider(color: _borderColor, height: 24),
          _buildStatusRow(
            icon: Icons.storage_outlined,
            title: 'Penyimpanan Data',
            subtitle: 'Integrasi database sistem.',
            value: 'Belum diverifikasi',
          ),
        ],
      ),
    );
  }


Widget _buildAbout() {
  return _buildCard(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 450;

        final icon = const _IconContainer(
          icon: Icons.eco_outlined,
          backgroundColor: Color(0xFFE8F0E9),
          iconColor: _leafGreen,
        );

        const description =
            'Aplikasi monitoring dan pengelolaan sistem pertanian '
            'berbasis Internet of Things (IoT) untuk membantu '
            'pemantauan sensor, sistem penyiraman, penggunaan air, '
            'dan laporan operasional Landia Farm.';

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tentang Landia Farm App',
              style: TextStyle(
                color: _forestGreen,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              description,
              softWrap: true,
              style: TextStyle(
                color: _textMuted,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
        );

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              icon,
              const SizedBox(height: 14),
              content,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            icon,
            const SizedBox(width: 14),
            Expanded(child: content),
          ],
        );
      },
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
            color: _forestGreen,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(color: _textMuted, fontSize: 13)),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
      ),
      child: child,
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    Color valueColor = _textDark,
  }) {
    return Row(
      children: [
        _IconContainer(
          icon: icon,
          backgroundColor: const Color(0xFFF1F3EC),
          iconColor: _leafGreen,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _textDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: _textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: valueColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    return _buildSettingRow(
      icon: icon,
      title: title,
      subtitle: subtitle,
      value: value,
      valueColor: Colors.brown,
    );
  }
}

class _IconContainer extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const _IconContainer({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: iconColor, size: 23),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF397A52)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF858B85)),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF26332F),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
