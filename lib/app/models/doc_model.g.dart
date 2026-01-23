// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doc_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DocModelAdapter extends TypeAdapter<DocModel> {
  @override
  final int typeId = 10;

  @override
  DocModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DocModel(
      id: fields[0] as String,
      tanggal: fields[1] as String,
      jam: fields[2] as String,
      satpamId: fields[3] as int,
      jumlah: fields[4] as int,
      ekspedisiId: fields[5] as int,
      tujuan: fields[6] as String?,
      noPolisi: fields[7] as String?,
      jenis: fields[8] as int,
      note: fields[9] as String?,
      foto: (fields[10] as List?)?.cast<String>(),
      docBoxOptionJson: fields[11] as String?,
      namaSupir: fields[12] as String,
      nomorSegel: fields[13] as String,
      totalEkor: fields[14] as int,
      comid: fields[15] as int,
      createdAt: fields[16] as String,
      isSynced: fields[17] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DocModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tanggal)
      ..writeByte(2)
      ..write(obj.jam)
      ..writeByte(3)
      ..write(obj.satpamId)
      ..writeByte(4)
      ..write(obj.jumlah)
      ..writeByte(5)
      ..write(obj.ekspedisiId)
      ..writeByte(6)
      ..write(obj.tujuan)
      ..writeByte(7)
      ..write(obj.noPolisi)
      ..writeByte(8)
      ..write(obj.jenis)
      ..writeByte(9)
      ..write(obj.note)
      ..writeByte(10)
      ..write(obj.foto)
      ..writeByte(11)
      ..write(obj.docBoxOptionJson)
      ..writeByte(12)
      ..write(obj.namaSupir)
      ..writeByte(13)
      ..write(obj.nomorSegel)
      ..writeByte(14)
      ..write(obj.totalEkor)
      ..writeByte(15)
      ..write(obj.comid)
      ..writeByte(16)
      ..write(obj.createdAt)
      ..writeByte(17)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
