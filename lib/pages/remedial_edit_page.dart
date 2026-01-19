import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../models/remedial_report_model.dart';
import '../services/db_helper.dart';

class RemedialEditPage extends StatefulWidget {
  final RemedialReport data;

  const RemedialEditPage({super.key, required this.data});

  @override
  State<RemedialEditPage> createState() => _RemedialEditPageState();
}

class _RemedialEditPageState extends State<RemedialEditPage> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController usahaController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController nominalController = TextEditingController();
  final TextEditingController hasilController = TextEditingController();

  String statusValue = 'New';
  final TextEditingController produkController = TextEditingController();
  DateTime? rencanaKunjungan;

  File? foto;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    final d = widget.data;

    namaController.text = d.namaNasabah;
    // usahaController.text = d.usaha;
    alamatController.text = d.alamat;
    nominalController.text = d.nominal;
    hasilController.text = d.hasil;

    statusValue = d.status;
    produkController.text = d.produk;
    rencanaKunjungan = d.rencanaKunjungan;

    if (d.fotoPath != null && File(d.fotoPath!).existsSync()) {
      foto = File(d.fotoPath!);
    }
  }

  Future<void> ambilFoto() async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => foto = File(image.path));
    }
  }

  Future<void> pilihTanggalKunjungan() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: rencanaKunjungan ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => rencanaKunjungan = picked);
    }
  }

  // ==========================
  // UPDATE DATA (FIX)
  // ==========================
  Future<void> submitUpdate() async {
    if (namaController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama Nasabah wajib diisi')));
      return;
    }

    final updated = RemedialReport(
      id: widget.data.id, // 🔥 WAJIB
      namaRemedial: widget.data.namaRemedial,
      namaNasabah: namaController.text,
      // usaha: usahaController.text,
      alamat: alamatController.text,
      nominal: nominalController.text,
      status: statusValue,
      produk: produkController.text,
      hasil: hasilController.text,
      tanggalLaporan: widget.data.tanggalLaporan, // ❗ JANGAN DIUBAH
      rencanaKunjungan: rencanaKunjungan,
      fotoPath: foto?.path,
    );

    await DBHelper.update(updated);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Data berhasil diperbarui')));

    Navigator.pop(context, true); // 🔙 BALIK KE LIST
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Remedial Report')),
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
                  child: const Text('Update Foto'),
                ),
                const SizedBox(width: 10),
                Text(foto == null ? 'Tidak ada foto' : 'Foto siap'),
              ],
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitUpdate,
                child: const Text('Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
