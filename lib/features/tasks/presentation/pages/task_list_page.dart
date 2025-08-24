import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:task_manager/features/auth/presentation/pages/login_page.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_event.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../bloc/task_bloc.dart';
import '../widgets/task_item.dart';
import '../widgets/task_filter_chip.dart';
import '../widgets/task_stats_card.dart';
import 'create_task_page.dart';
import '../../data/models/task_model.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final _searchController = TextEditingController();
  TaskStatus? _selectedFilter;
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Tasks',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              if (state is TaskSyncing) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Syncing...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
        bottom: _showSearch ? PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
        ) : null,
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading tasks...'),
                ],
              ),
            );
          } else if (state is TaskLoaded || state is TaskSyncing) {
            final tasks = state is TaskLoaded 
                ? state.tasks 
                : (state as TaskSyncing).tasks;
            final filteredTasks = _getFilteredTasks(tasks);
            
            if (tasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tasks yet',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to create your first task',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return Column(
              children: [
                TaskStatsCard(tasks: tasks),
                TaskFilterChip(
                  selectedStatus: _selectedFilter,
                  onStatusChanged: (status) {
                    setState(() {
                      _selectedFilter = status;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filteredTasks.isEmpty && tasks.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No tasks found',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your search or filter',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedFilter = null;
                                    _searchController.clear();
                                    _showSearch = false;
                                  });
                                },
                                child: const Text('Show All Tasks'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:  EdgeInsets.only(bottom: (index + 1) >= filteredTasks.length ? 120 : 12),
                              child: TaskItem(task: filteredTasks[index]),
                            );
                          },
                        ),
                ),
              ],
            );
          } else if (state is TaskError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Oops! Something went wrong',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<TaskBloc>().add(LoadTasksEvent()),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateTask(context),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }

  void _navigateToCreateTask(BuildContext context) {
    final taskBloc = context.read<TaskBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: taskBloc,
          child: const CreateTaskPage(),
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    final authBloc = context.read<AuthBloc>();
    
    // Clear local task data
    try {
      final taskBox = di.sl<Box<TaskModel>>();
      await taskBox.clear();
    } catch (e) {
      // Handle error silently
    }
    
    if (!mounted) return;
    
    // Trigger AuthBloc logout
    authBloc.add(LogoutEvent());
    
    // Navigate to login
    Navigator.pushAndRemoveUntil(
      this.context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (_) => di.sl<AuthBloc>(),
          child: const LoginPage(),
        ),
      ),
      (route) => false,
    );
  }

  List<TaskModel> _getFilteredTasks(List<TaskModel> tasks) {
    if (tasks.isEmpty) return tasks;
    
    final query = _searchController.text.toLowerCase().trim();
    
    return tasks.where((task) {
      // Status filter
      if (_selectedFilter != null && task.taskStatus != _selectedFilter) {
        return false;
      }
      
      // Search filter
      if (query.isNotEmpty) {
        return task.title.toLowerCase().contains(query) ||
               (task.description?.toLowerCase().contains(query) ?? false);
      }
      
      return true;
    }).toList()..sort((a, b) {
      // Smart sorting: overdue first, then priority, then due date
      if (a.isOverdue && !b.isOverdue) return -1;
      if (!a.isOverdue && b.isOverdue) return 1;
      
      final priorityComparison = b.priority.compareTo(a.priority);
      if (priorityComparison != 0) return priorityComparison;
      
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      
      return a.createdAt.compareTo(b.createdAt);
    });
  }
}