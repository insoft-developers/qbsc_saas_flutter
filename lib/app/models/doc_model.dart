import 'package:hive_flutter/hive_flutter.dart';

part 'doc_model.g.dart';

@HiveType(typeId: 10) // pastikan unik (beda dari model-model Hive lainnya)
class DocModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String tanggal;

  @HiveField(2)
  String jam;

  @HiveField(3)
  int satpamId;

  @HiveField(4)
  int jumlah;

  @HiveField(5)
  int ekspedisiId;

  @HiveField(6)
  String? tujuan;

  @HiveField(7)
  String? noPolisi;

  @HiveField(8)
  int jenis;

  @HiveField(9)
  String? note;

  @HiveField(10)
  String? foto;

  @HiveField(11)
  int comid;

  @HiveField(12)
  String createdAt;

  @HiveField(13)
  bool isSynced;

  DocModel({
    required this.id,
    required this.tanggal,
    required this.jam,
    required this.satpamId,
    required this.jumlah,
    required this.ekspedisiId,
    this.tujuan,
    this.noPolisi,
    required this.jenis,
    this.note,
    this.foto,
    required this.comid,
    required this.createdAt,
    this.isSynced = false,
  });

  /// Konversi ke JSON untuk dikirim ke server
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "tanggal": tanggal,
      "jam": jam,
      "satpam_id": satpamId,
      "jumlah": jumlah,
      "ekpedisi_id": ekspedisiId,
      "tujuan": tujuan,
      "no_polisi": noPolisi,
      "jenis": jenis,
      "note": note,
      "foto": foto,
      "comid": comid,
    };
  }

  /// Konversi dari JSON (misal saat ambil data dari API)
  factory DocModel.fromJson(Map<String, dynamic> json) {
    return DocModel(
      id: json['id'],
      tanggal: json['tanggal'],
      jam: json['jam'],
      satpamId: json['satpam_id'],
      jumlah: json['jumlah'],
      ekspedisiId: json['ekspedisi_id'],
      tujuan: json['tujuan'] ?? '',
      noPolisi: json['no_polisi'] ?? '',
      jenis: json['jenis'],
      note: json['note'] ?? '',
      foto: json['foto'],
      comid: json['comid'],
      createdAt: json['created_at'],
    );
  }
}
