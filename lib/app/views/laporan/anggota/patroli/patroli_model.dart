class PatroliModel {
  final int id;
  final String tanggal;
  final String jam;
  final String? jamAwal;
  final String? jamAkhir;

  final int locationId;
  final String locationName;

  final int satpamId;
  final String satpamName;

  final String? fotoSatpam;

  final String? latitude;
  final String? longitude;

  final String? note;
  final String? foto;

  final int comid;
  final String companyName;
  final String createdAt;

  PatroliModel({
    required this.id,
    required this.tanggal,
    required this.jam,
    this.jamAwal,
    this.jamAkhir,
    required this.locationId,
    required this.locationName,
    required this.satpamId,
    required this.satpamName,
    this.fotoSatpam,
    this.latitude,
    this.longitude,
    this.note,
    this.foto,
    required this.comid,
    required this.companyName,
    required this.createdAt,
  });

  /// =========================
  /// FROM JSON
  /// =========================
  factory PatroliModel.fromJson(Map<String, dynamic> json) {
    return PatroliModel(
      id: json['id'],
      tanggal: json['tanggal'] ?? '',
      jam: json['jam'] ?? '',
      jamAwal: json['jam_awal'],
      jamAkhir: json['jam_akhir'],
      locationId: json['location_id'] ?? 0,
      locationName: json['lokasi'] != null
          ? json['lokasi']['nama_lokasi'] ?? ''
          : '',
      satpamId: json['satpam_id'],
      satpamName: json['satpam']['name'] ?? '',
      fotoSatpam: json['satpam'] != null
          ? json['satpam']['face_photo_path'] ?? ''
          : '',
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      note: json['note'] ?? '',
      foto: json['photo_path'] ?? '',
      comid: json['comid'],
      companyName: json['company']['company_name'] ?? '',
      createdAt: json['created_at'],
    );
  }
}
