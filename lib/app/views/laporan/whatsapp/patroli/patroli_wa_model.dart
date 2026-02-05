class PatroliWaModel {
  final int id;
  final String tanggal;
  final String jam;
  final String hari;
  final String jamAwalPatroli;
  final String jamAkhirPatroli;
  final String locationName;
  final String locationUrl;
  final String note;
  final String foto;

  PatroliWaModel({
    required this.id,
    required this.tanggal,
    required this.hari,
    required this.jam,
    required this.jamAwalPatroli,
    required this.jamAkhirPatroli,
    required this.locationName,
    required this.locationUrl,
    required this.note,
    required this.foto,
  });

  factory PatroliWaModel.fromJson(Map<String, dynamic> json) {
    return PatroliWaModel(
      id: json['id'],
      tanggal: json['tanggal'] ?? '',
      hari: _hariFromTanggal(json['tanggal']),
      jam: json['jam'] ?? '',
      jamAwalPatroli: json['jam_awal_patroli'] ?? '',
      jamAkhirPatroli: json['jam_akhir_patroli'] ?? '',
      locationName: json['lokasi']['nama_lokasi'] ?? '',
      locationUrl: (json['latitude'] != null && json['longitude'] != null)
          ? 'https://www.google.com/maps/search/?api=1&query=${json['latitude']},${json['longitude']}'
          : '',

      note: json['note'] ?? '',
      foto: json['photo_path'] ?? '',
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
