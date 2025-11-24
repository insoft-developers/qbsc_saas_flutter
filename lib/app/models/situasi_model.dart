import 'package:hive_flutter/hive_flutter.dart';

part 'situasi_model.g.dart';

@HiveType(typeId: 11)
class SituasiModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  int satpamId;

  @HiveField(2)
  String createdAt;

  @HiveField(3)
  String laporan;

  @HiveField(4)
  String? foto;

  @HiveField(5)
  int comid;

  @HiveField(6)
  bool isSynced;

  SituasiModel({
    required this.id,
    required this.satpamId,
    required this.createdAt,
    required this.laporan,
    this.foto,
    required this.comid,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "satpam_id": satpamId,
      "tanggal": createdAt,
      "laporan": laporan,
      "foto": foto,
      "comid": comid,
    };
  }

  factory SituasiModel.fromJson(Map<String, dynamic> json) {
    return SituasiModel(
      id: json['id'],
      satpamId: json['satpam_id'],
      createdAt: json['tanggal'],
      laporan: json['laporan'],
      foto: json['foto'],
      comid: json['comid'],
    );
  }
}
