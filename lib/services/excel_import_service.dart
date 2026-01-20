import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

import '../models/remedial_report_model.dart';
import 'db_helper.dart';

class ExcelImportService {
  static Future<int> importRemedialExcel({required String namaRemedial}) async {
    int totalInserted = 0;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null) return 0;

    final file = File(result.files.single.path!);
    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    final sheet = excel.tables.values.first;
    if (sheet == null) return 0;

    for (int i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      if (row.isEmpty) continue;

      final data = RemedialReport(
        namaRemedial: namaRemedial,
        namaNasabah: row[0]?.value.toString() ?? '',
        alamat: row[1]?.value.toString() ?? '',
        nominal: row[2]?.value.toString() ?? '',
        status: row[3]?.value.toString() ?? '',
        produk: row[4]?.value.toString() ?? '',
        hasil: row[5]?.value.toString() ?? '',
      );

      await DBHelper.insert(data);
      totalInserted++;
    }

    return totalInserted;
  }
}
