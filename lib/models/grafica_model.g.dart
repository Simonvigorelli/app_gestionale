// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grafica_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GraficaModelAdapter extends TypeAdapter<GraficaModel> {
  @override
  final int typeId = 6;

  @override
  GraficaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GraficaModel(
      codice: fields[0] as String,
      descrizione: fields[1] as String,
      prezzo: fields[2] as double,
      tipoPrezzo: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, GraficaModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.codice)
      ..writeByte(1)
      ..write(obj.descrizione)
      ..writeByte(2)
      ..write(obj.prezzo)
      ..writeByte(3)
      ..write(obj.tipoPrezzo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraficaModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
