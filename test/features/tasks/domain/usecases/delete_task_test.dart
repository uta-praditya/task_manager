import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:task_manager/core/error/failures.dart';
import 'package:task_manager/features/tasks/domain/repositories/task_repository.dart';
import 'package:task_manager/features/tasks/domain/usecases/delete_task.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late DeleteTask usecase;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    usecase = DeleteTask(mockRepository);
  });

  const testTaskId = '1';

  test('should delete task from repository', () async {
    when(() => mockRepository.deleteTask(testTaskId))
        .thenAnswer((_) async => const Right(null));

    final result = await usecase(testTaskId);

    expect(result, const Right(null));
    verify(() => mockRepository.deleteTask(testTaskId));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    when(() => mockRepository.deleteTask(testTaskId))
        .thenAnswer((_) async => Left(ServerFailure()));

    final result = await usecase(testTaskId);

    expect(result, Left(ServerFailure()));
    verify(() => mockRepository.deleteTask(testTaskId));
  });
}