// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kandang_alarm_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KandangAlarmModelAdapter extends TypeAdapter<KandangAlarmModel> {
  @override
  final int typeId = 7;

  @override
  KandangAlarmModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KandangAlarmModel(
      id: fields[0] as int?,
      uuid: fields[1] as String,
      tanggal: fields[2] as String,
      jam: fields[3] as String,
      kandangId: fields[4] as int,
      satpamId: fields[5] as int,
      isAlarmOn: fields[6] as bool,
      note: fields[7] as String?,
      foto: fields[8] as String?,
      comid: fields[9] as int,
      latitude: fields[10] as double?,
      longitude: fields[11] as double?,
      isSynced: fields[12] as bool,
      syncedAt: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, KandangAlarmModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.uuid)
      ..writeByte(2)
      ..write(obj.tanggal)
      ..writeByte(3)
      ..write(obj.jam)
      ..writeByte(4)
      ..write(obj.kandangId)
      ..writeByte(5)
      ..write(obj.satpamId)
      ..writeByte(6)
      ..write(obj.isAlarmOn)
      ..writeByte(7)
      ..write(obj.note)
      ..writeByte(8)
      ..write(obj.foto)
      ..writeByte(9)
      ..write(obj.comid)
      ..writeByte(10)
      ..write(obj.latitude)
      ..writeByte(11)
      ..write(obj.longitude)
      ..writeByte(12)
      ..write(obj.isSynced)
      ..writeByte(13)
      ..write(obj.syncedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KandangAlarmModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
