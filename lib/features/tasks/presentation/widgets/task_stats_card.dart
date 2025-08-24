import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';

class TaskStatsCard extends StatelessWidget {
  final List<TaskModel> tasks;

  const TaskStatsCard({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final todoCount = tasks.where((t) => t.taskStatus == TaskStatus.toDo).length;
    final inProgressCount = tasks.where((t) => t.taskStatus == TaskStatus.inProgress).length;
    final doneCount = tasks.where((t) => t.taskStatus == TaskStatus.done).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              label: 'To Do',
              count: todoCount,
              color: Colors.blue.shade600,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _StatItem(
              label: 'Progress',
              count: inProgressCount,
              color: Colors.orange.shade600,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _StatItem(
              label: 'Done',
              count: doneCount,
              color: Colors.green.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatItem({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}