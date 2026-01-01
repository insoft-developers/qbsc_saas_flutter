class AbsensiModel {
  final int id;
  final String tanggal;
  final int satpamId;
  final String satpamName;
  final String latitude;
  final String longitude;
  final String jamMasuk;
  final String jamKeluar;
  final String shiftName;
  final int status;
  final String description;
  final String catatanMasuk;
  final String catatanKeluar;
  final int comid;
  final String comName;
  final String createdAt;

  AbsensiModel({
    required this.id,
    required this.tanggal,
    required this.satpamId,
    required this.satpamName,
    required this.latitude,
    required this.longitude,
    required this.jamMasuk,
    required this.jamKeluar,
    required this.shiftName,
    required this.status,
    required this.description,
    required this.catatanMasuk,
    required this.catatanKeluar,
    required this.comid,
    required this.comName,
    required this.createdAt,
  });

  /// ================= FROM JSON =================
  factory AbsensiModel.fromJson(Map<String, dynamic> json) {
    return AbsensiModel(
      id: json['id'] ?? 0,
      tanggal: json['tanggal'] ?? '',
      satpamId: json['satpam_id'] ?? 0,
      satpamName: json['satpam']['name'] ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      jamMasuk: json['jam_masuk'] ?? '',
      jamKeluar: json['jam_keluar'] ?? '',
      shiftName: json['shift_name'] ?? '',
      status: json['status'] ?? 0,
      description: json['description'] ?? '',
      catatanMasuk: json['catatan_masuk'] ?? '',
      catatanKeluar: json['catatan_keluar'] ?? '',
      comid: json['comid'] ?? 0,
      comName: json['company']['company_name'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
