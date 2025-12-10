class EmergencyModel {
  final int id;
  final String name;
  final String whatsapp;

  EmergencyModel({
    required this.id,
    required this.name,
    required this.whatsapp,
  });

  factory EmergencyModel.fromJson(Map<String, dynamic> json) {
    return EmergencyModel(
      id: json['id'],
      name: json['name'],
      whatsapp: json['whatsapp'],
    );
  }
}
