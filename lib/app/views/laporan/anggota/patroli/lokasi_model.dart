class LokasiModel {
  final int id;
  final String locationName;

  LokasiModel({required this.id, required this.locationName});

  factory LokasiModel.fromJson(Map<String, dynamic> json) {
    return LokasiModel(id: json['id'], locationName: json['nama_lokasi']);
  }
}
