class KandangWaModel {
  final int id;
  final String name;
  final String suhu;
  final String kipas;
  final String alarm;
  final String lampu;
  final String kipasImage;

  KandangWaModel({
    required this.id,
    required this.name,
    required this.suhu,
    required this.kipas,
    required this.alarm,
    required this.lampu,
    required this.kipasImage,
  });

  factory KandangWaModel.fromJson(Map<String, dynamic> json) {
    return KandangWaModel(
      id: json['id'],
      name: json['name'] ?? '',
      suhu: json['suhu']?.toString() ?? '',
      kipas: json['kipas'] ?? '',
      alarm: json['alarm']?.toString() ?? '',
      lampu: json['lampu']?.toString() ?? '',
      kipasImage: json['kipas_image'] ?? '',
    );
  }
}
