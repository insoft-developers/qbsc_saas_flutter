import 'package:hive/hive.dart';

part 'kandang_suhu_model.g.dart';

@HiveType(typeId: 5)
class KandangSuhuModel extends HiveObject {
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
  double? stdTemp;

  @HiveField(7)
  double? temperature;

  @HiveField(8)
  String? note;

  @HiveField(9)
  String? foto;

  @HiveField(10)
  int comid;

  @HiveField(11)
  double? latitude;

  @HiveField(12)
  double? longitude;

  /// Menandakan apakah data sudah disinkronkan ke server
  @HiveField(13)
  bool isSynced;

  @HiveField(14)
  String? syncedAt;

  KandangSuhuModel({
    this.id,
    required this.uuid,
    required this.tanggal,
    required this.jam,
    required this.kandangId,
    required this.satpamId,
    this.stdTemp,
    this.temperature,
    this.note,
    this.foto,
    required this.comid,
    this.latitude,
    this.longitude,
    this.isSynced = false,
    this.syncedAt,
  });

  /// Convert ke JSON untuk dikirim ke server
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "uuid": uuid,
      "tanggal": tanggal,
      "jam": jam,
      "kandang_id": kandangId,
      "satpam_id": satpamId,
      "std_temp": stdTemp,
      "temperature": temperature,
      "note": note,
      "foto": foto,
      "comid": comid,
      "latitude": latitude,
      "longitude": longitude,
    };
  }

  /// Buat dari JSON (kalau download dari server)
  factory KandangSuhuModel.fromJson(Map<String, dynamic> json) {
    return KandangSuhuModel(
      id: json["id"],
      uuid: json["uuid"],
      tanggal: json["tanggal"],
      jam: json["jam"],
      kandangId: json["kandang_id"],
      satpamId: json["satpam_id"],
      stdTemp: (json["std_temp"] as num?)?.toDouble(),
      temperature: (json["temperature"] as num?)?.toDouble(),
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
