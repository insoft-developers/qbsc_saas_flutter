class KandangModel {
  final int id;
  final String name;

  KandangModel({required this.id, required this.name});

  factory KandangModel.fromJson(Map<String, dynamic> json) {
    return KandangModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'],
    );
  }
}
