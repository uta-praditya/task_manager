import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';

class TaskFilterChip extends StatelessWidget {
  final TaskStatus? selectedStatus;
  final Function(TaskStatus?) onStatusChanged;

  const TaskFilterChip({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: selectedStatus == null,
            onSelected: (selected) => onStatusChanged(null),
          ),
          const SizedBox(width: 8),
          ...TaskStatus.values.map((status) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_getStatusText(status)),
              selected: selectedStatus == status,
              onSelected: (selected) => onStatusChanged(selected ? status : null),
              avatar: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          )),
        ],
      ),
    );
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

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.toDo:
        return Colors.blue;
      case TaskStatus.inProgress:
        return Colors.orange;
      case TaskStatus.done:
        return Colors.green;
    }
  }
}