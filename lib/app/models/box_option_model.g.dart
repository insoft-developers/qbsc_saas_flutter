// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'box_option_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BoxOptionModelAdapter extends TypeAdapter<BoxOptionModel> {
  @override
  final int typeId = 24;

  @override
  BoxOptionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BoxOptionModel(
      id: fields[0] as int,
      jenisBox: fields[1] as String,
      comid: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, BoxOptionModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.jenisBox)
      ..writeByte(2)
      ..write(obj.comid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoxOptionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
