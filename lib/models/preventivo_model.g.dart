// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preventivo_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PreventivoModelAdapter extends TypeAdapter<PreventivoModel> {
  @override
  final int typeId = 3;

  @override
  PreventivoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PreventivoModel(
      id: fields[0] as String,
      numero: fields[1] as int,
      data: fields[2] as String,
      azienda: fields[3] as AziendaModel,
      cliente: fields[4] as ClienteModel,
      nomeStand: fields[5] as String,
      dimensioneStand: fields[6] as double,
      nomeManifestazione: fields[7] as String,
      dataManifestazione: fields[8] as String,
      cittaManifestazione: fields[9] as String,
      estero: fields[10] as bool,
      prodotti: (fields[11] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      servizi: (fields[12] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      iva: fields[13] as double,
      rincaro: fields[14] as double,
      acconto: fields[15] as double,
      sconto: fields[16] as double,
      totale: fields[17] as double,
    );
  }

  @override
  void write(BinaryWriter writer, PreventivoModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.numero)
      ..writeByte(2)
      ..write(obj.data)
      ..writeByte(3)
      ..write(obj.azienda)
      ..writeByte(4)
      ..write(obj.cliente)
      ..writeByte(5)
      ..write(obj.nomeStand)
      ..writeByte(6)
      ..write(obj.dimensioneStand)
      ..writeByte(7)
      ..write(obj.nomeManifestazione)
      ..writeByte(8)
      ..write(obj.dataManifestazione)
      ..writeByte(9)
      ..write(obj.cittaManifestazione)
      ..writeByte(10)
      ..write(obj.estero)
      ..writeByte(11)
      ..write(obj.prodotti)
      ..writeByte(12)
      ..write(obj.servizi)
      ..writeByte(13)
      ..write(obj.iva)
      ..writeByte(14)
      ..write(obj.rincaro)
      ..writeByte(15)
      ..write(obj.acconto)
      ..writeByte(16)
      ..write(obj.sconto)
      ..writeByte(17)
      ..write(obj.totale);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreventivoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
