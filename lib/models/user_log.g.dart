// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserLogAdapter extends TypeAdapter<UserLog> {
  @override
  final int typeId = 0;

  @override
  UserLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserLog(
      userId: fields[0] as String,
      eventType: fields[1] as String,
      details: Map<String, dynamic>.from(fields[2] as Map),
      timestamp: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserLog obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.eventType)
      ..writeByte(2)
      ..write(obj.details)
      ..writeByte(3)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
