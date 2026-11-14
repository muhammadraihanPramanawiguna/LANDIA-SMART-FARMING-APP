import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:landia_app/app/app.dart';

void main() {
  group('LANDIA FARM APP Widget Tests', () {
    Future<void> setScreenSize(
      WidgetTester tester, {
      required Size size,
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
    }

    Future<void> pumpLandiaApp(WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: LandiaFarmApp()));

      await tester.pumpAndSettle();
    }

    testWidgets(
      'Dashboard menampilkan ringkasan sensor dan operasional pada desktop',
      (tester) async {
        await setScreenSize(tester, size: const Size(1440, 1000));

        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await pumpLandiaApp(tester);

        // Header aplikasi.
        expect(find.text('LANDIA FARM APP'), findsOneWidget);
        expect(find.text('Mode Demo'), findsOneWidget);

        // Header dashboard.
        expect(find.text('Dashboard'), findsNWidgets(2));
        expect(
          find.text('Pantau kondisi operasional Landia Farm.'),
          findsOneWidget,
        );
        expect(find.text('Data Simulasi'), findsOneWidget);

        // Peringatan data demo.
        expect(find.textContaining('Mode Demo aktif.'), findsOneWidget);

        // Ringkasan sensor.
        expect(find.text('Ringkasan pembacaan sensor'), findsOneWidget);
        expect(find.text('Suhu Udara'), findsOneWidget);
        expect(find.text('Kelembapan Udara'), findsOneWidget);
        expect(find.text('Kelembapan Tanah'), findsOneWidget);
        expect(find.text('Level Air Tangki'), findsOneWidget);
        expect(find.text('Sensor Hujan'), findsOneWidget);
        expect(find.text('Debit Air'), findsOneWidget);

        // Ringkasan air dan biaya.
        expect(find.text('Penggunaan Air'), findsOneWidget);
        expect(find.text('Penggunaan Air Hari Ini'), findsOneWidget);
        expect(find.text('Estimasi Biaya Bulan Ini'), findsOneWidget);
        expect(find.text('Rp15.000'), findsOneWidget);

        // Aktivitas penyiraman.
        expect(find.text('Aktivitas Penyiraman'), findsOneWidget);
        expect(find.text('Penyiraman Area Tanaman'), findsOneWidget);
        expect(find.text('10 menit'), findsOneWidget);
        expect(find.text('100 L'), findsOneWidget);

        // Status sistem.
        expect(find.text('Status Sistem'), findsOneWidget);
        expect(find.text('ESP32'), findsOneWidget);
        expect(find.text('Server'), findsOneWidget);
        expect(find.text('Sensor IoT'), findsOneWidget);

        // Dashboard tidak lagi menampilkan grafik tren.
        expect(find.text('Tren Kondisi Lingkungan'), findsNothing);
        expect(find.text('Tren Penggunaan Air'), findsNothing);

        // Tidak boleh ada error render.
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Dashboard desktop menampilkan sidebar dan navigasi berfungsi',
      (tester) async {
        await setScreenSize(tester, size: const Size(1440, 1000));

        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await pumpLandiaApp(tester);

        // Sidebar.
        expect(find.text('Dashboard'), findsNWidgets(2));
        expect(find.text('Monitoring'), findsOneWidget);
        expect(find.text('Penyiraman'), findsOneWidget);
        expect(find.text('Biaya Air'), findsOneWidget);
        expect(find.text('Histori'), findsOneWidget);
        expect(find.text('Laporan'), findsOneWidget);
        expect(find.text('Perangkat'), findsOneWidget);
        expect(find.text('Pengaturan'), findsOneWidget);

        // Navigasi ke Monitoring.
        await tester.tap(find.text('Monitoring'));
        await tester.pumpAndSettle();

        expect(find.text('Monitoring Sensor'), findsOneWidget);
        expect(
  find.text('Pemantauan kondisi sensor Landia Farm.'),
  findsOneWidget,
);

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('Navigasi mobile tampil tanpa horizontal overflow', (
      tester,
    ) async {
      await setScreenSize(tester, size: const Size(360, 800));

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpLandiaApp(tester);

      // AppBar mobile.
      expect(find.text('LANDIA FARM'), findsOneWidget);

      // Bottom navigation.
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Sensor'), findsOneWidget);
      expect(find.text('Air'), findsOneWidget);
      expect(find.text('Histori'), findsOneWidget);
      expect(find.text('Lainnya'), findsOneWidget);

      // Konten Dashboard.
      expect(find.text('Kondisi Lingkungan'), findsOneWidget);
      expect(find.text('Penggunaan Air'), findsOneWidget);
      expect(find.text('Aktivitas Penyiraman'), findsOneWidget);
      expect(find.text('Status Sistem'), findsOneWidget);

      // Pastikan tidak ada error render atau overflow.
      expect(tester.takeException(), isNull);
    });

    testWidgets('Menu Lainnya dapat dibuka dan menampilkan menu tambahan', (
      tester,
    ) async {
      await setScreenSize(tester, size: const Size(360, 800));

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpLandiaApp(tester);

      await tester.tap(find.text('Lainnya'));
      await tester.pumpAndSettle();

      expect(find.text('Menu Lainnya'), findsOneWidget);
      expect(find.text('Biaya Air'), findsOneWidget);
      expect(find.text('Laporan'), findsOneWidget);
      expect(find.text('Perangkat'), findsOneWidget);
      expect(find.text('Pengaturan'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('Menu tambahan dapat membuka halaman Biaya Air', (
      tester,
    ) async {
      await setScreenSize(tester, size: const Size(360, 800));

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpLandiaApp(tester);

      await tester.tap(find.text('Lainnya'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Biaya Air'));
      await tester.pumpAndSettle();

      expect(find.text('Biaya Air'), findsOneWidget);
      expect(
  find.text(
    'Pantau penggunaan air dan estimasi biaya Landia Farm.',
  ),
  findsOneWidget,
);
      expect(tester.takeException(), isNull);
    });
  });
}
