// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'azienda_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AziendaModelAdapter extends TypeAdapter<AziendaModel> {
  @override
  final int typeId = 5;

  @override
  AziendaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AziendaModel(
      nome: fields[0] as String,
      indirizzo: fields[1] as String,
      telefono: fields[2] as String,
      email: fields[3] as String,
      piva: fields[4] as String,
      iban: fields[5] as String,
      codiceUnivoco: fields[6] as String,
      logoPath: fields[7] as String,
      firmaPath: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AziendaModel obj) {
    writer
      ..writeByte(9)
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
      ..write(obj.iban)
      ..writeByte(6)
      ..write(obj.codiceUnivoco)
      ..writeByte(7)
      ..write(obj.logoPath)
      ..writeByte(8)
      ..write(obj.firmaPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AziendaModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
