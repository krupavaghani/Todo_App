part of 'todo_bloc.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

class TodoLoaded extends TodoEvent {
  const TodoLoaded();
}

class TodoAddedOrUpdated extends TodoEvent {
  const TodoAddedOrUpdated({
    this.todo,
    required this.title,
    required this.description,
    required this.durationSeconds,
  });

  final Todo? todo;
  final String title;
  final String description;
  final int durationSeconds;

  @override
  List<Object?> get props => [todo, title, description, durationSeconds];
}

class TodoDeleted extends TodoEvent {
  const TodoDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class TodoStarted extends TodoEvent {
  const TodoStarted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class TodoPaused extends TodoEvent {
  const TodoPaused(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class TodoStopped extends TodoEvent {
  const TodoStopped(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class TodoTicked extends TodoEvent {
  const TodoTicked();
}
