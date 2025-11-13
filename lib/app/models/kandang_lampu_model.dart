import 'package:hive/hive.dart';

part 'kandang_lampu_model.g.dart';

@HiveType(typeId: 8) // pastikan unik (beda dari model-model Hive lainnya)
class KandangLampuModel extends HiveObject {
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
  bool isLampOn;

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

  KandangLampuModel({
    this.id,
    required this.uuid,
    required this.tanggal,
    required this.jam,
    required this.kandangId,
    required this.satpamId,
    required this.isLampOn,
    this.note,
    this.foto,
    required this.comid,
    this.latitude,
    this.longitude,
    this.isSynced = false,
    this.syncedAt,
  });

  /// Konversi ke JSON untuk dikirim ke server
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "uuid": uuid,
      "tanggal": tanggal,
      "jam": jam,
      "kandang_id": kandangId,
      "satpam_id": satpamId,
      "is_lamp_on": isLampOn ? 1 : 0,
      "note": note,
      "foto": foto,
      "comid": comid,
      "latitude": latitude,
      "longitude": longitude,
    };
  }

  /// Konversi dari JSON (misal saat ambil data dari API)
  factory KandangLampuModel.fromJson(Map<String, dynamic> json) {
    return KandangLampuModel(
      id: json["id"],
      uuid: json["uuid"] ?? '',
      tanggal: json["tanggal"] ?? '',
      jam: json["jam"] ?? '',
      kandangId: json["kandang_id"] ?? 0,
      satpamId: json["satpam_id"] ?? 0,
      isLampOn: json["is_lamp_on"].toString() == '1',
      note: json["note"],
      foto: json["foto"],
      comid: json["comid"] ?? 0,
      latitude: (json["latitude"] as num?)?.toDouble(),
      longitude: (json["longitude"] as num?)?.toDouble(),
      isSynced: json["isSynced"] ?? false,
      syncedAt: json['syncedAt']?.toString(),
    );
  }
}
