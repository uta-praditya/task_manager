import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/task_model.dart';
import '../repositories/task_repository.dart';

class CreateTask {
  final TaskRepository repository;

  CreateTask(this.repository);

  Future<Either<Failure, TaskModel>> call(
    String title, 
    String? description, {
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
  }) async {
    return await repository.createTask(
      title, 
      description, 
      status: status,
      priority: priority,
      dueDate: dueDate,
    );
  }
}