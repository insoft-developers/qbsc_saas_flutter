import 'package:hive/hive.dart';

part 'location_model.g.dart';

@HiveType(typeId: 1)
class LocationModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String qrcode;

  @HiveField(2)
  final String namaLokasi;

  @HiveField(3)
  final double latitude;

  @HiveField(4)
  final double longitude;

  @HiveField(5)
  final int isActive;

  @HiveField(6)
  final int comid;

  LocationModel({
    required this.id,
    required this.qrcode,
    required this.namaLokasi,
    required this.latitude,
    required this.longitude,
    required this.isActive,
    required this.comid,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
    id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
    qrcode: json['qrcode']?.toString() ?? '',
    namaLokasi: json['nama_lokasi']?.toString() ?? '',
    latitude:
        (json['latitude'] == null || json['latitude'].toString() == 'null')
        ? 0.0
        : double.tryParse(json['latitude'].toString()) ?? 0.0,
    longitude:
        (json['longitude'] == null || json['longitude'].toString() == 'null')
        ? 0.0
        : double.tryParse(json['longitude'].toString()) ?? 0.0,
    isActive: json['is_active'] is int
        ? json['is_active']
        : int.tryParse(json['is_active'].toString()) ?? 0,
    comid: json['comid'] is int
        ? json['comid']
        : int.tryParse(json['comid'].toString()) ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'qrcode': qrcode,
    'nama_lokasi': namaLokasi,
    'latitude': latitude.isNaN ? 0.0 : latitude,
    'longitude': longitude.isNaN ? 0.0 : longitude,
    'is_active': isActive,
    'comid': comid,
  };
}
