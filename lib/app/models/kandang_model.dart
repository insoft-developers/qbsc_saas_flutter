import 'package:hive/hive.dart';

part 'kandang_model.g.dart';

@HiveType(typeId: 3)
class KandangModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String code;

  @HiveField(2)
  String name;

  @HiveField(3)
  double stdTemp;

  @HiveField(4)
  int fanAmount;

  @HiveField(5)
  bool isEmpty;

  @HiveField(6)
  int pic;

  @HiveField(7)
  int comid;

  KandangModel({
    required this.id,
    required this.code,
    required this.name,
    required this.stdTemp,
    required this.fanAmount,
    required this.isEmpty,
    required this.pic,
    required this.comid,
  });

  /// Convert JSON → Object
  factory KandangModel.fromJson(Map<String, dynamic> json) {
    return KandangModel(
      id: int.parse(json['id'].toString()),
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      stdTemp: double.parse(json['std_temp'].toString()),
      fanAmount: int.parse(json['fan_amount'].toString()),
      isEmpty: json['is_empty'].toString() == '1' ? true : false,
      pic: int.parse(json['pic'].toString()),
      comid: int.parse(json['comid'].toString()),
    );
  }

  /// Convert Object → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'std_temp': stdTemp,
      'fan_amount': fanAmount,
      'is_empty': isEmpty ? 1 : 0,
      'pic': pic,
      'comid': comid,
    };
  }
}
