// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ekspedisi_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EkspedisiModelAdapter extends TypeAdapter<EkspedisiModel> {
  @override
  final int typeId = 9;

  @override
  EkspedisiModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EkspedisiModel(
      id: fields[0] as int,
      code: fields[1] as String,
      name: fields[2] as String,
      comid: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, EkspedisiModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.code)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.comid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EkspedisiModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
