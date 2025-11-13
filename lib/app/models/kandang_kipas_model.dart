import 'package:hive/hive.dart';

part 'kandang_kipas_model.g.dart';

@HiveType(typeId: 6) // pastikan beda typeId dari model lain!
class KandangKipasModel extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String uuid;

  @HiveField(2)
  String tanggal;

  @HiveField(3)
  String jam;

  @HiveField(4)
  int kandangId;

  @HiveField(5)
  int satpamId;

  @HiveField(6)
  String? kipas; // contoh: "1,0,1,0,1" untuk kipas 1-5

  @HiveField(7)
  String? note;

  @HiveField(8)
  String? foto;

  @HiveField(9)
  int comid;

  @HiveField(10)
  double? latitude;

  @HiveField(11)
  double? longitude;

  @HiveField(12)
  bool isSynced;

  @HiveField(13)
  String? syncedAt;

  KandangKipasModel({
    this.id,
    required this.uuid,
    required this.tanggal,
    required this.jam,
    required this.kandangId,
    required this.satpamId,
    this.kipas,
    this.note,
    this.foto,
    required this.comid,
    this.latitude,
    this.longitude,
    this.isSynced = false,
    this.syncedAt,
  });

  /// Convert ke JSON (untuk sync ke server)
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "uuid": uuid,
      "tanggal": tanggal,
      "jam": jam,
      "kandang_id": kandangId,
      "satpam_id": satpamId,
      "kipas": kipas,
      "note": note,
      "foto": foto,
      "comid": comid,
      "latitude": latitude,
      "longitude": longitude,
    };
  }

  /// Convert dari JSON (misal saat ambil dari server)
  factory KandangKipasModel.fromJson(Map<String, dynamic> json) {
    return KandangKipasModel(
      id: json["id"],
      uuid: json["uuid"],
      tanggal: json["tanggal"],
      jam: json["jam"],
      kandangId: json["kandang_id"],
      satpamId: json["satpam_id"],
      kipas: json["kipas"],
      note: json["note"],
      foto: json["foto"],
      comid: json["comid"],
      latitude: (json["latitude"] as num?)?.toDouble(),
      longitude: (json["longitude"] as num?)?.toDouble(),
      isSynced: json["isSynced"] ?? false,
      syncedAt: json['syncedAt']?.toString(),
    );
  }
}
