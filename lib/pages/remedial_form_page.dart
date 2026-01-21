import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/remedial_report_model.dart';
import '../models/master_nasabah_model.dart';
import '../services/db_helper.dart';
import 'remedial_list_page.dart';

class RemedialFormPage extends StatefulWidget {
  const RemedialFormPage({super.key});

  @override
  State<RemedialFormPage> createState() => _RemedialFormPageState();
}

class _RemedialFormPageState extends State<RemedialFormPage> {
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
    if (image != null) setState(() => foto = File(image.path));
  }

  Future<void> submitReport() async {
    if (namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama Nasabah wajib diisi')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final namaRemedial = prefs.getString('nama_remedial') ?? 'Unknown';

    String? fotoPath;
    if (foto != null) {
      fotoPath = await simpanFotoPermanen(foto!);
    }

    final report = RemedialReport(
      namaRemedial: namaRemedial,
      namaNasabah: namaController.text,
      alamat: alamatController.text,
      produk: produkController.text,
      nominal: nominalController.text,
      pokok: pokokController.text,
      bunga: bungaController.text,
      setor: setorController.text,
      status: statusValue,
      hasil: hasilController.text,
      rencanaKunjungan: rencanaKunjungan,
      fotoPath: fotoPath,
    );

    await DBHelper.insert(report);

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
            /// ==========================
            /// 🔍 AUTOCOMPLETE NASABAH
            /// ==========================
            Autocomplete<Map<String, dynamic>>(
              optionsBuilder: (TextEditingValue value) {
                if (value.text.length < 1) {
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
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Nama Nasabah',
                    hintText: 'Ketik nama nasabah',
                  ),
                  onChanged: (value) {
                    // sinkron ke controller utama
                    namaController.text = value;
                  },
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
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
