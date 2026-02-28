part of 'todo.dart';

class TodoStatusAdapter extends TypeAdapter<TodoStatus> {
  @override
  final int typeId = 0;

  @override
  TodoStatus read(BinaryReader reader) {
    final value = reader.readByte();
    switch (value) {
      case 0:
        return TodoStatus.todo;
      case 1:
        return TodoStatus.inProgress;
      case 2:
        return TodoStatus.done;
      default:
        return TodoStatus.todo;
    }
  }

  @override
  void write(BinaryWriter writer, TodoStatus obj) {
    switch (obj) {
      case TodoStatus.todo:
        writer.writeByte(0);
        break;
      case TodoStatus.inProgress:
        writer.writeByte(1);
        break;
      case TodoStatus.done:
        writer.writeByte(2);
        break;
    }
  }
}

class TodoAdapter extends TypeAdapter<Todo> {
  @override
  final int typeId = 1;

  @override
  Todo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Todo(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      durationSeconds: fields[3] as int,
      elapsedSeconds: fields[4] as int,
      status: fields[5] as TodoStatus,
    );
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.durationSeconds)
      ..writeByte(4)
      ..write(obj.elapsedSeconds)
      ..writeByte(5)
      ..write(obj.status);
  }
}

