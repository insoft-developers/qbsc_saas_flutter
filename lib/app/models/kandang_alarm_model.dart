import 'package:hive/hive.dart';

part 'kandang_alarm_model.g.dart';

@HiveType(typeId: 7) // pastikan typeId unik
class KandangAlarmModel extends HiveObject {
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
  bool isAlarmOn;

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

  KandangAlarmModel({
    this.id,
    required this.uuid,
    required this.tanggal,
    required this.jam,
    required this.kandangId,
    required this.satpamId,
    required this.isAlarmOn,
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
      "is_alarm_on": isAlarmOn ? 1 : 0,
      "note": note,
      "foto": foto,
      "comid": comid,
      "latitude": latitude,
      "longitude": longitude,
    };
  }

  /// Convert dari JSON (misal saat fetch dari API)
  factory KandangAlarmModel.fromJson(Map<String, dynamic> json) {
    return KandangAlarmModel(
      id: json["id"],
      uuid: json["uuid"] ?? '',
      tanggal: json["tanggal"] ?? '',
      jam: json["jam"] ?? '',
      kandangId: json["kandang_id"] ?? 0,
      satpamId: json["satpam_id"] ?? 0,
      isAlarmOn: json["is_alarm_on"].toString() == '1',
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
