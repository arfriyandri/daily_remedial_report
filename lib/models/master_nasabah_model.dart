class MasterNasabah {
  final int? id;
  final String nama;
  final String alamat;
  final String produk;
  final String nominal;
  final String pokok;
  final String bunga;
  final String setor;

  MasterNasabah({
    this.id,
    required this.nama,
    required this.alamat,
    required this.produk,
    required this.nominal,
    this.pokok = '',
    this.bunga = '',
    this.setor = '',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nama': nama,
      'alamat': alamat,
      'produk': produk,
      'nominal': nominal,
      'pokok': pokok,
      'bunga': bunga,
      'setor': setor,
    };
  }

  factory MasterNasabah.fromMap(Map<String, dynamic> map) {
    return MasterNasabah(
      id: map['id'],
      nama: map['nama'],
      alamat: map['alamat'],
      produk: map['produk'],
      nominal: map['nominal'],
      pokok: map['pokok'] ?? '',
      bunga: map['bunga'] ?? '',
      setor: map['setor'] ?? '',
    );
  }
}
