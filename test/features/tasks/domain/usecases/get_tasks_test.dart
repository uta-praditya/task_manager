import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:task_manager/core/error/failures.dart';
import 'package:task_manager/features/tasks/data/models/task_model.dart';
import 'package:task_manager/features/tasks/domain/repositories/task_repository.dart';
import 'package:task_manager/features/tasks/domain/usecases/get_tasks.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late GetTasks usecase;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    usecase = GetTasks(mockRepository);
  });

  final testTasks = [
    TaskModel(
      id: '1',
      title: 'Task 1',
      status: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    TaskModel(
      id: '2',
      title: 'Task 2',
      status: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  test('should get tasks from repository', () async {
    when(() => mockRepository.getTasks())
        .thenAnswer((_) async => Right(testTasks));

    final result = await usecase();

    expect(result, Right(testTasks));
    verify(() => mockRepository.getTasks());
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    when(() => mockRepository.getTasks())
        .thenAnswer((_) async => Left(CacheFailure()));

    final result = await usecase();

    expect(result, Left(CacheFailure()));
    verify(() => mockRepository.getTasks());
  });
}