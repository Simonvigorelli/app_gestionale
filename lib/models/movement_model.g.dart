// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movement_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovementModelAdapter extends TypeAdapter<MovementModel> {
  @override
  final int typeId = 2;

  @override
  MovementModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MovementModel(
      id: fields[0] as String,
      productCode: fields[1] as String,
      productDescription: fields[2] as String,
      manifestation: fields[3] as String,
      stand: fields[4] as String?,
      quantity: fields[5] as int,
      dateOut: fields[6] as DateTime,
      dateIn: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, MovementModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productCode)
      ..writeByte(2)
      ..write(obj.productDescription)
      ..writeByte(3)
      ..write(obj.manifestation)
      ..writeByte(4)
      ..write(obj.stand)
      ..writeByte(5)
      ..write(obj.quantity)
      ..writeByte(6)
      ..write(obj.dateOut)
      ..writeByte(7)
      ..write(obj.dateIn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovementModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
