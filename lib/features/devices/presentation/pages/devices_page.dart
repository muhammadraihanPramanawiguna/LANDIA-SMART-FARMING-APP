import 'package:flutter/material.dart';

import '../../data/mock_device_repository.dart';
import '../../domain/device_info.dart';

class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  static const Color _forestGreen = Color(0xFF173F35);
  static const Color _leafGreen = Color(0xFF397A52);
  static const Color _cream = Color(0xFFF4F3E9);
  static const Color _textDark = Color(0xFF26332E);
  static const Color _textMuted = Color(0xFF858A86);
  static const Color _borderColor = Color(0xFFE5E7E2);

  @override
  Widget build(BuildContext context) {
    final device = MockDeviceRepository().getDeviceInfo();

    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 650;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(isMobile),
                      const SizedBox(height: 24),

                      _buildControllerCard(device),

                      const SizedBox(height: 24),

                      _buildSectionTitle(
                        'Konektivitas Perangkat',
                        'Informasi jalur komunikasi ESP32 menuju server.',
                      ),

                      const SizedBox(height: 12),

                      _buildConnectionSection(device.connections, isMobile),

                      const SizedBox(height: 24),

                      _buildSectionTitle(
                        'Komponen IoT',
                        'Sensor dan aktuator yang dikelola oleh satu ESP32.',
                      ),

                      const SizedBox(height: 12),

                      _buildComponentSection(device.components, isMobile),

                      const SizedBox(height: 24),

                      _buildInformationCard(),

                      const SizedBox(height: 20),

                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Perangkat IoT',
              style: TextStyle(
                color: _forestGreen,
                fontSize: isMobile ? 22 : 27,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildDemoBadge(),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          'Pantau controller utama, sensor, dan konektivitas '
          'sistem IoT Landia Farm.',
          style: TextStyle(color: _textMuted, fontSize: isMobile ? 12 : 14),
        ),
      ],
    );
  }

  Widget _buildDemoBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0D8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.science_outlined, color: Color(0xFFAA7527), size: 14),
          SizedBox(width: 5),
          Text(
            'Mode DEMO',
            style: TextStyle(
              color: Color(0xFF94651F),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTROLLER CARD
  // ============================================================

  Widget _buildControllerCard(DeviceInfo device) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _forestGreen,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.memory, color: Colors.white, size: 29),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        color: _forestGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      device.description,
                      style: const TextStyle(color: _textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              _buildStatusBadge(device.status),
            ],
          ),

          const SizedBox(height: 20),

          const Divider(color: _borderColor),

          const SizedBox(height: 15),

          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 450 ? 1 : 2;

              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: columns == 1 ? 5.2 : 4.4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 12,
                children: [
                  _buildInfoItem(
                    Icons.fingerprint,
                    'Device ID',
                    device.deviceId,
                  ),
                  _buildInfoItem(
                    Icons.code,
                    'Firmware Version',
                    device.firmwareVersion,
                  ),
                  _buildInfoItem(
                    Icons.developer_board,
                    'Hardware',
                    device.hardware,
                  ),
                  _buildInfoItem(
                    Icons.access_time,
                    'Terakhir Aktif',
                    device.lastSeen,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: _leafGreen, size: 19),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(color: _textMuted, fontSize: 10),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _textDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _forestGreen,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(color: _textMuted, fontSize: 12)),
      ],
    );
  }

  // ============================================================
  // CONNECTION SECTION
  // ============================================================

  Widget _buildConnectionSection(
    List<DeviceConnection> connections,
    bool isMobile,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 550 ? 1 : 2;

        return GridView.builder(
          itemCount: connections.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 105,
          ),
          itemBuilder: (context, index) {
            return _buildConnectionCard(connections[index]);
          },
        );
      },
    );
  }

  Widget _buildConnectionCard(DeviceConnection connection) {
    final color = _statusColor(connection.status);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              _connectionIcon(connection.name),
              color: color,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  connection.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  connection.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _textMuted, fontSize: 10),
                ),
                const SizedBox(height: 5),
                Text(
                  connection.statusLabel,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _connectionIcon(String name) {
    if (name.contains('ESP32')) {
      return Icons.memory;
    }

    if (name.contains('Hotspot')) {
      return Icons.wifi;
    }

    if (name.contains('Internet')) {
      return Icons.public;
    }

    if (name.contains('MQTT')) {
      return Icons.sync_alt;
    }

    return Icons.cloud_outlined;
  }

  // ============================================================
  // COMPONENT SECTION
  // ============================================================

  Widget _buildComponentSection(
    List<DeviceComponent> components,
    bool isMobile,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 550
            ? 1
            : constraints.maxWidth < 900
            ? 2
            : 3;

        return GridView.builder(
          itemCount: components.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 112,
          ),
          itemBuilder: (context, index) {
            return _buildComponentCard(components[index]);
          },
        );
      },
    );
  }

  Widget _buildComponentCard(DeviceComponent component) {
    final isSensor = component.type == DeviceComponentType.sensor;

    final icon = isSensor
        ? _sensorIcon(component.name)
        : Icons.electrical_services_outlined;

    final typeLabel = isSensor ? 'SENSOR' : 'AKTUATOR';

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1EB),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: _leafGreen, size: 22),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        component.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _forestGreen,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 3),

                Text(
                  typeLabel,
                  style: const TextStyle(
                    color: _leafGreen,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  component.function,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _textMuted, fontSize: 10),
                ),

                const SizedBox(height: 3),

                Text(
                  component.statusDescription,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF9A7A45), fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _sensorIcon(String name) {
    switch (name) {
      case 'DHT11':
        return Icons.thermostat_outlined;
      case 'Soil Moisture':
        return Icons.grass_outlined;
      case 'Ultrasonic':
        return Icons.water_drop_outlined;
      case 'Rain Sensor':
        return Icons.cloudy_snowing;
      case 'YF-S201':
        return Icons.water_outlined;
      default:
        return Icons.sensors;
    }
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _buildStatusBadge(DeviceConnectionStatus status) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: color, size: 8),
          const SizedBox(width: 6),
          Text(
            _statusLabel(status),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(DeviceConnectionStatus status) {
    switch (status) {
      case DeviceConnectionStatus.connected:
        return const Color(0xFF2E8050);
      case DeviceConnectionStatus.disconnected:
        return const Color(0xFFC34B43);
      case DeviceConnectionStatus.unknown:
        return const Color(0xFFAA7527);
    }
  }

  String _statusLabel(DeviceConnectionStatus status) {
    switch (status) {
      case DeviceConnectionStatus.connected:
        return 'Online';
      case DeviceConnectionStatus.disconnected:
        return 'Offline';
      case DeviceConnectionStatus.unknown:
        return 'Belum diverifikasi';
    }
  }

  // ============================================================
  // INFORMATION CARD
  // ============================================================

  Widget _buildInformationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0E8),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFD5E1D5)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: _leafGreen, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi Sistem Perangkat',
                  style: TextStyle(
                    color: _forestGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Seluruh sensor dan aktuator dikelola oleh '
                  'satu ESP32 Main Controller. '
                  'Status koneksi dan pembacaan perangkat '
                  'akan tersedia setelah integrasi backend.',
                  style: TextStyle(color: _textDark, fontSize: 11, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter() {
    return Center(
      child: Text(
        'LANDIA FARM APP • IoT Device Management',
        style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
      ),
    );
  }
}
