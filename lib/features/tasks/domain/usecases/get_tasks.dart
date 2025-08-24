import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/task_model.dart';
import '../repositories/task_repository.dart';

class GetTasks {
  final TaskRepository repository;

  GetTasks(this.repository);

  Future<Either<Failure, List<TaskModel>>> call() async {
    return await repository.getTasks();
  }
}