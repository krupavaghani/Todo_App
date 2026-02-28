part of 'todo_bloc.dart';

enum TodoStatusState { initial, loaded }

class TodoState extends Equatable {
  final TodoStatusState status;
  final List<Todo> todos;

  const TodoState({
    this.status = TodoStatusState.initial,
    this.todos = const [],
  });

  @override
  List<Object?> get props => [status, todos];
}
