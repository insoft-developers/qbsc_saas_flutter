import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

part 'doc_model.g.dart';

@HiveType(typeId: 10)
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

  /// MULTI FOTO
  @HiveField(10)
  List<String> foto;

  /// ===============================
  /// DOC BOX OPTION (JSON STRING)
  /// ===============================
  @HiveField(11)
  String docBoxOptionJson;

  @HiveField(12)
  String namaSupir;

  @HiveField(13)
  String nomorSegel;

  @HiveField(14)
  int totalEkor;

  @HiveField(15)
  int comid;

  @HiveField(16)
  String createdAt;

  @HiveField(17)
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
    List<String>? foto,
    String? docBoxOptionJson,
    required this.namaSupir,
    required this.nomorSegel,
    required this.totalEkor,
    required this.comid,
    required this.createdAt,
    this.isSynced = false,
  }) : foto = foto ?? [],
       docBoxOptionJson = docBoxOptionJson ?? '[]';

  // ===============================
  // HELPER GETTER / SETTER
  // ===============================
  List<Map<String, dynamic>> get docBoxOption {
    final decoded = jsonDecode(docBoxOptionJson);
    return List<Map<String, dynamic>>.from(decoded);
  }

  set docBoxOption(List<Map<String, dynamic>> value) {
    docBoxOptionJson = jsonEncode(value);
  }

  // ===============================
  // TO JSON (KIRIM KE SERVER)
  // ===============================
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "tanggal": tanggal,
      "jam": jam,
      "satpam_id": satpamId,
      "jumlah": jumlah,
      "ekspedisi_id": ekspedisiId,
      "tujuan": tujuan,
      "no_polisi": noPolisi,
      "jenis": jenis,
      "note": note,
      "foto": foto,
      "doc_box_option": docBoxOption,
      "nama_supir": namaSupir,
      "nomor_segel": nomorSegel,
      "total_ekor": totalEkor,
      "comid": comid,
    };
  }

  // ===============================
  // FROM JSON (DARI SERVER)
  // ===============================
  factory DocModel.fromJson(Map<String, dynamic> json) {
    return DocModel(
      id: json['id'],
      tanggal: json['tanggal'],
      jam: json['jam'],
      satpamId: json['satpam_id'],
      jumlah: json['jumlah'],
      ekspedisiId: json['ekspedisi_id'],
      tujuan: json['tujuan'],
      noPolisi: json['no_polisi'],
      jenis: json['jenis'],
      note: json['note'],
      foto: json['foto'] != null ? List<String>.from(json['foto']) : [],
      docBoxOptionJson: json['doc_box_option'] != null
          ? jsonEncode(json['doc_box_option'])
          : '[]',
      namaSupir: json['nama_supir'] ?? '',
      nomorSegel: json['nomor_segel'] ?? '',
      totalEkor: json['total_ekor'] ?? 0,
      comid: json['comid'],
      createdAt: json['created_at'],
      isSynced: true,
    );
  }
}
