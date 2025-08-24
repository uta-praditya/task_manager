import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';

class PriorityIndicator extends StatelessWidget {
  final TaskPriority priority;
  final bool showLabel;

  const PriorityIndicator({
    super.key,
    required this.priority,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.flag,
          size: 16,
          color: _getPriorityColor(priority),
        ),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            _getPriorityText(priority),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _getPriorityColor(priority),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
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
}