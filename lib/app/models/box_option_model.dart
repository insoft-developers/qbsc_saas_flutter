import 'package:hive/hive.dart';

part 'box_option_model.g.dart';

@HiveType(typeId: 24)
class BoxOptionModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String jenisBox;

  @HiveField(2)
  int comid;

  BoxOptionModel({
    required this.id,
    required this.jenisBox,
    required this.comid,
  });

  factory BoxOptionModel.fromJson(Map<String, dynamic> json) {
    return BoxOptionModel(
      id: json['id'],
      jenisBox: json['jenis_box'],
      comid: json['comid'],
    );
  }
}
