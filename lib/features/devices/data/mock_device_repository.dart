import '../domain/device_info.dart';

class MockDeviceRepository {
  DeviceInfo getDeviceInfo() {
    return const DeviceInfo(
      name: 'ESP32 Main Controller',
      description: 'Controller utama sistem IoT Landia Farm',
      deviceId: 'Belum dikonfigurasi',
      firmwareVersion: 'Belum diketahui',
      hardware: 'ESP32',
      lastSeen: 'Belum tersedia',
      status: DeviceConnectionStatus.unknown,
      connections: [
        DeviceConnection(
          name: 'ESP32 Controller',
          description: 'Status operasional controller',
          status: DeviceConnectionStatus.unknown,
        ),
        DeviceConnection(
          name: 'Hotspot HP Petani',
          description: 'Koneksi Wi-Fi dari hotspot petani',
          status: DeviceConnectionStatus.unknown,
        ),
        DeviceConnection(
          name: 'Internet',
          description: 'Akses jaringan menuju server',
          status: DeviceConnectionStatus.unknown,
        ),
        DeviceConnection(
          name: 'MQTT Broker',
          description: 'Komunikasi data perangkat IoT',
          status: DeviceConnectionStatus.unknown,
        ),
        DeviceConnection(
          name: 'Backend Landia Farm',
          description: 'Layanan REST API dan penyimpanan data',
          status: DeviceConnectionStatus.unknown,
        ),
      ],
      components: [
        DeviceComponent(
          name: 'DHT11',
          function: 'Mengukur suhu dan kelembapan udara',
          type: DeviceComponentType.sensor,
          statusDescription: 'Menunggu data sensor',
        ),
        DeviceComponent(
          name: 'Soil Moisture',
          function: 'Mengukur kelembapan tanah',
          type: DeviceComponentType.sensor,
          statusDescription: 'Menunggu data sensor',
        ),
        DeviceComponent(
          name: 'Ultrasonic',
          function: 'Mengukur level air tangki',
          type: DeviceComponentType.sensor,
          statusDescription: 'Menunggu data sensor',
        ),
        DeviceComponent(
          name: 'Rain Sensor',
          function: 'Mendeteksi kondisi hujan',
          type: DeviceComponentType.sensor,
          statusDescription: 'Menunggu data sensor',
        ),
        DeviceComponent(
          name: 'YF-S201',
          function: 'Mengukur debit dan volume air',
          type: DeviceComponentType.sensor,
          statusDescription: 'Menunggu data sensor',
        ),
        DeviceComponent(
          name: 'Relay',
          function: 'Mengendalikan rangkaian pompa',
          type: DeviceComponentType.actuator,
          statusDescription: 'Status belum tersedia',
        ),
        DeviceComponent(
          name: 'Pompa Air',
          function: 'Mendukung sistem penyiraman otomatis',
          type: DeviceComponentType.actuator,
          statusDescription: 'Status belum tersedia',
        ),
      ],
    );
  }
}
