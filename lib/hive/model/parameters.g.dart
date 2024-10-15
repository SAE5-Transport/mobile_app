// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parameters.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ParametersAdapter extends TypeAdapter<Parameters> {
  @override
  final int typeId = 1;

  @override
  Parameters read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Parameters(
      name: fields[0] as String,
      themeId: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Parameters obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.themeId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParametersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
