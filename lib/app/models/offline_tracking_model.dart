import 'package:hive/hive.dart';

part 'offline_tracking_model.g.dart';

@HiveType(typeId: 22)
class OfflineTrackingModel extends HiveObject {
  @HiveField(0)
  String uuid;

  @HiveField(1)
  int satpamId;

  @HiveField(2)
  double latitude;

  @HiveField(3)
  double longitude;

  @HiveField(4)
  double accuracy;

  @HiveField(5)
  String recordedAt;

  @HiveField(6)
  bool synced;

  OfflineTrackingModel({
    required this.uuid,
    required this.satpamId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.recordedAt,
    this.synced = false,
  });

  factory OfflineTrackingModel.fromJson(Map<String, dynamic> json) {
    return OfflineTrackingModel(
      uuid: json['uuid'],
      satpamId: json['satpam_id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      accuracy: json['accuracy'],
      recordedAt: json['recorded_at'],
      synced: json['synced'] ?? false,
    );
  }
}
