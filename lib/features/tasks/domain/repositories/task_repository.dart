import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/task_model.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<TaskModel>>> getTasks();
  Future<Either<Failure, TaskModel>> createTask(
    String title, 
    String? description, {
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
  });
  Future<Either<Failure, TaskModel>> updateTask(TaskModel task);
  Future<Either<Failure, void>> deleteTask(String id);
  Future<Either<Failure, List<TaskModel>>> getTasksByStatus(TaskStatus status);
}