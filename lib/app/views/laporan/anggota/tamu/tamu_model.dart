class TamuModel {
  final int id;
  final String uuid;
  final int? satpamId;
  final String? satpamName;
  final int? satpamIdPulang;
  final String? satpamPulangName;
  final String namaTamu;
  final int jumlahTamu;
  final String? tujuan;
  final String? whatsapp;
  final String? foto;
  final int isStatus;
  final String? catatan;
  final String? arriveAt;
  final String? leaveAt;
  final int? createdBy;
  final String? createdName;
  final int comid;
  final String comName;
  final String createdAt;

  TamuModel({
    required this.id,
    required this.uuid,
    this.satpamId,
    this.satpamName,
    this.satpamIdPulang,
    this.satpamPulangName,
    required this.namaTamu,
    required this.jumlahTamu,
    this.tujuan,
    this.whatsapp,
    this.foto,
    required this.isStatus,
    this.catatan,
    this.arriveAt,
    this.leaveAt,
    this.createdBy,
    this.createdName,
    required this.comid,
    required this.comName,
    required this.createdAt,
  });

  /// ======================
  /// FROM JSON
  /// ======================
  factory TamuModel.fromJson(Map<String, dynamic> json) {
    return TamuModel(
      id: json['id'] ?? 0,
      uuid: json['uuid'],
      satpamId: json['satpam_id'] ?? 0,
      satpamName: json['satpam'] != null ? json['satpam']['name'] : null,

      satpamIdPulang: json['satpam_id_pulang'] ?? 0,
      satpamPulangName: json['satpam_pulang'] != null
          ? json['satpam_pulang']['name']
          : null,
      namaTamu: json['nama_tamu'] ?? '',
      jumlahTamu: json['jumlah_tamu'] ?? 0,
      tujuan: json['tujuan'] ?? '',
      whatsapp: json['whatsapp'] ?? '',
      foto: json['foto'] ?? '',
      isStatus: json['is_status'] ?? 0,
      catatan: json['catatan'] ?? '',
      arriveAt: json['arrive_at'] ?? '',
      leaveAt: json['leave_at'] ?? '',
      createdBy: json['created_by'] ?? 0,
      createdName: json['user'] != null ? json['user']['name'] : 'Satpam',
      comid: json['comid'] ?? 0,
      comName: json['company']['company_name'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
