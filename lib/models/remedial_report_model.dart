class RemedialReport {
  final int? id;

  // 🔑 IDENTITAS
  final String namaRemedial; // petugas / user
  final String namaNasabah;

  // 📄 DATA NASABAH
  final String alamat;
  final String nominal;
  final String pokok;
  final String bunga;
  final String setor;
  final String status;
  final String produk;
  final String hasil;

  // 🗓 TANGGAL
  final DateTime tanggalLaporan;
  final DateTime? rencanaKunjungan;

  // 📷 FOTO
  final String? fotoPath;

  RemedialReport({
    this.id,
    required this.namaRemedial,
    required this.namaNasabah,
    required this.alamat,
    required this.nominal,
    required this.pokok,
    required this.bunga,
    required this.setor,
    required this.status,
    required this.produk,
    required this.hasil,
    DateTime? tanggalLaporan,
    this.rencanaKunjungan,
    this.fotoPath,
  }) : tanggalLaporan = tanggalLaporan ?? DateTime.now();

  // ======================
  // SIMPAN KE SQLITE
  // ======================
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'namaRemedial': namaRemedial,
      'namaNasabah': namaNasabah,
      'alamat': alamat,
      'nominal': nominal,
      'pokok': pokok,
      'bunga': bunga,
      'setor': setor,
      'status': status,
      'produk': produk,
      'hasil': hasil,
      'tanggalLaporan': tanggalLaporan.toIso8601String(),
      'rencanaKunjungan': rencanaKunjungan?.toIso8601String(),
      'fotoPath': fotoPath,
    };
  }

  // ======================
  // AMBIL DARI SQLITE
  // ======================
  factory RemedialReport.fromMap(Map<String, dynamic> map) {
    return RemedialReport(
      id: map['id'] as int?,
      namaRemedial: map['namaRemedial'] ?? '',
      namaNasabah: map['namaNasabah'] ?? '',
      alamat: map['alamat'] ?? '',
      nominal: map['nominal'] ?? '',
      pokok: map['pokok'] ?? '',
      bunga: map['bunga'] ?? '',
      setor: map['setor'] ?? '',
      status: map['status'] ?? '',
      produk: map['produk'] ?? '',
      hasil: map['hasil'] ?? '',
      tanggalLaporan: map['tanggalLaporan'] != null
          ? DateTime.parse(map['tanggalLaporan'])
          : DateTime.now(),
      rencanaKunjungan: map['rencanaKunjungan'] != null
          ? DateTime.parse(map['rencanaKunjungan'])
          : null,
      fotoPath: map['fotoPath'],
    );
  }
}
