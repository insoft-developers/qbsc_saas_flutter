// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kandang_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KandangModelAdapter extends TypeAdapter<KandangModel> {
  @override
  final int typeId = 3;

  @override
  KandangModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KandangModel(
      id: fields[0] as int,
      code: fields[1] as String,
      name: fields[2] as String,
      stdTemp: fields[3] as double,
      fanAmount: fields[4] as int,
      isEmpty: fields[5] as bool,
      pic: fields[6] as int,
      comid: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, KandangModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.code)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.stdTemp)
      ..writeByte(4)
      ..write(obj.fanAmount)
      ..writeByte(5)
      ..write(obj.isEmpty)
      ..writeByte(6)
      ..write(obj.pic)
      ..writeByte(7)
      ..write(obj.comid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KandangModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
