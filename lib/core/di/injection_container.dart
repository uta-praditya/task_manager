import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../network/http_client.dart';
import '../../features/tasks/data/datasources/task_local_datasource.dart';
import '../../features/tasks/data/datasources/task_remote_datasource.dart';
import '../../features/tasks/data/models/task_model.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/domain/usecases/create_task.dart';
import '../../features/tasks/domain/usecases/get_tasks.dart';
import '../../features/tasks/domain/usecases/update_task.dart';
import '../../features/tasks/domain/usecases/delete_task.dart';
import '../../features/tasks/presentation/bloc/task_bloc.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../../features/auth/domain/usecases/logout_user.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Bloc
  sl.registerFactory(() => TaskBloc(
    getTasks: sl(),
    createTask: sl(),
    updateTask: sl(),
    deleteTask: sl(),
  ));
  
  sl.registerFactory(() => AuthBloc(
    loginUser: sl(),
    registerUser: sl(),
    logoutUser: sl(),
  ));

  // Use cases
  sl.registerLazySingleton(() => GetTasks(sl()));
  sl.registerLazySingleton(() => CreateTask(sl()));
  sl.registerLazySingleton(() => UpdateTask(sl()));
  sl.registerLazySingleton(() => DeleteTask(sl()));
  
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));

  // Repository
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      connectivity: sl(),
    ),
  );
  
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(taskBox: sl()),
  );
  sl.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  // External
  final taskBox = await Hive.openBox<TaskModel>('tasks');
  
  // One-time migration for schema changes
  const migrationKey = 'schema_version';
  const currentVersion = 2;
  final prefs = await Hive.openBox('settings');
  final savedVersion = prefs.get(migrationKey, defaultValue: 1);
  
  if (savedVersion < currentVersion) {
    await taskBox.clear();
    await prefs.put(migrationKey, currentVersion);
  }
  
  sl.registerLazySingleton(() => taskBox);
  
  // External dependencies
  sl.registerLazySingleton(() => Connectivity());
  
  // Create basic Dio instance
  sl.registerLazySingleton<Dio>(() => HttpClient.createDio());
}