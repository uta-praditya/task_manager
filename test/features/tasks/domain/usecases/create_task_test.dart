import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:task_manager/core/error/failures.dart';
import 'package:task_manager/features/tasks/data/models/task_model.dart';
import 'package:task_manager/features/tasks/domain/repositories/task_repository.dart';
import 'package:task_manager/features/tasks/domain/usecases/create_task.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late CreateTask usecase;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    usecase = CreateTask(mockRepository);
  });

  const testTitle = 'Test Task';
  const testDescription = 'Test Description';
  final testTask = TaskModel(
    id: '1',
    title: testTitle,
    description: testDescription,
    status: 0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  test('should create task from repository', () async {
    when(() => mockRepository.createTask(testTitle, testDescription))
        .thenAnswer((_) async => Right(testTask));

    final result = await usecase(testTitle, testDescription);

    expect(result, Right(testTask));
    verify(() => mockRepository.createTask(testTitle, testDescription));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    when(() => mockRepository.createTask(testTitle, testDescription))
        .thenAnswer((_) async => Left(ServerFailure()));

    final result = await usecase(testTitle, testDescription);

    expect(result, Left(ServerFailure()));
    verify(() => mockRepository.createTask(testTitle, testDescription));
  });
}