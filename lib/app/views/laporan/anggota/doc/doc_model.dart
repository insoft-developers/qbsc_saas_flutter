import 'dart:convert';

class DocModel {
  final int id;
  final String tanggal;
  final String? inputDate;
  final String jam;
  final int satpamId;
  final String satpamName;
  final int jumlah;
  final int ekspedisiId;
  final String ekspedisiName;
  final String? tujuan;
  final String? noPolisi;
  final int jenis;
  final String? note;
  final List<String> foto;
  final String docBoxOptionJson;
  final String namaSupir;
  final String nomorSegel;
  final int totalEkor;
  final int comid;
  final String comName;
  final String createdAt;

  DocModel({
    required this.id,
    required this.tanggal,
    this.inputDate,
    required this.jam,
    required this.satpamId,
    required this.satpamName,
    required this.jumlah,
    required this.ekspedisiId,
    required this.ekspedisiName,
    this.tujuan,
    this.noPolisi,
    required this.jenis,
    this.note,
    required this.foto,
    required this.docBoxOptionJson,
    required this.namaSupir,
    required this.nomorSegel,
    required this.totalEkor,
    required this.comid,
    required this.comName,
    required this.createdAt,
  });

  factory DocModel.fromJson(Map<String, dynamic> json) {
    return DocModel(
      id: json['id'],
      tanggal: json['tanggal'],
      inputDate: json['input_date'],
      jam: json['jam'],
      satpamId: json['satpam_id'],
      satpamName: json['satpam']?['name'] ?? '',
      jumlah: json['jumlah'],
      ekspedisiId: json['ekspedisi_id'],
      ekspedisiName: json['ekspedisi']?['name'] ?? '',
      tujuan: json['tujuan'],
      noPolisi: json['no_polisi'],
      jenis: json['jenis'],
      note: json['note'] ?? '',
      foto: _parseFoto(json['foto']),

      // 🔥 INI DIA TEMPATNYA
      docBoxOptionJson: _parseBoxOption(json['doc_box_option']),

      namaSupir: json['nama_supir'] ?? '',
      nomorSegel: json['nomor_segel'] ?? '',
      totalEkor: json['total_ekor'] ?? 0,
      comid: json['comid'],
      comName: json['company']?['company_name'] ?? '',
      createdAt: json['created_at'],
    );
  }

  // ================= FOTO PARSER =================
  static List<String> _parseFoto(dynamic foto) {
    if (foto == null) return [];

    if (foto is String && foto.isNotEmpty) {
      // string JSON array
      if (foto.trim().startsWith('[')) {
        try {
          final List list = jsonDecode(foto);
          return list.map((e) => e.toString()).toList();
        } catch (_) {
          return [];
        }
      }
      return [foto];
    }

    if (foto is List) {
      return foto.map((e) => e.toString()).toList();
    }

    return [];
  }

  // ================= BOX OPTION PARSER =================
  static String _parseBoxOption(dynamic box) {
    if (box == null) return '[]';

    // API kirim STRING JSON
    if (box is String && box.isNotEmpty) {
      try {
        final decoded = jsonDecode(box);

        if (decoded is List) {
          return jsonEncode(decoded);
        }

        if (decoded is Map) {
          return jsonEncode([decoded]);
        }
      } catch (_) {
        return '[]';
      }
    }

    // Sudah LIST
    if (box is List) {
      return jsonEncode(box);
    }

    // Object tunggal
    if (box is Map<String, dynamic>) {
      return jsonEncode([box]);
    }

    return '[]';
  }
}
