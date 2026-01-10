class AbsensiAnggotaModel {
  final int id;
  final String name;
  final String whatsapp;
  final String tanggal;
  final String jamMasuk;
  final String jamKeluar;
  final int status;
  final String foto;

  AbsensiAnggotaModel({
    required this.id,
    required this.name,
    required this.whatsapp,
    required this.tanggal,
    required this.jamMasuk,
    required this.jamKeluar,
    required this.status,
    required this.foto,
  });

  factory AbsensiAnggotaModel.fromJson(Map<String, dynamic> json) {
    return AbsensiAnggotaModel(
      id: json['id'],
      name: json['name'],
      whatsapp: json['whatsapp'],
      tanggal: json['tanggal'] ?? '',
      jamMasuk: json['jam_masuk'] ?? '',
      jamKeluar: json['jam_keluar'] ?? '',
      status: json['status'] ?? 0,
      foto: json['face_photo_path'] ?? '',
    );
  }
}
