enum DeviceConnectionStatus { connected, disconnected, unknown }

enum DeviceComponentType { sensor, actuator }

class DeviceConnection {
  final String name;
  final String description;
  final DeviceConnectionStatus status;

  const DeviceConnection({
    required this.name,
    required this.description,
    required this.status,
  });

  String get statusLabel {
    switch (status) {
      case DeviceConnectionStatus.connected:
        return 'Terhubung';
      case DeviceConnectionStatus.disconnected:
        return 'Terputus';
      case DeviceConnectionStatus.unknown:
        return 'Belum diverifikasi';
    }
  }
}

class DeviceComponent {
  final String name;
  final String function;
  final DeviceComponentType type;
  final String statusDescription;

  const DeviceComponent({
    required this.name,
    required this.function,
    required this.type,
    required this.statusDescription,
  });
}

class DeviceInfo {
  final String name;
  final String description;
  final String deviceId;
  final String firmwareVersion;
  final String hardware;
  final String lastSeen;
  final DeviceConnectionStatus status;
  final List<DeviceConnection> connections;
  final List<DeviceComponent> components;

  const DeviceInfo({
    required this.name,
    required this.description,
    required this.deviceId,
    required this.firmwareVersion,
    required this.hardware,
    required this.lastSeen,
    required this.status,
    required this.connections,
    required this.components,
  });

  String get statusLabel {
    switch (status) {
      case DeviceConnectionStatus.connected:
        return 'Online';
      case DeviceConnectionStatus.disconnected:
        return 'Offline';
      case DeviceConnectionStatus.unknown:
        return 'Belum diverifikasi';
    }
  }
}
