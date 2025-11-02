class LokasiModel {
  final int id;
  final String qrcode;
  final String namaLokasi;
  final double latitude;
  final double longitude;
  final int isActive;
  final int comid;

  LokasiModel({
    required this.id,
    required this.qrcode,
    required this.namaLokasi,
    required this.latitude,
    required this.longitude,
    required this.isActive,
    required this.comid,
  });

  factory LokasiModel.fromJson(Map<String, dynamic> json) {
    double parseToDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseToInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return LokasiModel(
      id: parseToInt(json['id']),
      qrcode: json['qrcode'] ?? '',
      namaLokasi: json['nama_lokasi'] ?? '',
      latitude: parseToDouble(json['latitude']),
      longitude: parseToDouble(json['longitude']),
      isActive: parseToInt(json['is_active']),
      comid: parseToInt(json['comid']),
    );
  }
}
