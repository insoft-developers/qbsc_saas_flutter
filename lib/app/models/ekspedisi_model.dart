import 'package:hive_flutter/hive_flutter.dart';

part 'ekspedisi_model.g.dart';

@HiveType(typeId: 9) // pastikan unik (beda dari model-model Hive lainnya)
class EkspedisiModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String code;

  @HiveField(2)
  String name;

  @HiveField(3)
  int comid;

  EkspedisiModel({
    required this.id,
    required this.code,
    required this.name,
    required this.comid,
  });

  /// Konversi ke JSON untuk dikirim ke server
  Map<String, dynamic> toJson() {
    return {"id": id, "code": code, "name": name, "comid": comid};
  }

  /// Konversi dari JSON (misal saat ambil data dari API)
  factory EkspedisiModel.fromJson(Map<String, dynamic> json) {
    return EkspedisiModel(
      id: json["id"],
      code: json["code"] ?? '',
      name: json["name"] ?? '',
      comid: json["comid"] ?? 0,
    );
  }
}
