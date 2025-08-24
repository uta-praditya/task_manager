import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:task_manager/core/error/failures.dart';
import 'package:task_manager/features/tasks/data/models/task_model.dart';
import 'package:task_manager/features/tasks/domain/repositories/task_repository.dart';
import 'package:task_manager/features/tasks/domain/usecases/update_task.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late UpdateTask usecase;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    usecase = UpdateTask(mockRepository);
  });

  final testTask = TaskModel(
    id: '1',
    title: 'Updated Task',
    status: 1,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUpAll(() {
    registerFallbackValue(testTask);
  });

  test('should update task in repository', () async {
    when(() => mockRepository.updateTask(any()))
        .thenAnswer((_) async => Right(testTask));

    final result = await usecase(testTask);

    expect(result, Right(testTask));
    verify(() => mockRepository.updateTask(testTask));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    when(() => mockRepository.updateTask(any()))
        .thenAnswer((_) async => Left(ServerFailure()));

    final result = await usecase(testTask);

    expect(result, Left(ServerFailure()));
    verify(() => mockRepository.updateTask(testTask));
  });
}