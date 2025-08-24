import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:task_manager/features/tasks/domain/usecases/create_task.dart';
import 'package:task_manager/features/tasks/domain/usecases/get_tasks.dart';
import 'package:task_manager/features/tasks/domain/usecases/update_task.dart';
import 'package:task_manager/features/tasks/domain/usecases/delete_task.dart';
import 'package:task_manager/features/auth/domain/usecases/login_user.dart';
import 'package:task_manager/features/auth/domain/usecases/register_user.dart';
import 'package:task_manager/features/auth/domain/usecases/logout_user.dart';

import 'package:task_manager/features/tasks/data/models/task_model.dart';
import 'package:task_manager/features/auth/data/models/user_model.dart';
import 'package:task_manager/features/tasks/data/repositories/task_repository_impl.dart';

import 'package:task_manager/features/tasks/domain/repositories/task_repository.dart';
import 'package:task_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:task_manager/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:task_manager/features/tasks/data/datasources/task_remote_datasource.dart';

class MockTaskRepository extends Mock implements TaskRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockTaskLocalDataSource extends Mock implements TaskLocalDataSource {}
class MockTaskRemoteDataSource extends Mock implements TaskRemoteDataSource {}
class MockConnectivity extends Mock implements Connectivity {}

void main() {
  group('Fixed Domain + Data Layer Tests', () {
    late TaskModel testTask;
    late UserModel testUser;

    setUp(() {
      testTask = TaskModel(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        status: 0,
        priority: 1,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        dueDate: DateTime(2025, 12, 31), // Future date
      );

      testUser = const UserModel(
        id: '1',
        email: 'test@example.com',
        name: 'Test User',
      );
    });

    setUpAll(() {
      registerFallbackValue(TaskModel(
        id: 'fallback',
        title: 'Fallback',
        status: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    });

    group('Task Domain Use Cases', () {
      late MockTaskRepository mockRepository;

      setUp(() {
        mockRepository = MockTaskRepository();
      });

      test('CreateTask executes successfully', () async {
        when(() => mockRepository.createTask('Test', 'Desc'))
            .thenAnswer((_) async => Right(testTask));

        final usecase = CreateTask(mockRepository);
        final result = await usecase('Test', 'Desc');

        expect(result.isRight(), true);
        verify(() => mockRepository.createTask('Test', 'Desc'));
      });

      test('GetTasks executes successfully', () async {
        when(() => mockRepository.getTasks())
            .thenAnswer((_) async => Right([testTask]));

        final usecase = GetTasks(mockRepository);
        final result = await usecase();

        expect(result.isRight(), true);
        verify(() => mockRepository.getTasks());
      });

      test('UpdateTask executes successfully', () async {
        when(() => mockRepository.updateTask(any()))
            .thenAnswer((_) async => Right(testTask));

        final usecase = UpdateTask(mockRepository);
        final result = await usecase(testTask);

        expect(result.isRight(), true);
        verify(() => mockRepository.updateTask(testTask));
      });

      test('DeleteTask executes successfully', () async {
        when(() => mockRepository.deleteTask('1'))
            .thenAnswer((_) async => const Right(null));

        final usecase = DeleteTask(mockRepository);
        final result = await usecase('1');

        expect(result.isRight(), true);
        verify(() => mockRepository.deleteTask('1'));
      });
    });

    group('Auth Domain Use Cases', () {
      late MockAuthRepository mockRepository;

      setUp(() {
        mockRepository = MockAuthRepository();
      });

      test('LoginUser executes successfully', () async {
        when(() => mockRepository.login('email', 'pass'))
            .thenAnswer((_) async => Right(testUser));

        final usecase = LoginUser(mockRepository);
        final result = await usecase('email', 'pass');

        expect(result.isRight(), true);
        verify(() => mockRepository.login('email', 'pass'));
      });

      test('RegisterUser executes successfully', () async {
        when(() => mockRepository.register('email', 'pass', 'name'))
            .thenAnswer((_) async => Right(testUser));

        final usecase = RegisterUser(mockRepository);
        final result = await usecase('email', 'pass', 'name');

        expect(result.isRight(), true);
        verify(() => mockRepository.register('email', 'pass', 'name'));
      });

      test('LogoutUser executes successfully', () async {
        when(() => mockRepository.logout())
            .thenAnswer((_) async => const Right(null));

        final usecase = LogoutUser(mockRepository);
        final result = await usecase();

        expect(result.isRight(), true);
        verify(() => mockRepository.logout());
      });
    });

    group('Data Models', () {
      test('TaskModel properties and methods', () {
        expect(testTask.id, '1');
        expect(testTask.title, 'Test Task');
        expect(testTask.taskStatus, TaskStatus.toDo);
        expect(testTask.taskPriority, TaskPriority.medium);
        expect(testTask.isOverdue, false); // Future date

        final json = testTask.toJson();
        expect(json['title'], 'Test Task');

        final fromJson = TaskModel.fromJson(json);
        expect(fromJson.title, 'Test Task');
      });

      test('UserModel properties and methods', () {
        expect(testUser.id, '1');
        expect(testUser.email, 'test@example.com');
        expect(testUser.name, 'Test User');

        final json = testUser.toJson();
        expect(json['email'], 'test@example.com');

        final fromJson = UserModel.fromJson(json);
        expect(fromJson.email, 'test@example.com');
      });
    });

    group('Repository Implementations', () {
      late MockTaskLocalDataSource mockLocalDataSource;
      late MockTaskRemoteDataSource mockRemoteDataSource;
      late MockConnectivity mockConnectivity;

      setUp(() {
        mockLocalDataSource = MockTaskLocalDataSource();
        mockRemoteDataSource = MockTaskRemoteDataSource();
        mockConnectivity = MockConnectivity();
      });

      test('TaskRepositoryImpl offline behavior', () async {
        when(() => mockLocalDataSource.getTasks())
            .thenAnswer((_) async => [testTask]);
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.none);

        final repository = TaskRepositoryImpl(
          localDataSource: mockLocalDataSource,
          remoteDataSource: mockRemoteDataSource,
          connectivity: mockConnectivity,
        );

        final result = await repository.getTasks();

        expect(result.isRight(), true);
        verify(() => mockLocalDataSource.getTasks());
        verify(() => mockConnectivity.checkConnectivity());
      });

      test('TaskRepositoryImpl online sync behavior', () async {
        when(() => mockLocalDataSource.getTasks())
            .thenAnswer((_) async => []);
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        when(() => mockRemoteDataSource.getTasks())
            .thenAnswer((_) async => [testTask]);
        when(() => mockLocalDataSource.updateTask(any()))
            .thenAnswer((_) async => testTask);

        final repository = TaskRepositoryImpl(
          localDataSource: mockLocalDataSource,
          remoteDataSource: mockRemoteDataSource,
          connectivity: mockConnectivity,
        );

        final result = await repository.getTasks();

        expect(result.isRight(), true);
        verify(() => mockRemoteDataSource.getTasks());
        verify(() => mockLocalDataSource.updateTask(testTask));
      });

      test('TaskRepositoryImpl create task', () async {
        when(() => mockLocalDataSource.createTask(any()))
            .thenAnswer((_) async => testTask);
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        when(() => mockRemoteDataSource.createTask(any()))
            .thenAnswer((_) async => testTask);

        final repository = TaskRepositoryImpl(
          localDataSource: mockLocalDataSource,
          remoteDataSource: mockRemoteDataSource,
          connectivity: mockConnectivity,
        );

        final result = await repository.createTask('Test', 'Desc');

        expect(result.isRight(), true);
        verify(() => mockLocalDataSource.createTask(any()));
        verify(() => mockRemoteDataSource.createTask(any()));
      });
    });
  });
}