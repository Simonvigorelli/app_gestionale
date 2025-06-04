// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cliente_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClienteModelAdapter extends TypeAdapter<ClienteModel> {
  @override
  final int typeId = 4;

  @override
  ClienteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClienteModel(
      nome: fields[0] as String,
      indirizzo: fields[1] as String,
      telefono: fields[2] as String,
      email: fields[3] as String,
      piva: fields[4] as String,
      codiceUnivoco: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ClienteModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.nome)
      ..writeByte(1)
      ..write(obj.indirizzo)
      ..writeByte(2)
      ..write(obj.telefono)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.piva)
      ..writeByte(5)
      ..write(obj.codiceUnivoco);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClienteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
