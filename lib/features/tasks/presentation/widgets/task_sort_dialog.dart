import 'package:flutter/material.dart';

enum TaskSortOption {
  createdDate,
  dueDate,
  priority,
  title,
  status,
}

class TaskSortDialog extends StatelessWidget {
  final TaskSortOption currentSort;
  final bool ascending;
  final Function(TaskSortOption, bool) onSortChanged;

  const TaskSortDialog({
    super.key,
    required this.currentSort,
    required this.ascending,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sort Tasks'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...TaskSortOption.values.map((option) => RadioListTile<TaskSortOption>(
            title: Text(_getSortOptionText(option)),
            value: option,
            groupValue: currentSort,
            onChanged: (value) {
              if (value != null) {
                onSortChanged(value, ascending);
                Navigator.pop(context);
              }
            },
          )),
          const Divider(),
          SwitchListTile(
            title: const Text('Ascending Order'),
            value: ascending,
            onChanged: (value) {
              onSortChanged(currentSort, value);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  String _getSortOptionText(TaskSortOption option) {
    switch (option) {
      case TaskSortOption.createdDate:
        return 'Created Date';
      case TaskSortOption.dueDate:
        return 'Due Date';
      case TaskSortOption.priority:
        return 'Priority';
      case TaskSortOption.title:
        return 'Title';
      case TaskSortOption.status:
        return 'Status';
    }
  }
}