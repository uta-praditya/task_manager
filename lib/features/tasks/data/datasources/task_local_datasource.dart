import 'package:hive/hive.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<TaskModel> createTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final Box<TaskModel> taskBox;

  TaskLocalDataSourceImpl({required this.taskBox});

  @override
  Future<List<TaskModel>> getTasks() async {
    return taskBox.values.toList();
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    await taskBox.put(task.id, task);
    return task;
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    await taskBox.put(task.id, task);
    return task;
  }

  @override
  Future<void> deleteTask(String id) async {
    await taskBox.delete(id);
  }
}