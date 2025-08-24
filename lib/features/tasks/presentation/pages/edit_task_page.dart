import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_event.dart';
import '../../data/models/task_model.dart';
import '../bloc/task_bloc.dart';

class EditTaskPage extends StatefulWidget {
  final TaskModel task;

  const EditTaskPage({super.key, required this.task});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late TaskStatus _selectedStatus;
  late TaskPriority _selectedPriority;
  late DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description ?? '');
    _selectedStatus = widget.task.taskStatus;
    _selectedPriority = widget.task.taskPriority;
    _selectedDueDate = widget.task.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Task Title',
                        prefixIcon: Icon(Icons.title),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a task title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<TaskStatus>(
                            value: _selectedStatus,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(),
                            ),
                            items: TaskStatus.values.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(_getStatusText(status)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<TaskPriority>(
                            value: _selectedPriority,
                            decoration: const InputDecoration(
                              labelText: 'Priority',
                              border: OutlineInputBorder(),
                            ),
                            items: TaskPriority.values.map((priority) {
                              return DropdownMenuItem(
                                value: priority,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.flag,
                                      size: 16,
                                      color: _getPriorityColor(priority),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(_getPriorityText(priority)),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPriority = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDueDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Due Date',
                          border: const OutlineInputBorder(),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_selectedDueDate != null)
                                IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _selectedDueDate = null;
                                    });
                                  },
                                ),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                        child: Text(
                          _selectedDueDate == null
                              ? 'No due date'
                              : '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: _saveTask,
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final updatedTask = TaskModel(
        id: widget.task.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        status: _selectedStatus.index,
        createdAt: widget.task.createdAt,
        updatedAt: DateTime.now(),
        priority: _selectedPriority.index,
        dueDate: _selectedDueDate,
      );
      
      context.read<TaskBloc>().add(UpdateTaskEvent(task: updatedTask));
      Navigator.pop(context);
    }
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.toDo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
    }
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }
}