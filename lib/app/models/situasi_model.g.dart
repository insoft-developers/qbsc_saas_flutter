// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'situasi_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SituasiModelAdapter extends TypeAdapter<SituasiModel> {
  @override
  final int typeId = 11;

  @override
  SituasiModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SituasiModel(
      id: fields[0] as String,
      satpamId: fields[1] as int,
      createdAt: fields[2] as String,
      laporan: fields[3] as String,
      foto: fields[4] as String?,
      comid: fields[5] as int,
      isSynced: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SituasiModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.satpamId)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.laporan)
      ..writeByte(4)
      ..write(obj.foto)
      ..writeByte(5)
      ..write(obj.comid)
      ..writeByte(6)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SituasiModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
