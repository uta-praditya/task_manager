import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/features/tasks/data/models/task_model.dart';

void main() {
  final testTask = TaskModel(
    id: '1',
    title: 'Test Task',
    description: 'Test Description',
    status: 0,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 2),
    priority: 1,
    dueDate: DateTime(2024, 1, 15),
  );

  group('TaskModel', () {
    test('should create task with all properties', () {
      expect(testTask.id, '1');
      expect(testTask.title, 'Test Task');
      expect(testTask.description, 'Test Description');
      expect(testTask.status, 0);
      expect(testTask.priority, 1);
    });

    test('should return correct task status enum', () {
      expect(testTask.taskStatus, TaskStatus.toDo);
      
      final inProgressTask = TaskModel(
        id: '2',
        title: 'In Progress',
        status: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(inProgressTask.taskStatus, TaskStatus.inProgress);
    });

    test('should return correct task priority enum', () {
      expect(testTask.taskPriority, TaskPriority.medium);
      
      final highPriorityTask = TaskModel(
        id: '3',
        title: 'High Priority',
        status: 0,
        priority: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(highPriorityTask.taskPriority, TaskPriority.high);
    });

    test('should detect overdue tasks correctly', () {
      final overdueTask = TaskModel(
        id: '4',
        title: 'Overdue Task',
        status: 0,
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(overdueTask.isOverdue, true);

      final futureTask = TaskModel(
        id: '5',
        title: 'Future Task',
        status: 0,
        dueDate: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(futureTask.isOverdue, false);
    });

    test('should convert to JSON correctly', () {
      final json = testTask.toJson();
      
      expect(json['id'], '1');
      expect(json['title'], 'Test Task');
      expect(json['description'], 'Test Description');
      expect(json['status'], 0);
      expect(json['priority'], 1);
    });

    test('should create from JSON correctly', () {
      final json = {
        'id': '1',
        'title': 'Test Task',
        'description': 'Test Description',
        'status': 0,
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-02T00:00:00.000',
        'priority': 1,
        'dueDate': '2024-01-15T00:00:00.000',
      };

      final task = TaskModel.fromJson(json);
      
      expect(task.id, '1');
      expect(task.title, 'Test Task');
      expect(task.description, 'Test Description');
      expect(task.status, 0);
      expect(task.priority, 1);
    });
  });
}