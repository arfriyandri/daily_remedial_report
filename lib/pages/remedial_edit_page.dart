import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../models/remedial_report_model.dart';
import '../models/master_nasabah_model.dart';
import '../services/db_helper.dart';
import 'remedial_list_page.dart';

class RemedialEditPage extends StatefulWidget {
  final RemedialReport data;

  const RemedialEditPage({super.key, required this.data});

  @override
  State<RemedialEditPage> createState() => _RemedialEditPageState();
}

class _RemedialEditPageState extends State<RemedialEditPage> {
  final namaController = TextEditingController();
  final alamatController = TextEditingController();
  final nominalController = TextEditingController();
  final hasilController = TextEditingController();
  final produkController = TextEditingController();

  String statusValue = 'New';
  DateTime? rencanaKunjungan;

  File? foto;
  final picker = ImagePicker();

  // =====================
  // SIMPAN FOTO PERMANEN
  // =====================
  Future<String?> simpanFotoPermanen(File foto) async {
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
      initialDate: rencanaKunjungan ?? DateTime.now(),
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
  // UPDATE DATA
  // =====================
  Future<void> updateReport() async {
    if (namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama Nasabah wajib diisi')));
      return;
    }

    String? fotoPath = widget.data.fotoPath;
    if (foto != null) {
      fotoPath = await simpanFotoPermanen(foto!);
    }

    final updated = RemedialReport(
      id: widget.data.id,
      namaRemedial: widget.data.namaRemedial,
      namaNasabah: namaController.text,
      alamat: alamatController.text,
      nominal: nominalController.text,
      status: statusValue,
      produk: produkController.text,
      hasil: hasilController.text,
      tanggalLaporan: widget.data.tanggalLaporan,
      rencanaKunjungan: rencanaKunjungan,
      fotoPath: fotoPath,
    );

    await DBHelper.update(updated);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Data berhasil diperbarui')));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RemedialListPage()),
    );
  }

  @override
  void initState() {
    super.initState();

    final d = widget.data;
    namaController.text = d.namaNasabah;
    alamatController.text = d.alamat;
    nominalController.text = d.nominal;
    hasilController.text = d.hasil;
    produkController.text = d.produk;
    statusValue = d.status;
    rencanaKunjungan = d.rencanaKunjungan;

    if (d.fotoPath != null) {
      foto = File(d.fotoPath!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Remedial Report')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // =========================
            // 🔍 AUTOCOMPLETE NASABAH
            // =========================
            Autocomplete<MasterNasabah>(
              displayStringForOption: (e) => e.nama,
              optionsBuilder: (value) async {
                if (value.text.length < 2) {
                  return const Iterable<MasterNasabah>.empty();
                }
                return await DBHelper.searchNasabah(value.text);
              },
              onSelected: (selected) {
                namaController.text = selected.nama;
                alamatController.text = selected.alamat;
                nominalController.text = selected.nominal;
                produkController.text = selected.produk;
              },
              fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                controller.text = namaController.text;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Nama Nasabah',
                    border: OutlineInputBorder(),
                    hintText: 'Cari atau ubah manual',
                  ),
                  onChanged: (v) => namaController.text = v,
                );
              },
            ),

            const SizedBox(height: 12),
            TextField(
              controller: alamatController,
              decoration: const InputDecoration(labelText: 'Alamat'),
            ),

            const SizedBox(height: 12),
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

            const SizedBox(height: 12),
            TextField(
              controller: produkController,
              decoration: const InputDecoration(labelText: 'Produk'),
            ),

            const SizedBox(height: 12),
            TextField(
              controller: nominalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Nominal'),
            ),

            const SizedBox(height: 12),
            TextField(
              controller: hasilController,
              decoration: const InputDecoration(labelText: 'Hasil / Kendala'),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    rencanaKunjungan == null
                        ? 'Rencana Kunjungan'
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
                  child: const Text('Ganti Foto'),
                ),
                const SizedBox(width: 10),
                Text(foto == null ? 'Belum ada foto' : 'Foto siap'),
              ],
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: updateReport,
                child: const Text('Update Data'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
