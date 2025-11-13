// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kandang_suhu_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KandangSuhuModelAdapter extends TypeAdapter<KandangSuhuModel> {
  @override
  final int typeId = 5;

  @override
  KandangSuhuModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KandangSuhuModel(
      id: fields[0] as int?,
      uuid: fields[1] as String,
      tanggal: fields[2] as String,
      jam: fields[3] as String,
      kandangId: fields[4] as int,
      satpamId: fields[5] as int,
      stdTemp: fields[6] as double?,
      temperature: fields[7] as double?,
      note: fields[8] as String?,
      foto: fields[9] as String?,
      comid: fields[10] as int,
      latitude: fields[11] as double?,
      longitude: fields[12] as double?,
      isSynced: fields[13] as bool,
      syncedAt: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, KandangSuhuModel obj) {
    writer
      ..writeByte(15)
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
      ..write(obj.stdTemp)
      ..writeByte(7)
      ..write(obj.temperature)
      ..writeByte(8)
      ..write(obj.note)
      ..writeByte(9)
      ..write(obj.foto)
      ..writeByte(10)
      ..write(obj.comid)
      ..writeByte(11)
      ..write(obj.latitude)
      ..writeByte(12)
      ..write(obj.longitude)
      ..writeByte(13)
      ..write(obj.isSynced)
      ..writeByte(14)
      ..write(obj.syncedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KandangSuhuModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
