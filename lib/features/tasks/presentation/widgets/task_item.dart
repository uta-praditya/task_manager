import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_event.dart';
import '../../data/models/task_model.dart';
import '../pages/edit_task_page.dart';
import '../bloc/task_bloc.dart';
import 'priority_indicator.dart';

class TaskItem extends StatelessWidget {
  final TaskModel task;

  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      dismissThresholds: const {DismissDirection.endToStart: 0.4},
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade400, Colors.red.shade600],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 28,
            ),
             SizedBox(height: 4),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Delete Task'),
              content: Text('Are you sure you want to delete "${task.title}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ?? false;
      },
      onDismissed: (direction) {
        context.read<TaskBloc>().add(DeleteTaskEvent(taskId: task.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${task.title}" deleted')),
        );
      },
      child: Card(
        elevation: task.isOverdue ? 8 : 4,
        shadowColor: task.isOverdue 
            ? Colors.red.withValues(alpha: 0.3)
            : Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: task.isOverdue 
              ? BorderSide(color: Colors.red.shade300, width: 1)
              : task.isDueSoon
                  ? BorderSide(color: Colors.orange.shade300, width: 1)
                  : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToEditTask(context),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: task.taskStatus == TaskStatus.done
                  ? LinearGradient(
                      colors: [
                        Colors.green.shade50,
                        Colors.green.shade100.withValues(alpha: 0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _getPriorityColor(task.taskPriority),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                PriorityIndicator(priority: task.taskPriority),
                                const SizedBox(width: 8),
                                if (task.isOverdue)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'OVERDUE',
                                      style: TextStyle(
                                        color: Colors.red.shade800,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                if (task.isDueSoon && !task.isOverdue)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'DUE SOON',
                                      style: TextStyle(
                                        color: Colors.orange.shade800,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              task.title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                decoration: task.taskStatus == TaskStatus.done 
                                    ? TextDecoration.lineThrough 
                                    : null,
                                color: task.taskStatus == TaskStatus.done
                                    ? Theme.of(context).colorScheme.outline
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(task.taskStatus),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusTextColor(task.taskStatus).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          _getStatusText(task.taskStatus),
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: _getStatusTextColor(task.taskStatus),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (task.description != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        task.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule_outlined,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Created ${_formatDate(task.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (task.dueDate != null) ...[
                          const SizedBox(width: 16),
                          Icon(
                            Icons.event_outlined,
                            size: 16,
                            color: task.isOverdue 
                                ? Colors.red 
                                : task.isDueSoon 
                                    ? Colors.orange 
                                    : Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Due ${_formatDueDate(task.dueDate!)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: task.isOverdue 
                                  ? Colors.red 
                                  : task.isDueSoon 
                                      ? Colors.orange 
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const Spacer(),
                        PopupMenuButton(
                          icon: Icon(
                            Icons.more_vert,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          itemBuilder: (context) => [
                           const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18),
                                   SizedBox(width: 12),
                                   Text('Edit Task'),
                                ],
                              ),
                            ),
                           const  PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                   SizedBox(width: 12),
                                  Text('Delete Task', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _navigateToEditTask(context);
                            } else if (value == 'delete') {
                              _showDeleteDialog(context);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
        return Colors.blue.shade50;
      case TaskStatus.inProgress:
        return Colors.orange.shade50;
      case TaskStatus.done:
        return Colors.green.shade50;
    }
  }

  Color _getStatusTextColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.toDo:
        return Colors.blue.shade800;
      case TaskStatus.inProgress:
        return Colors.orange.shade800;
      case TaskStatus.done:
        return Colors.green.shade800;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green.shade400;
      case TaskPriority.medium:
        return Colors.orange.shade400;
      case TaskPriority.high:
        return Colors.red.shade400;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    
    if (difference.inDays < 0) {
      return '${difference.inDays.abs()} days ago';
    } else if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'tomorrow';
    } else if (difference.inDays < 7) {
      return 'in ${difference.inDays} days';
    } else {
      return '${dueDate.day}/${dueDate.month}/${dueDate.year}';
    }
  }

  void _navigateToEditTask(BuildContext context) {
    final taskBloc = context.read<TaskBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: taskBloc,
          child: EditTaskPage(task: task),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: Text('Are you sure you want to delete "${task.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<TaskBloc>().add(DeleteTaskEvent(taskId: task.id));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${task.title}" deleted')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}