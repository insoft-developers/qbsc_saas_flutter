class SuhuModel {
  final int id;
  final String tanggal;
  final String jam;
  final int kandangId;
  final String kandangName;
  final int satpamId;
  final String satpamName;
  final int temperature;
  final String? note;
  final String? foto;
  final int comid;
  final String companyName;
  final String? latitude;
  final String? longitude;
  final String createdAt;

  SuhuModel({
    required this.id,
    required this.tanggal,
    required this.jam,
    required this.kandangId,
    required this.kandangName,
    required this.satpamId,
    required this.satpamName,
    required this.temperature,
    this.note,
    this.foto,
    required this.comid,
    required this.companyName,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  factory SuhuModel.fromJson(Map<String, dynamic> json) {
    return SuhuModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      tanggal: json['tanggal'] ?? '',
      jam: json['jam'] ?? '',
      kandangId: json['kandang_id'] is int
          ? json['kandang_id']
          : int.tryParse(json['kandang_id'].toString()) ?? 0,
      kandangName: json['kandang']['name'] ?? '',
      satpamId: json['satpam_id'] is int
          ? json['satpam_id']
          : int.tryParse(json['satpam_id'].toString()) ?? 0,
      satpamName: json['satpam']['name'] ?? '',
      temperature: json['temperature'] is int
          ? json['temperature']
          : int.tryParse(json['temperature'].toString()) ?? 0,
      note: json['note'],
      foto: json['foto'] ?? '',
      comid: json['comid'] is int
          ? json['comid']
          : int.tryParse(json['comid'].toString()) ?? 0,
      companyName: json['company']['company_name'] ?? '',
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      createdAt: json['created_at'] ?? '',
    );
  }
}
