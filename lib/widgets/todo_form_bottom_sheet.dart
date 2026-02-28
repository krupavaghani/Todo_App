import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../utils/time_format.dart';

class TodoFormData {
  final String title;
  final String description;
  final int durationSeconds;

  TodoFormData({
    required this.title,
    required this.description,
    required this.durationSeconds,
  });
}

class TodoFormBottomSheet extends StatefulWidget {
  final Todo? initialTodo;
  final void Function(TodoFormData data) onSubmit;

  const TodoFormBottomSheet({
    super.key,
    this.initialTodo,
    required this.onSubmit,
  });

  @override
  State<TodoFormBottomSheet> createState() => _TodoFormBottomSheetState();
}

class _TodoFormBottomSheetState extends State<TodoFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _minutesController;
  late final TextEditingController _secondsController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTodo?.title);
    _descriptionController = TextEditingController(
      text: widget.initialTodo?.description,
    );

    final totalSeconds = widget.initialTodo?.durationSeconds ?? 60;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    _minutesController = TextEditingController(
      text: minutes > 0 ? minutes.toString() : '',
    );
    _secondsController = TextEditingController(
      text: seconds > 0 ? seconds.toString() : '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

 

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialTodo != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit TODO' : 'New TODO',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Time (max ${formatDuration(kMaxTodoDurationSeconds)})',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minutesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Minutes',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateTime,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _secondsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Seconds',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _submit,
                    child: Text(
                      'Save',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateTime(String? val) {
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final seconds = int.tryParse(_secondsController.text) ?? 0;
    final totalSeconds = (minutes * 60) + seconds;
    if (totalSeconds <= 0) {
      return 'Please set a timer > 0 seconds';
    }
    if (totalSeconds > kMaxTodoDurationSeconds) {
      return 'Max allowed time is ${formatDuration(kMaxTodoDurationSeconds)}';
    }
    return null;
  }

   void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final seconds = int.tryParse(_secondsController.text) ?? 0;
    final totalSeconds = (minutes * 60) + seconds;

    widget.onSubmit(
      TodoFormData(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        durationSeconds: totalSeconds,
      ),
    );
    Navigator.of(context).pop();
  }
}
