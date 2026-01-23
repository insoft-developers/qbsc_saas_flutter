// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_tracking_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfflineTrackingModelAdapter extends TypeAdapter<OfflineTrackingModel> {
  @override
  final int typeId = 22;

  @override
  OfflineTrackingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineTrackingModel(
      uuid: fields[0] as String,
      satpamId: fields[1] as int,
      latitude: fields[2] as double,
      longitude: fields[3] as double,
      accuracy: fields[4] as double,
      recordedAt: fields[5] as String,
      synced: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineTrackingModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.satpamId)
      ..writeByte(2)
      ..write(obj.latitude)
      ..writeByte(3)
      ..write(obj.longitude)
      ..writeByte(4)
      ..write(obj.accuracy)
      ..writeByte(5)
      ..write(obj.recordedAt)
      ..writeByte(6)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineTrackingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
