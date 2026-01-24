class SituasiModel {
  final int id;
  final String tanggal;
  final int satpamId;
  final String satpamName;
  final String laporan;
  final String? foto;
  final int comid;
  final String comName;
  final String createdAt;

  SituasiModel({
    required this.id,
    required this.tanggal,
    required this.satpamId,
    required this.satpamName,
    required this.laporan,
    this.foto,
    required this.comid,
    required this.comName,
    required this.createdAt,
  });

  /// ======================
  /// FROM JSON
  /// ======================
  factory SituasiModel.fromJson(Map<String, dynamic> json) {
    return SituasiModel(
      id: json['id'] ?? 0,
      tanggal: json['tanggal'] ?? '',
      satpamId: json['satpam_id'] ?? 0,
      satpamName: json['satpam']['name'] ?? '',
      laporan: json['laporan'] ?? '',
      foto: json['foto'] ?? '',
      comid: json['comid'] ?? 0,
      comName: json['company']['company_name'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
