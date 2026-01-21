import 'package:flutter/material.dart';
import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

import 'remedial_form_page.dart';
import 'remedial_edit_page.dart';

import '../models/remedial_report_model.dart';
import '../services/db_helper.dart';

class RemedialListPage extends StatefulWidget {
  const RemedialListPage({super.key});

  @override
  State<RemedialListPage> createState() => _RemedialListPageState();
}

class _RemedialListPageState extends State<RemedialListPage> {
  List<RemedialReport> laporan = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await DBHelper.getAll();
    setState(() => laporan = data);
  }

  // =========================
  // EXPORT EXCEL (RAPI)
  // =========================
  Future<String?> exportExcel({bool share = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final namaRemedial = prefs.getString('nama_remedial') ?? 'Unknown';

    String? path; // ✅ PENTING

    try {
      final workbook = xlsio.Workbook();
      final sheet = workbook.worksheets[0];
      sheet.name = 'Laporan Remedial';

      // ====== JUDUL ======
      sheet.getRangeByName('A1:H1').merge();
      sheet.getRangeByName('A1')
        ..setText('Nama Remedial : $namaRemedial')
        ..cellStyle.bold = true
        ..cellStyle.fontSize = 14
        ..cellStyle.hAlign = xlsio.HAlignType.center;

      sheet.getRangeByName('A2:H2').merge();
      sheet.getRangeByName('A2')
        ..setText(
          'Tanggal Laporan : ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
        )
        ..cellStyle.hAlign = xlsio.HAlignType.center;

      // =========================
      // STYLE
      // =========================
      final headerStyle = workbook.styles.add('headerStyle')
        ..bold = true
        ..hAlign = xlsio.HAlignType.center
        ..vAlign = xlsio.VAlignType.center
        ..backColor = '#E5E7EB'
        ..borders.all.lineStyle = xlsio.LineStyle.thin;

      final cellStyle = workbook.styles.add('cellStyle')
        ..hAlign = xlsio.HAlignType.center
        ..vAlign = xlsio.VAlignType.center
        ..borders.all.lineStyle = xlsio.LineStyle.thin;

      final nominalStyle = workbook.styles.add('nominalStyle')
        ..hAlign = xlsio.HAlignType.right
        ..vAlign = xlsio.VAlignType.center
        ..borders.all.lineStyle = xlsio.LineStyle.thin;

      // =========================
      // HEADER
      // =========================
      final headers = [
        'No',
        'Nama Nasabah',
        'Alamat',
        'Status',
        'Tipe/Kol',
        'Plafon',
        'Pokok',
        'Bunga',
        'Setor',
        'Hasil',
        'Foto',
      ];

      int headerRow = 4;
      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.getRangeByIndex(headerRow, i + 1);
        cell
          ..setText(headers[i])
          ..cellStyle = headerStyle;
      }

      int row = 5;
      int no = 1;

      // =========================
      // DATA
      // =========================
      for (var e in laporan) {
        sheet.getRangeByIndex(row, 1)
          ..setNumber(no.toDouble())
          ..cellStyle = cellStyle;

        sheet.getRangeByIndex(row, 2)
          ..setText(e.namaNasabah)
          ..cellStyle = cellStyle;

        sheet.getRangeByIndex(row, 3)
          ..setText(e.alamat)
          ..cellStyle = cellStyle;

        sheet.getRangeByIndex(row, 4)
          ..setText(e.status)
          ..cellStyle = nominalStyle;

        sheet.getRangeByIndex(row, 5)
          ..setText(e.produk)
          ..cellStyle = cellStyle;

        sheet.getRangeByIndex(row, 6)
          ..setText(e.nominal)
          ..cellStyle = cellStyle;

        sheet.getRangeByIndex(row, 7)
          ..setText(e.pokok)
          ..cellStyle = cellStyle;

        sheet.getRangeByIndex(row, 8)
          ..setText(e.bunga)
          ..cellStyle = cellStyle;

        sheet.getRangeByIndex(row, 9)
          ..setText(e.setor)
          ..cellStyle = cellStyle;

        sheet.getRangeByIndex(row, 10)
          ..setText(e.hasil)
          ..cellStyle = cellStyle;

        // FOTO → KOLOM 8 (FIX)
        if (e.fotoPath != null && File(e.fotoPath!).existsSync()) {
          final resizedBytes = await resizeImageForExcel(e.fotoPath!);

          sheet.getRangeByIndex(row, 11)
            ..columnWidth = 12
            ..rowHeight = 70;

          final picture = sheet.pictures.addStream(row, 11, resizedBytes);
          picture
            ..width = 65
            ..height = 75;
        }

        row++;
        no++;
      }

      // AUTO WIDTH
      for (int i = 1; i <= headers.length; i++) {
        sheet.autoFitColumn(i);
      }

      final dir = await getTemporaryDirectory();
      final tanggal = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final safeName = namaRemedial.replaceAll(' ', '_').replaceAll('/', '-');

      path = '${dir.path}/Laporan Remedial_${safeName}_$tanggal.xlsx';

      final file = File(path);
      file.writeAsBytesSync(workbook.saveAsStream());
      workbook.dispose();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal export: $e')));
      return null;
    }

    // =========================
    // SHARE (OPTIONAL)
    // =========================
    if (share && path != null) {
      await Share.shareXFiles([XFile(path)], text: 'Laporan Remedial');
    }

    return path;
  }

  Future<List<int>> resizeImageForExcel(String path) async {
    final bytes = await File(path).readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) return bytes;

    final resized = img.copyResize(
      original,
      width: 128,
      height: 128,
      interpolation: img.Interpolation.cubic,
    );

    return img.encodeJpg(resized, quality: 90);
  }

  Future<void> deleteData(int id) async {
    await DBHelper.delete(id);
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Laporan'),

        // ⬅️ TOMBOL KEMBALI KE FORM
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const RemedialFormPage()),
            );
          },
        ),

        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'preview') {
                final path = await exportExcel();
                if (path != null) {
                  OpenFilex.open(path);
                }
              } else if (value == 'share') {
                await exportExcel(share: true);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'preview', child: Text('Preview Excel')),
              PopupMenuItem(value: 'share', child: Text('Share Excel')),
            ],
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          // =========================
          // GROUP DATA BY DATE
          // =========================
          final Map<String, List<RemedialReport>> groupedData = {};

          for (var item in laporan) {
            final dateKey = DateFormat(
              'dd/MM/yyyy',
            ).format(item.tanggalLaporan);
            groupedData.putIfAbsent(dateKey, () => []);
            groupedData[dateKey]!.add(item);
          }

          final dateKeys = groupedData.keys.toList();

          return ListView.builder(
            itemCount: dateKeys.length,
            itemBuilder: (context, index) {
              final date = dateKeys[index];
              final items = groupedData[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =========================
                  // DATE SEPARATOR
                  // =========================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.grey.shade200,
                    child: Text(
                      date,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  // =========================
                  // LIST ITEM PER TANGGAL
                  // =========================
                  ...items.map(
                    (data) => Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: ListTile(
                        title: Text(data.namaNasabah),
                        subtitle: Text(data.produk),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        RemedialEditPage(data: data),
                                  ),
                                );

                                if (result == true) {
                                  loadData();
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteData(data.id!),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
