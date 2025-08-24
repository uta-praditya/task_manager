import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/di/injection_container.dart' as di;
import 'features/tasks/data/models/task_model.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(TaskModelAdapter());
  
  await di.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AuthBloc>(),
      child: MaterialApp(
        title: 'Task Manager',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            elevation: 4,
          ),
        ),
        home: const SplashPage(),
      ),
    );
  }
}