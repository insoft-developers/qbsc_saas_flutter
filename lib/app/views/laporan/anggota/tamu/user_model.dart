class UserModel {
  final int id;
  final String name;

  UserModel({required this.id, required this.name});

  /// ======================
  /// FROM JSON
  /// ======================
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}
