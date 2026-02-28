import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/todo_repository.dart';
import '../models/todo.dart';
import '../utils/id_generator.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository _repository;
  Timer? _timer;

  TodoBloc(this._repository) : super(const TodoState()) {
    on<TodoLoaded>(_onLoaded);
    on<TodoAddedOrUpdated>(_onAddedOrUpdated);
    on<TodoDeleted>(_onDeleted);
    on<TodoStarted>(_onStarted);
    on<TodoPaused>(_onPaused);
    on<TodoStopped>(_onStopped);
    on<TodoTicked>(_onTicked);
  }

  Future<void> _onLoaded(TodoLoaded event, Emitter<TodoState> emit) async {
    final todos = _repository.loadTodos();
    emit(TodoState(status: TodoStatusState.loaded, todos: todos));
    _ensureTimer();
  }

  Future<void> _onAddedOrUpdated(
    TodoAddedOrUpdated event,
    Emitter<TodoState> emit,
  ) async {
    Todo todoToSave;
    final existingIndex = state.todos.indexWhere(
      (element) => element.id == event.todo?.id,
    );

    if (event.todo == null) {
      todoToSave = Todo(
        id: generateId(),
        title: event.title,
        description: event.description,
        durationSeconds: event.durationSeconds,
      );
    } else {
      todoToSave = event.todo!.copyWith(
        title: event.title,
        description: event.description,
        durationSeconds: event.durationSeconds,
      );
    }

    await _repository.insertOrUpdateTodo(todoToSave);

    final updated = state.todos.toList();
    if (existingIndex == -1) {
      updated.add(todoToSave);
    } else {
      updated[existingIndex] = todoToSave;
    }
    emit(TodoState(status: state.status, todos: updated));
    _ensureTimer();
  }

  Future<void> _onDeleted(TodoDeleted event, Emitter<TodoState> emit) async {
    await _repository.deleteTodo(event.id);
    final updated = state.todos
        .where((element) => element.id != event.id)
        .toList();
    emit(TodoState(status: state.status, todos: updated));
    _ensureTimer();
  }

  Future<void> _onStarted(TodoStarted event, Emitter<TodoState> emit) async {
    final updated = state.todos.map((t) {
      if (t.id == event.id && !t.isCompleted && t.remainingSeconds > 0) {
        return t.copyWith(status: TodoStatus.inProgress);
      }
      return t;
    }).toList();

    for (final todo in updated) {
      await _repository.insertOrUpdateTodo(todo);
    }

    emit(TodoState(status: state.status, todos: updated));
    _ensureTimer();
  }

  Future<void> _onPaused(TodoPaused event, Emitter<TodoState> emit) async {
    final updated = state.todos.map((t) {
      if (t.id == event.id && t.status == TodoStatus.inProgress) {
        return t.copyWith(status: TodoStatus.todo);
      }
      return t;
    }).toList();

    for (final todo in updated) {
      await _repository.insertOrUpdateTodo(todo);
    }

    emit(TodoState(status: state.status, todos: updated));
    _ensureTimer();
  }

  Future<void> _onStopped(TodoStopped event, Emitter<TodoState> emit) async {
    final updated = state.todos.map((t) {
      if (t.id == event.id) {
        return t.copyWith(
          status: TodoStatus.done,
          elapsedSeconds: t.durationSeconds,
        );
      }
      return t;
    }).toList();

    for (final todo in updated) {
      await _repository.insertOrUpdateTodo(todo);
    }

    emit(TodoState(status: state.status, todos: updated));
    _ensureTimer();
  }

  Future<void> _onTicked(TodoTicked event, Emitter<TodoState> emit) async {
    final updated = state.todos.map((t) {
      if (t.status != TodoStatus.inProgress || t.remainingSeconds == 0) {
        return t;
      }

      final int newElapsedSeconds = t.elapsedSeconds + 1;
      final bool isCompleted = newElapsedSeconds > t.durationSeconds;

      return Todo(
        id: t.id,
        title: t.title,
        description: t.description,
        durationSeconds: t.durationSeconds,
        elapsedSeconds: isCompleted ? t.durationSeconds : newElapsedSeconds,
        status: isCompleted ? TodoStatus.done : t.status,
      );
    }).toList();

    for (final todo in updated) {
      await _repository.insertOrUpdateTodo(todo);
    }

    emit(TodoState(status: state.status, todos: updated));

    final hasRunning = updated.any((t) => t.isRunning);
    if (!hasRunning) {
      _cancelTimer();
    }
  }

  void _ensureTimer() {
    final hasRunning = state.todos.any((t) => t.isRunning);
    if (hasRunning && _timer == null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        add(const TodoTicked());
      });
    } else if (!hasRunning) {
      _cancelTimer();
    }
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}
