import 'dart:convert';

class PemeriksaanDocModel {
  final String hari;
  final String tanggal;
  final String inputDate;
  final String supir;
  final String noPolisi;
  final String ekspedisi;
  final String tujuan;
  final String nomorSegel;
  final String note;
  final int totalEkor;
  final int jumlahBox;
  final List<BoxDoc> boxes;
  final List<String> fotos;

  PemeriksaanDocModel({
    required this.hari,
    required this.tanggal,
    required this.inputDate,
    required this.supir,
    required this.noPolisi,
    required this.ekspedisi,
    required this.tujuan,
    required this.nomorSegel,
    required this.note,
    required this.jumlahBox,
    required this.totalEkor,
    required this.boxes,
    required this.fotos,
  });

  factory PemeriksaanDocModel.fromJson(Map<String, dynamic> json) {
    // parse doc_box_option (string JSON)
    final List<BoxDoc> boxList = (json['doc_box_option'] != null)
        ? (jsonDecode(json['doc_box_option']) as List)
              .map((e) => BoxDoc.fromJson(e))
              .toList()
        : [];

    // parse foto (string JSON array)
    final List<String> fotoList = (json['foto'] != null)
        ? List<String>.from(jsonDecode(json['foto']))
        : [];

    return PemeriksaanDocModel(
      hari: _hariFromTanggal(json['tanggal']),
      tanggal: json['tanggal'] ?? '-',
      inputDate: json['input_date'] ?? '-',
      supir: json['nama_supir'] ?? '-',
      noPolisi: json['no_polisi'] ?? '-',
      ekspedisi: json['ekspedisi'] == null
          ? ''
          : json['ekspedisi']['name'] ?? '', // sesuaikan API
      tujuan: json['tujuan'] ?? '-',
      nomorSegel: json['nomor_segel'] ?? '-',
      note: json['note'] ?? '-',
      jumlahBox: json['jumlah'] ?? 0,
      totalEkor: json['total_ekor'] ?? 0,
      boxes: boxList,
      fotos: fotoList,
    );
  }

  static String _hariFromTanggal(String? tanggal) {
    if (tanggal == null) return '-';
    final dt = DateTime.parse(tanggal);
    const hari = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return hari[dt.weekday - 1];
  }
}

class BoxDoc {
  final String name;
  final String jumlahBox;
  final String isi;
  final String totalEkor;

  BoxDoc({
    required this.name,
    required this.jumlahBox,
    required this.isi,
    required this.totalEkor,
  });

  factory BoxDoc.fromJson(Map<String, dynamic> json) {
    final jumlah = int.tryParse(json['jumlah_box'] ?? '0') ?? 0;
    final isi = int.tryParse(json['isi'] ?? '0') ?? 0;

    return BoxDoc(
      name: json['option_name'] ?? '-',
      jumlahBox: json['jumlah_box'] ?? '0',
      isi: json['isi'] ?? '0',
      totalEkor: (jumlah * isi).toString(),
    );
  }
}
