import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/task_model.dart';
import '../repositories/task_repository.dart';

class UpdateTask {
  final TaskRepository repository;

  UpdateTask(this.repository);

  Future<Either<Failure, TaskModel>> call(TaskModel task) async {
    return await repository.updateTask(task);
  }
}