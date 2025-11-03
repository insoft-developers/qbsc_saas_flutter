import 'package:hive/hive.dart';

part 'patroli_model.g.dart'; // untuk generate adapter

@HiveType(typeId: 2) // pastikan unik dari model lain
class PatroliModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String tanggal;

  @HiveField(2)
  String jam;

  @HiveField(3)
  String locationId;

  @HiveField(4)
  String locationCode;

  @HiveField(5)
  String satpamId;

  @HiveField(6)
  double latitude;

  @HiveField(7)
  double longitude;

  @HiveField(8)
  String note;

  @HiveField(9)
  String comid;

  // Tambahan untuk sinkronisasi
  @HiveField(10)
  bool isSynced;

  @HiveField(11)
  String? syncedAt;

  PatroliModel({
    required this.id,
    required this.tanggal,
    required this.jam,
    required this.locationId,
    required this.locationCode,
    required this.satpamId,
    required this.latitude,
    required this.longitude,
    required this.note,
    required this.comid,
    this.isSynced = false,
    this.syncedAt,
  });

  /// Konversi ke JSON untuk dikirim ke API server
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tanggal': tanggal,
      'jam': jam,
      'location_id': locationId,
      'location_code': locationCode,
      'satpam_id': satpamId,
      'latitude': latitude,
      'longitude': longitude,
      'note': note,
      'comid': comid,
    };
  }

  /// Buat instance dari JSON (misal kalau download dari server)
  factory PatroliModel.fromJson(Map<String, dynamic> json) {
    return PatroliModel(
      id: json['id'] ?? '',
      tanggal: json['tanggal'] ?? '',
      jam: json['jam'] ?? '',
      locationId: json['location_id']?.toString() ?? '',
      locationCode: json['location_code']?.toString() ?? '',
      satpamId: json['satpam_id']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      note: json['note'] ?? '',
      comid: json['comid'] ?? '',
      isSynced: json['isSynced'] ?? true,
      syncedAt: json['syncedAt']?.toString(),
    );
  }

  /// Copy dengan perubahan field tertentu (berguna saat update sync)
  PatroliModel copyWith({bool? isSynced, String? syncedAt}) {
    return PatroliModel(
      id: id,
      tanggal: tanggal,
      jam: jam,
      locationId: locationId,
      locationCode: locationCode,
      satpamId: satpamId,
      latitude: latitude,
      longitude: longitude,
      note: note,
      comid: comid,
      isSynced: isSynced ?? this.isSynced,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}
