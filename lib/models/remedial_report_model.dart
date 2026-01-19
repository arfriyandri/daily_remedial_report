class RemedialReport {
  final int? id;

  final String namaRemedial;
  final String namaNasabah;
  // final String usaha;
  final String alamat;
  final String nominal;
  final String status;
  final String produk;
  final String hasil;

  final DateTime tanggalLaporan;
  final DateTime? rencanaKunjungan;
  final String? fotoPath;

  RemedialReport({
    this.id,
    required this.namaRemedial,
    required this.namaNasabah,
    // required this.usaha,
    required this.alamat,
    required this.nominal,
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
      if (id != null) 'id': id,
      'namaRemedial': namaRemedial,
      'namaNasabah': namaNasabah,
      // 'usaha': usaha,
      'alamat': alamat,
      'nominal': nominal,
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
      // usaha: map['usaha'] ?? '',
      alamat: map['alamat'] ?? '',
      nominal: map['nominal'] ?? '',
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
