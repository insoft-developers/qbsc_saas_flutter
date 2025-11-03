// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patroli_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PatroliModelAdapter extends TypeAdapter<PatroliModel> {
  @override
  final int typeId = 2;

  @override
  PatroliModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PatroliModel(
      id: fields[0] as String,
      tanggal: fields[1] as String,
      jam: fields[2] as String,
      locationId: fields[3] as String,
      locationCode: fields[4] as String,
      satpamId: fields[5] as String,
      latitude: fields[6] as double,
      longitude: fields[7] as double,
      note: fields[8] as String,
      comid: fields[9] as String,
      isSynced: fields[10] as bool,
      syncedAt: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PatroliModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tanggal)
      ..writeByte(2)
      ..write(obj.jam)
      ..writeByte(3)
      ..write(obj.locationId)
      ..writeByte(4)
      ..write(obj.locationCode)
      ..writeByte(5)
      ..write(obj.satpamId)
      ..writeByte(6)
      ..write(obj.latitude)
      ..writeByte(7)
      ..write(obj.longitude)
      ..writeByte(8)
      ..write(obj.note)
      ..writeByte(9)
      ..write(obj.comid)
      ..writeByte(10)
      ..write(obj.isSynced)
      ..writeByte(11)
      ..write(obj.syncedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatroliModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
