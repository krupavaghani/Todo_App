import 'package:hive_flutter/hive_flutter.dart';

part 'todo.g.dart';

const int kMaxTodoDurationSeconds = 5 * 60;

@HiveType(typeId: 0)
enum TodoStatus {
  @HiveField(0)
  todo,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  done,
}

@HiveType(typeId: 1)
class Todo extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  int durationSeconds;

  @HiveField(4)
  int elapsedSeconds;

  @HiveField(5)
  TodoStatus status;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.durationSeconds,
    this.elapsedSeconds = 0,
    this.status = TodoStatus.todo,
  });

  bool get isCompleted => status == TodoStatus.done;

  bool get isRunning => status == TodoStatus.inProgress && remainingSeconds > 0;

  int get remainingSeconds =>
      (durationSeconds - elapsedSeconds).clamp(0, durationSeconds);

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    int? durationSeconds,
    int? elapsedSeconds,
    TodoStatus? status,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      status: status ?? this.status,
    );
  }
}
