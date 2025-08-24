import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../datasources/task_remote_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;
  final TaskRemoteDataSource remoteDataSource;
  final Connectivity connectivity;

  TaskRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
  });

  @override
  Future<Either<Failure, List<TaskModel>>> getTasks() async {
    try {
      // Always return local data first (offline-first)
      final localTasks = await localDataSource.getTasks();
      
      // Try to sync with remote if connected
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        try {
          final remoteTasks = await remoteDataSource.getTasks();
          // Update local cache with remote data
          for (final task in remoteTasks) {
            await localDataSource.updateTask(task);
          }
          return Right(remoteTasks);
        } catch (e) {
          // Return local data if remote fails
          return Right(localTasks);
        }
      }
      
      return Right(localTasks);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, TaskModel>> createTask(
    String title, 
    String? description, {
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
  }) async {
    try {
      final now = DateTime.now();
      final task = TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        status: (status ?? TaskStatus.toDo).index,
        priority: (priority ?? TaskPriority.medium).index,
        dueDate: dueDate,
        createdAt: now,
        updatedAt: now,
      );
      
      // Save locally first
      final createdTask = await localDataSource.createTask(task);
      
      // Try to sync with remote
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        try {
          await remoteDataSource.createTask(task);
        } catch (e) {
          // Continue with local task if remote fails
        }
      }
      
      return Right(createdTask);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, TaskModel>> updateTask(TaskModel task) async {
    try {
      // Update locally first
      final updatedTask = await localDataSource.updateTask(task);
      
      // Try to sync with remote
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        try {
          await remoteDataSource.updateTask(task);
        } catch (e) {
          // Continue with local update if remote fails
        }
      }
      
      return Right(updatedTask);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    try {
      // Delete locally first
      await localDataSource.deleteTask(id);
      
      // Try to sync with remote
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        try {
          await remoteDataSource.deleteTask(id);
        } catch (e) {
          // Continue with local deletion if remote fails
        }
      }
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<TaskModel>>> getTasksByStatus(TaskStatus status) async {
    try {
      final tasks = await localDataSource.getTasks();
      final filteredTasks = tasks
          .where((task) => task.status == status.index)
          .toList();
      return Right(filteredTasks);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}