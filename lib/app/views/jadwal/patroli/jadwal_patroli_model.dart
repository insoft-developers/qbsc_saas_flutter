import 'package:hive_flutter/hive_flutter.dart';

part 'jadwal_patroli_model.g.dart';

@HiveType(typeId: 21) // pastikan unik (beda dari model-model Hive lainnya)
class JadwalPatroliModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int patroliId;

  @HiveField(2)
  int locationId;

  @HiveField(3)
  int urutan;

  @HiveField(4)
  String jamAwal;

  @HiveField(5)
  String jamAkhir;

  @HiveField(6)
  int comid;

  @HiveField(7)
  bool isChecked;

  JadwalPatroliModel({
    required this.id,
    required this.patroliId,
    required this.locationId,
    required this.urutan,
    required this.jamAwal,
    required this.jamAkhir,
    required this.comid,
    this.isChecked = false,
  });

  /// Konversi ke JSON untuk dikirim ke server
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "patroli_id": patroliId,
      "location_id": locationId,
      "urutan": urutan,
      "jam_awal": jamAwal,
      "jam_akhir": jamAkhir,
      "comid": comid,
    };
  }

  /// Konversi dari JSON (misal saat ambil data dari API)
  factory JadwalPatroliModel.fromJson(Map<String, dynamic> json) {
    return JadwalPatroliModel(
      id: json['id'],
      patroliId: json['patroli_id'],
      locationId: json['location_id'],
      urutan: json['urutan'],
      jamAwal: json['jam_awal'],
      jamAkhir: json['jam_akhir'],
      comid: json['comid'],
      isChecked: json['isChecked'] ?? false,
    );
  }
}
