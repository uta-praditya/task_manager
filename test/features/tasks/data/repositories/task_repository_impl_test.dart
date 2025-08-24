import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:task_manager/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:task_manager/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:task_manager/features/tasks/data/models/task_model.dart';
import 'package:task_manager/features/tasks/data/repositories/task_repository_impl.dart';

class MockTaskLocalDataSource extends Mock implements TaskLocalDataSource {}
class MockTaskRemoteDataSource extends Mock implements TaskRemoteDataSource {}
class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late TaskRepositoryImpl repository;
  late MockTaskLocalDataSource mockLocalDataSource;
  late MockTaskRemoteDataSource mockRemoteDataSource;
  late MockConnectivity mockConnectivity;

  setUp(() {
    mockLocalDataSource = MockTaskLocalDataSource();
    mockRemoteDataSource = MockTaskRemoteDataSource();
    mockConnectivity = MockConnectivity();
    repository = TaskRepositoryImpl(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
      connectivity: mockConnectivity,
    );
  });

  final testTask = TaskModel(
    id: '1',
    title: 'Test Task',
    status: 0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUpAll(() {
    registerFallbackValue(testTask);
  });

  group('getTasks', () {
    test('should return local tasks when offline', () async {
      when(() => mockLocalDataSource.getTasks())
          .thenAnswer((_) async => [testTask]);
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);

      final result = await repository.getTasks();

      expect(result.isRight(), true);
      verify(() => mockLocalDataSource.getTasks());
      verify(() => mockConnectivity.checkConnectivity());
    });

    test('should sync with remote when online', () async {
      when(() => mockLocalDataSource.getTasks())
          .thenAnswer((_) async => []);
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(() => mockRemoteDataSource.getTasks())
          .thenAnswer((_) async => [testTask]);
      when(() => mockLocalDataSource.updateTask(any()))
          .thenAnswer((_) async => testTask);

      final result = await repository.getTasks();

      expect(result.isRight(), true);
      verify(() => mockRemoteDataSource.getTasks());
      verify(() => mockLocalDataSource.updateTask(testTask));
    });
  });

  group('createTask', () {
    test('should create task locally and sync when online', () async {
      when(() => mockLocalDataSource.createTask(any()))
          .thenAnswer((_) async => testTask);
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(() => mockRemoteDataSource.createTask(any()))
          .thenAnswer((_) async => testTask);

      final result = await repository.createTask('Test Task', null);

      expect(result.isRight(), true);
      verify(() => mockLocalDataSource.createTask(any()));
      verify(() => mockRemoteDataSource.createTask(any()));
    });
  });
}