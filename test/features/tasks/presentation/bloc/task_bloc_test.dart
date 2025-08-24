import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_manager/core/error/failures.dart';
import 'package:task_manager/features/tasks/data/models/task_model.dart';
import 'package:task_manager/features/tasks/domain/usecases/create_task.dart';
import 'package:task_manager/features/tasks/domain/usecases/get_tasks.dart';
import 'package:task_manager/features/tasks/domain/usecases/update_task.dart';
import 'package:task_manager/features/tasks/domain/usecases/delete_task.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_event.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_state.dart';

class MockGetTasks extends Mock implements GetTasks {}
class MockCreateTask extends Mock implements CreateTask {}
class MockUpdateTask extends Mock implements UpdateTask {}
class MockDeleteTask extends Mock implements DeleteTask {}

void main() {
  late TaskBloc taskBloc;
  late MockGetTasks mockGetTasks;
  late MockCreateTask mockCreateTask;

  setUp(() {
    mockGetTasks = MockGetTasks();
    mockCreateTask = MockCreateTask();
    taskBloc = TaskBloc(
      getTasks: mockGetTasks,
      createTask: mockCreateTask,
      updateTask: MockUpdateTask(),
      deleteTask: MockDeleteTask(),
    );
  });

  tearDown(() {
    taskBloc.close();
  });

  final tTasks = [
    TaskModel(
      id: '1',
      title: 'Test Task',
      description: 'Test Description',
      status: TaskStatus.toDo.index,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  group('LoadTasksEvent', () {
    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TaskLoaded] when tasks are loaded successfully',
      build: () {
        when(() => mockGetTasks()).thenAnswer((_) async => Right(tTasks));
        return taskBloc;
      },
      act: (bloc) => bloc.add(LoadTasksEvent()),
      expect: () => [
        TaskLoading(),
        TaskLoaded(tTasks),
      ],
      verify: (_) {
        verify(() => mockGetTasks()).called(1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TaskError] when loading tasks fails',
      build: () {
        when(() => mockGetTasks()).thenAnswer((_) async => Left(CacheFailure()));
        return taskBloc;
      },
      act: (bloc) => bloc.add(LoadTasksEvent()),
      expect: () => [
        TaskLoading(),
        const TaskError('Failed to load tasks'),
      ],
      verify: (_) {
        verify(() => mockGetTasks()).called(1);
      },
    );
  });

  group('CreateTaskEvent', () {
    final tTask = TaskModel(
      id: '2',
      title: 'New Task',
      description: 'New Description',
      status: TaskStatus.toDo.index,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    blocTest<TaskBloc, TaskState>(
      'creates task and reloads tasks when successful',
      build: () {
        when(() => mockCreateTask('New Task', 'New Description'))
            .thenAnswer((_) async => Right(tTask));
        when(() => mockGetTasks()).thenAnswer((_) async => Right([...tTasks, tTask]));
        return taskBloc;
      },
      act: (bloc) => bloc.add(const CreateTaskEvent(
        title: 'New Task',
        description: 'New Description',
      )),
      expect: () => [
        TaskLoading(),
        TaskLoaded([...tTasks, tTask]),
      ],
      verify: (_) {
        verify(() => mockCreateTask('New Task', 'New Description')).called(1);
        verify(() => mockGetTasks()).called(1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'emits TaskError when task creation fails',
      build: () {
        when(() => mockCreateTask('New Task', 'New Description'))
            .thenAnswer((_) async => Left(CacheFailure()));
        return taskBloc;
      },
      act: (bloc) => bloc.add(const CreateTaskEvent(
        title: 'New Task',
        description: 'New Description',
      )),
      expect: () => [
        const TaskError('Failed to create task'),
      ],
      verify: (_) {
        verify(() => mockCreateTask('New Task', 'New Description')).called(1);
      },
    );
  });
}