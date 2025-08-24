import 'package:flutter/foundation.dart';
import 'package:task_manager/features/tasks/data/models/task_model.dart';
import 'lib/core/network/http_client.dart';
import 'lib/features/auth/data/datasources/auth_remote_datasource.dart';
import 'lib/features/tasks/data/datasources/task_remote_datasource.dart';

void main() async {
  debugPrint('Testing API integration...\n');
  
  final dio = HttpClient.createDio();
  final authDataSource = AuthRemoteDataSourceImpl(dio: dio);
  
  try {
    // Test registration
    final registerResponse = await authDataSource.register(
      'test@example.com', 
      'password123', 
      'Test User'
    );
    debugPrint('Registration successful: ${registerResponse['user']['name']}');
    
    // Create authenticated client
    final authDio = HttpClient.createAuthenticatedDio(registerResponse['token']);
    final taskDataSource = TaskRemoteDataSourceImpl(dio: authDio);
    
    // Test task creation
    final task = await taskDataSource.createTask(
      TaskModel(
        id: '1',
        title: 'Test Task',
        description: 'Integration test task',
        status: 0,
        priority: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )
    );
    debugPrint('Task created: ${task.title}');
    
    // Test get tasks
    final tasks = await taskDataSource.getTasks();
    debugPrint('Retrieved ${tasks.length} tasks');
    
    debugPrint('\n Integration test completed successfully!');
    
  } catch (e) {
    debugPrint('Integration test failed: $e');
  }
}