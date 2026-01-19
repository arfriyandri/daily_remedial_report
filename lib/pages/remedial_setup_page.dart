import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'remedial_list_page.dart';

class RemedialSetupPage extends StatefulWidget {
  const RemedialSetupPage({super.key});

  @override
  State<RemedialSetupPage> createState() => _RemedialSetupPageState();
}

class _RemedialSetupPageState extends State<RemedialSetupPage> {
  final TextEditingController namaController = TextEditingController();
  bool loading = false;

  Future<void> simpanNamaRemedial() async {
    if (namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama Remedial wajib diisi')),
      );
      return;
    }

    setState(() => loading = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nama_remedial', namaController.text.trim());

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RemedialListPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Remedial')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Masukkan Nama Remedial',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Remedial',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : simpanNamaRemedial,
                child: Text(loading ? 'Menyimpan...' : 'Lanjut'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
