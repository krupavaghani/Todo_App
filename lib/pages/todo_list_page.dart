import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/todo_bloc.dart';
import '../models/todo.dart';
import '../widgets/todo_form_bottom_sheet.dart';
import '../widgets/todo_list_item.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<TodoBloc>().add(const TodoLoaded());
  }

 

  @override
  Widget build(BuildContext context) {
    final name = context.watch<AuthBloc>().state.userName;
    final title = name != null && name.isNotEmpty
        ? '$name TODOs'
        : 'My TODOs';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search by title',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<TodoBloc, TodoState>(
              builder: (context, state) {
                final todos = state.todos.where((t) {
                  if (_searchQuery.isEmpty) return true;
                  return t.title.toLowerCase().contains(_searchQuery);
                }).toList();

                if (todos.isEmpty) {
                  return const Center(
                    child: Text(
                      'No todos yet.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return TodoListItem(
                      todo: todo,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/details',
                          arguments: todo.id,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add,color: Colors.white,),
      ),
    );
  }

   void _openForm({Todo? todo}) {
    showModalBottomSheet(
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

