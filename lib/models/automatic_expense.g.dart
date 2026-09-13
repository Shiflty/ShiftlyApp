// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'automatic_expense.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AutomaticExpenseAdapter extends TypeAdapter<AutomaticExpense> {
  @override
  final int typeId = 5;

  @override
  AutomaticExpense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AutomaticExpense(
      description: fields[0] as String,
      amount: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, AutomaticExpense obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.description)
      ..writeByte(1)
      ..write(obj.amount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutomaticExpenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
