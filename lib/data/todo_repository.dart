import 'package:hive_flutter/hive_flutter.dart';

import '../models/todo.dart';

const String kTodosBoxName = 'todos_box';

class TodoRepository {
  TodoRepository(this._box);

  static late final TodoRepository instance;

  static Future<void> init() async {
    final box = await Hive.openBox<Todo>(kTodosBoxName);
    instance = TodoRepository(box);
  }

  final Box<Todo> _box;

  List<Todo> loadTodos() {
    return _box.values.toList();
  }

  Future<void> insertOrUpdateTodo(Todo todo) async {
    await _box.put(todo.id, todo);
  }

  Future<void> deleteTodo(String id) async {
    await _box.delete(id);
  }
}
