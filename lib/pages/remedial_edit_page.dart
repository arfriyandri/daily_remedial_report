import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../models/remedial_report_model.dart';
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
  final produkController = TextEditingController();
  final nominalController = TextEditingController();
  final pokokController = TextEditingController();
  final bungaController = TextEditingController();
  final setorController = TextEditingController();
  final hasilController = TextEditingController();

  List<Map<String, dynamic>> masterNasabah = [];

  String statusValue = '';
  DateTime? rencanaKunjungan;

  File? foto;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    final d = widget.data;

    namaController.text = d.namaNasabah;
    alamatController.text = d.alamat;
    produkController.text = d.produk;
    nominalController.text = d.nominal;
    pokokController.text = d.pokok ?? '';
    bungaController.text = d.bunga ?? '';
    setorController.text = d.setor ?? '';
    hasilController.text = d.hasil;

    statusValue = d.status;
    rencanaKunjungan = d.rencanaKunjungan;

    if (d.fotoPath != null) {
      foto = File(d.fotoPath!);
    }

    loadMasterNasabah();
  }

  Future<void> loadMasterNasabah() async {
    masterNasabah = await DBHelper().getMasterNasabah();
    setState(() {});
  }

  Future<String?> simpanFotoPermanen(File foto) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        'foto_${DateTime.now().millisecondsSinceEpoch}${p.extension(foto.path)}';
    final newPath = p.join(dir.path, fileName);
    return (await foto.copy(newPath)).path;
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
      produk: produkController.text,
      nominal: nominalController.text,
      pokok: pokokController.text,
      bunga: bungaController.text,
      setor: setorController.text,
      status: statusValue,
      hasil: hasilController.text,
      tanggalLaporan: widget.data.tanggalLaporan,
      rencanaKunjungan: rencanaKunjungan,
      fotoPath: fotoPath,
    );

    await DBHelper.update(updated);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RemedialListPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Lending Report')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// AUTOCOMPLETE NASABAH
            Autocomplete<Map<String, dynamic>>(
              optionsBuilder: (value) {
                if (value.text.isEmpty) {
                  return const Iterable.empty();
                }
                return masterNasabah.where(
                  (item) => item['nama'].toString().toLowerCase().contains(
                    value.text.toLowerCase(),
                  ),
                );
              },
              displayStringForOption: (option) => option['nama'],
              fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                controller.text = namaController.text;
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(labelText: 'Nama Nasabah'),
                  onChanged: (v) => namaController.text = v,
                );
              },
              onSelected: (selected) {
                namaController.text = selected['nama'];
                alamatController.text = selected['alamat'] ?? '';
                produkController.text = selected['produk'] ?? '';
                nominalController.text = selected['nominal'] ?? '';
                pokokController.text = selected['pokok'] ?? '';
                bungaController.text = selected['bunga'] ?? '';
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
                DropdownMenuItem(value: '', child: Text('')),
                DropdownMenuItem(value: 'Follow Up', child: Text('Follow Up')),
                DropdownMenuItem(value: 'Top Up', child: Text('Top Up')),
              ],
              onChanged: (v) => setState(() => statusValue = v!),
              decoration: const InputDecoration(labelText: 'Status'),
            ),

            const SizedBox(height: 12),
            TextField(
              controller: produkController,
              decoration: const InputDecoration(labelText: 'Kol/Jenis Kredit'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nominalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Plafon'),
            ),
            TextField(
              controller: pokokController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Pokok'),
            ),
            TextField(
              controller: bungaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Bunga'),
            ),
            TextField(
              controller: setorController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Setor'),
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
