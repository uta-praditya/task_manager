import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/delete_task.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasks getTasks;
  final CreateTask createTask;
  final UpdateTask updateTask;
  final DeleteTask deleteTask;

  TaskBloc({
    required this.getTasks,
    required this.createTask,
    required this.updateTask,
    required this.deleteTask,
  }) : super(TaskInitial()) {
    on<LoadTasksEvent>(_onLoadTasks);
    on<CreateTaskEvent>(_onCreateTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
  }

  Future<void> _onLoadTasks(LoadTasksEvent event, Emitter<TaskState> emit) async {
    if (state is! TaskLoaded) {
      emit(TaskLoading());
    } else {
      emit(TaskSyncing((state as TaskLoaded).tasks));
    }
    
    final result = await getTasks();
    result.fold(
      (failure) => emit(const TaskError('Failed to load tasks')),
      (tasks) => emit(TaskLoaded(tasks)),
    );
  }

  Future<void> _onCreateTask(CreateTaskEvent event, Emitter<TaskState> emit) async {
    if (state is TaskLoaded) {
      emit(TaskSyncing((state as TaskLoaded).tasks));
    }
    
    final result = await createTask(
      event.title, 
      event.description,
      status: event.status,
      priority: event.priority,
      dueDate: event.dueDate,
    );
    result.fold(
      (failure) => emit(const TaskError('Failed to create task')),
      (task) => add(LoadTasksEvent()),
    );
  }

  Future<void> _onUpdateTask(UpdateTaskEvent event, Emitter<TaskState> emit) async {
    if (state is TaskLoaded) {
      emit(TaskSyncing((state as TaskLoaded).tasks));
    }
    
    final result = await updateTask(event.task);
    result.fold(
      (failure) => emit(const TaskError('Failed to update task')),
      (task) => add(LoadTasksEvent()),
    );
  }

  Future<void> _onDeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) async {
    if (state is TaskLoaded) {
      emit(TaskSyncing((state as TaskLoaded).tasks));
    }
    
    final result = await deleteTask(event.taskId);
    result.fold(
      (failure) => emit(const TaskError('Failed to delete task')),
      (_) => add(LoadTasksEvent()),
    );
  }
}