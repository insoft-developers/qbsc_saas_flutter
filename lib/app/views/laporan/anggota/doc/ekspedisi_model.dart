class EkspedisiModel {
  final int id;
  final String name;

  EkspedisiModel({required this.id, required this.name});

  factory EkspedisiModel.fromJson(Map<String, dynamic> json) {
    return EkspedisiModel(id: json['id'], name: json['name']);
  }
}
