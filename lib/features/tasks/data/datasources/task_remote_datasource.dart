import 'package:dio/dio.dart';
import '../models/task_model.dart';
import '../../../../core/storage/token_storage.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks();
  Future<TaskModel> createTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio dio;

  TaskRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<TaskModel>> getTasks() async {
    final token = await TokenStorage.getToken();
    final response = await dio.get('/tasks', 
      options: Options(headers: {'Authorization': 'Bearer $token'}));
    return (response.data as List)
        .map((json) => TaskModel.fromJson(json))
        .toList();
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    final token = await TokenStorage.getToken();
    final response = await dio.post('/tasks', 
      data: {
        'title': task.title,
        'description': task.description,
        'status': task.status,
        'priority': task.priority,
        'dueDate': task.dueDate?.toIso8601String(),
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}));
    return TaskModel.fromJson(response.data);
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    final token = await TokenStorage.getToken();
    final response = await dio.put('/tasks/${task.id}', 
      data: {
        'title': task.title,
        'description': task.description,
        'status': task.status,
        'priority': task.priority,
        'dueDate': task.dueDate?.toIso8601String(),
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}));
    return TaskModel.fromJson(response.data);
  }

  @override
  Future<void> deleteTask(String id) async {
    final token = await TokenStorage.getToken();
    await dio.delete('/tasks/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}));
  }
}