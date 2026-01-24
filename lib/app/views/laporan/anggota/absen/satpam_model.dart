class SatpamModel {
  final int id;
  final String name;

  SatpamModel({required this.id, required this.name});

  factory SatpamModel.fromJson(Map<String, dynamic> json) {
    return SatpamModel(id: json['id'], name: json['name']);
  }
}
