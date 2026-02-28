import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/todo_bloc.dart';
import '../models/todo.dart';
import '../utils/time_format.dart';
import '../widgets/todo_form_bottom_sheet.dart';

class TodoDetailsPage extends StatelessWidget {
  const TodoDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final todoId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: const Text('Todo Details')),
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          final todo = state.todos.firstWhere(
            (t) => t.id == todoId,
            orElse: () => Todo(
              id: '',
              title: 'Not found',
              description: '',
              durationSeconds: 0,
            ),
          );

          if (todo.id.isEmpty) {
            return const Center(child: Text('Todo not found'));
          }

          final isRunning = todo.isRunning;
          final isDone = todo.isCompleted;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        todo.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _openEditForm(context, todo),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  todo.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Text(
                  'Status:  ${todo.status.name.toUpperCase()}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Timer',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${formatDuration(todo.elapsedSeconds)} / ${formatDuration(todo.durationSeconds)}',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: Colors.brown),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: isDone
                          ? null
                          : () => context.read<TodoBloc>().add(
                              TodoStarted(todo.id),
                            ),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Play'),
                    ),
                    ElevatedButton.icon(
                      onPressed: isRunning
                          ? () => context.read<TodoBloc>().add(
                              TodoPaused(todo.id),
                            )
                          : null,
                      icon: const Icon(Icons.pause),
                      label: const Text('Pause'),
                    ),
                    ElevatedButton.icon(
                      onPressed: isDone
                          ? null
                          : () => context.read<TodoBloc>().add(
                              TodoStopped(todo.id),
                            ),
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openEditForm(BuildContext context, Todo todo) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return TodoFormBottomSheet(
          initialTodo: todo,
          onSubmit: (data) {
            final event = TodoAddedOrUpdated(
              todo: todo,
              title: data.title,
              description: data.description,
              durationSeconds: data.durationSeconds,
            );
            context.read<TodoBloc>().add(event);
          },
        );
      },
    );
  }
}
