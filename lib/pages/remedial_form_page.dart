import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/remedial_report_model.dart';
import '../services/db_helper.dart';
import 'remedial_list_page.dart';

class RemedialFormPage extends StatefulWidget {
  final RemedialReport? editData;
  const RemedialFormPage({super.key, this.editData});

  @override
  State<RemedialFormPage> createState() => _RemedialFormPageState();
}

class _RemedialFormPageState extends State<RemedialFormPage> {
  final namaController = TextEditingController();
  final usahaController = TextEditingController();
  final alamatController = TextEditingController();
  final nominalController = TextEditingController();
  final hasilController = TextEditingController();

  String statusValue = 'New';
  final produkController = TextEditingController();
  DateTime? rencanaKunjungan;

  File? foto;
  final picker = ImagePicker();

  // =====================
  // SIMPAN FOTO PERMANEN
  // =====================
  Future<String?> simpanFotoPermanen(File? foto) async {
    if (foto == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        'foto_${DateTime.now().millisecondsSinceEpoch}${p.extension(foto.path)}';
    final newPath = p.join(dir.path, fileName);

    final savedImage = await foto.copy(newPath);
    return savedImage.path;
  }

  Future<void> pilihTanggalKunjungan() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => rencanaKunjungan = picked);
    }
  }

  Future<void> ambilFoto() async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => foto = File(image.path));
    }
  }

  // =====================
  // SUBMIT DATA
  // =====================
  Future<void> submitReport() async {
    debugPrint('➡️ SUBMIT START');

    try {
      if (namaController.text.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama Nasabah wajib diisi')),
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;

      final namaRemedial = prefs.getString('nama_remedial') ?? 'Unknown';

      String? fotoPath;
      if (foto != null) {
        fotoPath = await simpanFotoPermanen(foto);
        if (!mounted) return;
      }

      final report = RemedialReport(
        id: widget.editData?.id,
        namaRemedial: namaRemedial,
        namaNasabah: namaController.text,
        // usaha: usahaController.text,
        alamat: alamatController.text,
        nominal: nominalController.text,
        status: statusValue,
        produk: produkController.text,
        hasil: hasilController.text,
        tanggalLaporan: widget.editData?.tanggalLaporan ?? DateTime.now(),
        rencanaKunjungan: rencanaKunjungan,
        fotoPath: fotoPath,
      );

      if (widget.editData == null) {
        await DBHelper.insert(report);
      } else {
        await DBHelper.update(report);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data berhasil disimpan')));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RemedialListPage()),
      );

      debugPrint('✅ SUBMIT DONE');
    } catch (e, s) {
      debugPrint('❌ ERROR SUBMIT: $e');
      debugPrint('$s');

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ERROR: $e')));
    }
  }

  void resetForm() {
    namaController.clear();
    // usahaController.clear();
    alamatController.clear();
    nominalController.clear();
    hasilController.clear();
    produkController.clear();

    setState(() {
      statusValue = 'New';
      rencanaKunjungan = null;
      foto = null;
    });
  }

  @override
  void initState() {
    super.initState();

    if (widget.editData != null) {
      final data = widget.editData!;
      namaController.text = data.namaNasabah;
      // usahaController.text = data.usaha;
      alamatController.text = data.alamat;
      nominalController.text = data.nominal;
      hasilController.text = data.hasil;
      statusValue = data.status;
      produkController.text = data.produk;
      rencanaKunjungan = data.rencanaKunjungan;

      if (data.fotoPath != null) {
        foto = File(data.fotoPath!);
      }
    }
  }

  void bukaList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RemedialListPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editData != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Remedial Report' : 'Tambah Remedial Report'),
        actions: [
          IconButton(icon: const Icon(Icons.list), onPressed: bukaList),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama Nasabah'),
            ),
            const SizedBox(height: 10),
            // TextField(
            //   controller: usahaController,
            //   decoration: const InputDecoration(labelText: 'Usaha'),
            // ),
            // const SizedBox(height: 10),
            TextField(
              controller: alamatController,
              decoration: const InputDecoration(labelText: 'Alamat'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField(
              value: statusValue,
              items: const [
                DropdownMenuItem(value: 'New', child: Text('New')),
                DropdownMenuItem(value: 'F.Up', child: Text('F.Up')),
                DropdownMenuItem(value: 'Top Up', child: Text('Top Up')),
              ],
              onChanged: (v) => setState(() => statusValue = v!),
              decoration: const InputDecoration(labelText: 'Status'),
            ),

            const SizedBox(height: 10),

            // DropdownButtonFormField(
            //   value: produkValue,
            //   items: const [
            //     DropdownMenuItem(value: 'Tabungan', child: Text('Tabungan')),
            //     DropdownMenuItem(value: 'Deposito', child: Text('Deposito')),
            //     DropdownMenuItem(value: 'Kredit', child: Text('Kredit')),
            //   ],
            //   onChanged: (v) => setState(() => produkValue = v!),
            //   decoration: const InputDecoration(labelText: 'Produk'),
            // ),
            const SizedBox(height: 10),
            TextField(
              controller: produkController,
              decoration: const InputDecoration(labelText: 'Produk'),
            ),

            const SizedBox(height: 10),
            TextField(
              controller: hasilController,
              decoration: const InputDecoration(labelText: 'Hasil / Kendala'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nominalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Nominal'),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    rencanaKunjungan == null
                        ? 'Rencana kunjungan'
                        : DateFormat('dd/MM/yyyy').format(rencanaKunjungan!),
                  ),
                ),
                TextButton(
                  onPressed: pilihTanggalKunjungan,
                  child: const Text('Pilih'),
                ),
              ],
            ),

            Row(
              children: [
                ElevatedButton(
                  onPressed: ambilFoto,
                  child: const Text('Upload Foto'),
                ),
                const SizedBox(width: 10),
                Text(foto == null ? 'Belum ada foto' : 'Foto siap'),
              ],
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitReport,
                child: Text(isEdit ? 'Update' : 'Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
