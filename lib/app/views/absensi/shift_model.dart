class ShiftModel {
  final int id;
  final String name;
  final String jamMasukAwal;
  final String jamMasuk;
  final String jamMasukAkhir;
  final String jamPulangAwal;
  final String jamPulang;
  final String jamPulangAkhir;
  final int comid;

  ShiftModel({
    required this.id,
    required this.name,
    required this.jamMasukAwal,
    required this.jamMasuk,
    required this.jamMasukAkhir,
    required this.jamPulangAwal,
    required this.jamPulang,
    required this.jamPulangAkhir,
    required this.comid,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id'],
      name: json['name'],
      jamMasukAwal: json['jam_masuk_awal'],
      jamMasuk: json['jam_masuk'],
      jamMasukAkhir: json['jam_masuk_akhir'],
      jamPulangAwal: json['jam_pulang_awal'],
      jamPulang: json['jam_pulang'],
      jamPulangAkhir: json['jam_pulang_akhir'],
      comid: json['comid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "jam_masuk_awal": jamMasukAwal,
      "jam_masuk": jamMasuk,
      "jam_masuk_akhir": jamMasukAkhir,
      "jam_pulang_awal": jamPulangAwal,
      "jam_pulang": jamPulang,
      "jam_pulang_akhir": jamPulangAkhir,
      "comid": comid,
    };
  }
}
