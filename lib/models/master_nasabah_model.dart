class MasterNasabah {
  final int? id;
  final String nama;
  final String alamat;
  final String produk;
  final String nominal;

  MasterNasabah({
    this.id,
    required this.nama,
    required this.alamat,
    required this.produk,
    required this.nominal,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nama': nama,
      'alamat': alamat,
      'produk': produk,
      'nominal': nominal,
    };
  }

  factory MasterNasabah.fromMap(Map<String, dynamic> map) {
    return MasterNasabah(
      id: map['id'],
      nama: map['nama'],
      alamat: map['alamat'],
      produk: map['produk'],
      nominal: map['nominal'],
    );
  }
}
