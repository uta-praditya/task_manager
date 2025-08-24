import 'package:equatable/equatable.dart';
import '../../data/models/task_model.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasksEvent extends TaskEvent {}

class CreateTaskEvent extends TaskEvent {
  final String title;
  final String? description;
  final TaskStatus? status;
  final TaskPriority? priority;
  final DateTime? dueDate;

  const CreateTaskEvent({
    required this.title,
    this.description,
    this.status,
    this.priority,
    this.dueDate,
  });

  @override
  List<Object?> get props => [title, description, status, priority, dueDate];
}

class UpdateTaskEvent extends TaskEvent {
  final TaskModel task;

  const UpdateTaskEvent({required this.task});

  @override
  List<Object?> get props => [task];
}

class DeleteTaskEvent extends TaskEvent {
  final String taskId;

  const DeleteTaskEvent({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}