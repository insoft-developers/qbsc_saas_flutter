// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jadwal_patroli_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JadwalPatroliModelAdapter extends TypeAdapter<JadwalPatroliModel> {
  @override
  final int typeId = 21;

  @override
  JadwalPatroliModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JadwalPatroliModel(
      id: fields[0] as int,
      patroliId: fields[1] as int,
      locationId: fields[2] as int,
      urutan: fields[3] as int,
      jamAwal: fields[4] as String,
      jamAkhir: fields[5] as String,
      comid: fields[6] as int,
      isChecked: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, JadwalPatroliModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.patroliId)
      ..writeByte(2)
      ..write(obj.locationId)
      ..writeByte(3)
      ..write(obj.urutan)
      ..writeByte(4)
      ..write(obj.jamAwal)
      ..writeByte(5)
      ..write(obj.jamAkhir)
      ..writeByte(6)
      ..write(obj.comid)
      ..writeByte(7)
      ..write(obj.isChecked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JadwalPatroliModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
