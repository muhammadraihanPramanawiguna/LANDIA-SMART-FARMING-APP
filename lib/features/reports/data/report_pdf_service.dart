import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../irrigation/domain/irrigation_activity.dart';

class ReportPdfService {
  // ============================================================
  // LANDIA FARM COLOR PALETTE
  // ============================================================

  static const _forestGreen = PdfColor.fromInt(0xFF173F35);
  static const _leafGreen = PdfColor.fromInt(0xFF397A52);
  static const _cream = PdfColor.fromInt(0xFFF4F3E9);

  // ============================================================
  // GENERATE PDF REPORT
  // ============================================================

  Future<Uint8List> generate({
    required List<IrrigationActivity> activities,
    required String period,
    required double tariffPerM3,
    required double totalVolume,
    required double totalCost,
  }) async {
    final pdf = pw.Document(
      title: 'Laporan Operasional Landia Farm',
      author: 'LANDIA FARM APP',
      subject: 'Laporan monitoring dan operasional pertanian',
    );

    // Filter aktivitas yang sudah selesai.
    final completedActivities = activities
        .where((item) => item.status == IrrigationStatus.completed)
        .toList();

    // Total durasi hanya dihitung dari aktivitas selesai.
    final totalDuration = completedActivities.fold<int>(
      0,
      (sum, item) => sum + item.durationMinutes,
    );

    final now = DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(32, 36, 32, 36),

        // Header halaman lanjutan.
        header: (context) {
          if (context.pageNumber == 1) {
            return pw.SizedBox();
          }

          return pw.Container(
            alignment: pw.Alignment.centerLeft,
            margin: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Text(
              'LANDIA FARM | Laporan Operasional',
              style: pw.TextStyle(
                color: _forestGreen,
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          );
        },

        // Footer dan nomor halaman.
        footer: (context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 12),
            child: pw.Text(
              'LANDIA FARM APP | '
              '${context.pageNumber}/${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          );
        },

        build: (context) => [
          // ====================================================
          // HEADER
          // ====================================================
          _header(now),

          pw.SizedBox(height: 20),

          // ====================================================
          // 1. INFORMASI LAPORAN
          // ====================================================
          _heading('1. Informasi Laporan'),

          _simpleTable([
            ['Nama Sistem', 'LANDIA FARM APP'],
            ['Jenis Laporan', 'Laporan Operasional Pertanian'],
            ['Periode', period],
            ['Tanggal Dibuat', _dateTime(now)],
            ['Status Data', 'DEMO / SIMULASI'],
          ]),

          pw.SizedBox(height: 18),

          // ====================================================
          // 2. RINGKASAN OPERASIONAL
          // ====================================================
          _heading('2. Ringkasan Operasional'),

          _simpleTable([
            ['Total Aktivitas', '${activities.length} kali'],
            ['Aktivitas Selesai', '${completedActivities.length} kali'],
            ['Total Durasi', '$totalDuration menit'],
            ['Total Volume Air', '${totalVolume.toStringAsFixed(1)} Liter'],
            [
              'Konversi Volume',
              '${(totalVolume / 1000).toStringAsFixed(3)} m³',
            ],
            ['Tarif Simulasi', '${_currency(tariffPerM3)} / m³'],
            ['Estimasi Biaya', _currency(totalCost)],
          ]),

          pw.SizedBox(height: 18),

          // ====================================================
          // 3. SNAPSHOT SENSOR DEMO
          // ====================================================
          _heading('3. Snapshot Sensor DEMO'),

          _sensorTable(),

          pw.SizedBox(height: 18),

          // ====================================================
          // 4. RINCIAN AKTIVITAS PENYIRAMAN
          // ====================================================
          _heading('4. Rincian Aktivitas Penyiraman'),

          if (activities.isEmpty)
            _emptyActivity()
          else
            _activityTable(activities, tariffPerM3),

          pw.SizedBox(height: 18),

          // ====================================================
          // 5. METODE PERHITUNGAN BIAYA
          // ====================================================
          _heading('5. Metode Perhitungan Biaya'),

          _calculationSection(
            tariffPerM3: tariffPerM3,
            totalVolume: totalVolume,
            totalCost: totalCost,
          ),

          pw.SizedBox(height: 16),

          // ====================================================
          // 6. CATATAN DAN KETERANGAN
          // ====================================================
          _heading('6. Catatan dan Keterangan'),

          _disclaimer(tariffPerM3),

          pw.SizedBox(height: 18),

          // ====================================================
          // CLOSING
          // ====================================================
          _closing(),
        ],
      ),
    );

    return pdf.save();
  }

  // ============================================================
  // HEADER
  // ============================================================

  pw.Widget _header(DateTime date) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: _forestGreen,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'LANDIA FARM',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 23,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 5),

          pw.Text(
            'LAPORAN OPERASIONAL PERTANIAN',
            style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
          ),

          pw.SizedBox(height: 12),

          pw.Container(height: 1, color: PdfColors.white),

          pw.SizedBox(height: 10),

          pw.Text(
            'Dokumen dibuat: ${_dateTime(date)}',
            style: const pw.TextStyle(color: PdfColors.white, fontSize: 9),
          ),

          pw.SizedBox(height: 5),

          pw.Text(
            'Dokumen ini merupakan laporan DEMO / SIMULASI.',
            style: const pw.TextStyle(color: PdfColors.white, fontSize: 8),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADING
  // ============================================================

  pw.Widget _heading(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          color: _forestGreen,
          fontSize: 13,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // GENERAL TABLE
  // ============================================================

  pw.Widget _simpleTable(List<List<String>> rows) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.5),
        1: const pw.FlexColumnWidth(2),
      },
      children: rows.map((row) {
        return pw.TableRow(
          children: [_cell(row[0]), _cell(row[1], bold: true)],
        );
      }).toList(),
    );
  }

  pw.Widget _cell(String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        value,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  // ============================================================
  // SENSOR SNAPSHOT
  // ============================================================

  pw.Widget _sensorTable() {
    const rows = [
      ['Suhu Udara', '28.5 °C', 'Normal'],
      ['Kelembapan Udara', '75%', 'Normal'],
      ['Kelembapan Tanah', '55%', 'Normal'],
      ['Level Air Tangki', '80%', 'Aman'],
      ['Sensor Hujan', '0%', 'Tidak terdeteksi'],
      ['Debit Air', '0.0 L/min', 'Tidak mengalir'],
    ];

    return pw.TableHelper.fromTextArray(
      headers: const ['Parameter', 'Nilai', 'Status'],
      data: rows,
      headerDecoration: const pw.BoxDecoration(color: _leafGreen),
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontSize: 9,
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellPadding: const pw.EdgeInsets.all(7),
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
    );
  }

  // ============================================================
  // EMPTY ACTIVITY
  // ============================================================

  pw.Widget _emptyActivity() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Text(
        'Tidak ada aktivitas penyiraman pada periode ini.',
        style: const pw.TextStyle(fontSize: 9),
      ),
    );
  }

  // ============================================================
  // IRRIGATION ACTIVITY TABLE
  // ============================================================

  pw.Widget _activityTable(
    List<IrrigationActivity> activities,
    double tariffPerM3,
  ) {
    final rows = activities.map((item) {
      final status = item.status == IrrigationStatus.completed
          ? 'Selesai'
          : 'Belum selesai';

      return [
        item.area,
        _dateTime(item.startedAt),
        '${item.volumeLiters.toStringAsFixed(1)} L',
        '${item.durationMinutes} menit',
        _currency(item.calculateCost(tariffPerM3)),
        status,
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: const ['Area', 'Waktu', 'Volume', 'Durasi', 'Biaya', 'Status'],
      data: rows,
      headerDecoration: const pw.BoxDecoration(color: _leafGreen),
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontSize: 7,
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: const pw.TextStyle(fontSize: 7),
      cellPadding: const pw.EdgeInsets.all(5),
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
    );
  }

  // ============================================================
  // COST CALCULATION
  // ============================================================

  pw.Widget _calculationSection({
    required double tariffPerM3,
    required double totalVolume,
    required double totalCost,
  }) {
    final volumeM3 = totalVolume / 1000;

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Rumus Perhitungan',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),

          pw.SizedBox(height: 8),

          pw.Text(
            'Biaya = (Volume Liter / 1.000) x Tarif per m³',
            style: const pw.TextStyle(fontSize: 9),
          ),

          pw.SizedBox(height: 10),

          _calculationRow(
            'Volume air',
            '${totalVolume.toStringAsFixed(1)} Liter',
          ),

          _calculationRow(
            'Konversi volume',
            '${volumeM3.toStringAsFixed(3)} m³',
          ),

          _calculationRow('Tarif simulasi', '${_currency(tariffPerM3)} / m³'),

          pw.Divider(color: PdfColors.grey400),

          _calculationRow('Estimasi biaya', _currency(totalCost), bold: true),

          pw.SizedBox(height: 8),

          pw.Text(
            'Perhitungan biaya menggunakan tarif simulasi aplikasi, '
            'bukan tarif resmi atau tagihan aktual.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  pw.Widget _calculationRow(String label, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),

          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DISCLAIMER
  // ============================================================

  pw.Widget _disclaimer(double tariffPerM3) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _cream,
        border: pw.Border.all(color: PdfColors.grey400, width: 0.7),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PERHATIAN: STATUS DATA DEMO',
            style: pw.TextStyle(
              color: _forestGreen,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 7),

          pw.Text(
            '1. Laporan ini masih menggunakan data DEMO / SIMULASI.',
            style: const pw.TextStyle(fontSize: 8),
          ),

          pw.SizedBox(height: 4),

          pw.Text(
            '2. Snapshot sensor bukan histori pengukuran aktual.',
            style: const pw.TextStyle(fontSize: 8),
          ),

          pw.SizedBox(height: 4),

          pw.Text(
            '3. Volume penyiraman belum berasal dari pembacaan '
            'aktual sensor flow YF-S201 pada ESP32.',
            style: const pw.TextStyle(fontSize: 8),
          ),

          pw.SizedBox(height: 4),

          pw.Text(
            '4. Estimasi biaya menggunakan tarif simulasi '
            '${_currency(tariffPerM3)}/m³ dan bukan tagihan resmi.',
            style: const pw.TextStyle(fontSize: 8),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CLOSING
  // ============================================================

  pw.Widget _closing() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'LANDIA FARM APP',
            style: pw.TextStyle(
              color: _forestGreen,
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 4),

          pw.Text(
            'Smart Farming Monitoring System',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),

          pw.SizedBox(height: 6),

          pw.Text(
            'Dokumen dibuat secara otomatis oleh sistem.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FORMAT CURRENCY
  // ============================================================

  static String _currency(double value) {
    final digits = value.round().toString();
    final result = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      result.write(digits[i]);

      final remaining = digits.length - i - 1;

      if (remaining > 0 && remaining % 3 == 0) {
        result.write('.');
      }
    }

    return 'Rp${result.toString()}';
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  static String _dateTime(DateTime date) {
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

    return '$day ${months[date.month - 1]} ${date.year} '
        '$hour:$minute';
  }
}
