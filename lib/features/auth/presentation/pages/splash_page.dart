import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_event.dart';
import '../../../tasks/presentation/bloc/task_bloc.dart';
import '../../../tasks/presentation/pages/task_list_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../core/di/injection_container.dart' as di;
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _animationController.forward();
    _navigateToLogin();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Trigger auth check after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(CheckAuthStatusEvent());
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  _navigateToLogin() async {
    // Animation delay only
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (_) => di.sl<TaskBloc>()..add(LoadTasksEvent()),
                child: const TaskListPage(),
              ),
            ),
          );
        } else if (state is AuthUnauthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (_) => di.sl<AuthBloc>(),
                child: const LoginPage(),
              ),
            ),
          );
        }
      },
      child: Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.task_alt,
                          size: 80,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Task Manager',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Organize your tasks efficiently',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 64),
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Theme.of(context).colorScheme.onPrimary,
                          backgroundColor: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          ),
        ),
      ),
    );
  }
}